import axios from 'axios'
import * as cheerio from 'cheerio'
import { CreateProductWorkflowInputDTO } from "@medusajs/framework/types"
import { getCategoryFromSubtitle } from './crawl-attributes/category-mapper'
import { ollamaService } from '../services/ollama'
import { transformSpecs } from './dimensionHandler'

interface ProductOption {
  name: string
  values: string[]
}

interface ProductImage {
  url: string
  alt: string
}

interface ProductVariant {
  title: string
  sku?: string
  prices: {
    amount: number
    currency_code: string,
    price_list_id?: string
  }[]
  options: {
    value: string
  }[]
  images: string[]
  metadata: {
    specifications: Record<string, string>
    dimensions?: string
    material?: string
    weight?: string
    assembly?: string
    materialDetails?: string
    indoorOutdoorUse?: string
    tabletopHeight?: string
    tabletopThickness?: string
    packagingDimensions?: string
    shippingCartons?: string
    highlights: Highlight[]
    handle: string
    swatchStyle?: string
    dimensionImage?: string
    salePrice?: number
    tags?: string[]
    normalPrice: number
  }
}

interface ProductDetails {
  name: string
  subtitle?: string
  originalPrice: number
  salePrice?: number
  options: ProductOption[]
  images: ProductImage[]
  description: string
  specifications: Record<string, string>
  variants: ProductVariant[]
  metadata: {
    highlights: Highlight[]
    productType?: string
  }
}

interface Highlight {
  image: string
  title: string
  content: string
}

function cleanImageUrl(url: string): string {
  // Remove size dimensions like _1180x, _640x etc from the URL
  let cleanUrl = url.replace(/_([\d]+)x\./i, '.')
  
  // Remove URL parameters (everything after and including ?)
  cleanUrl = cleanUrl.split('?')[0]
  
  return cleanUrl
}

function isLargeImage(url: string): boolean {
  // Check for specific size indicators
  if (url.includes('2172x') || 
      url.includes('1800x') || 
      url.includes('files/') ||
      url.includes('_large') ||
      url.includes('_2048x')) {
    return true
  }

  // Extract size from URL (e.g., "60x", "1180x")
  const sizeMatch = url.match(/(\d+)x/)
  if (sizeMatch) {
    const size = parseInt(sizeMatch[1])
    return size >= 200
  }

  return true // If no size found, include the image
}

function removeDuplicateImages(images: string[]): string[] {
  // Clean URLs first and create a map to remove duplicates
  const uniqueUrls = new Map<string, string>()
  
  images.forEach(url => {
    const cleanedUrl = cleanImageUrl(url)
    // Keep the version with larger dimensions by checking if it includes a larger number
    const currentSize = url.match(/_([\d]+)x\./i)?.[1] || '0'
    const existingUrl = uniqueUrls.get(cleanedUrl)
    const existingSize = existingUrl?.match(/_([\d]+)x\./i)?.[1] || '0'
    
    if (!existingUrl || parseInt(currentSize) > parseInt(existingSize)) {
      uniqueUrls.set(cleanedUrl, url)
    }
  })
  
  return Array.from(uniqueUrls.values())
}

function normalizeImageUrl(url: string): string {
  // Ensure URL starts with http
  if (!url.startsWith('http')) {
    url = `https:${url.startsWith('//') ? url : `//${url}`}`
  }
  
  // Remove any URL parameters (everything after ?)
  url = url.split('?')[0]
  
  // Remove size dimensions like _1180x
  url = url.replace(/_([\d]+)x\./i, '.')
  
  return url
}

async function fetchProductJson(url: string): Promise<{
  images: ProductImage[]
  productType?: string
}> {
  try {
    // Convert URL to JSON endpoint
    const jsonUrl = url.endsWith('.json') ? url : `${url}.json`
    const response = await axios.get(jsonUrl)
    
    // Extract images from JSON response
    const images: ProductImage[] = response.data.product.images
      .filter(img => {
        const imgUrl = img.src.toLowerCase()
        return !imgUrl.includes('lifestyle')
      })
      .map(img => ({
        url: cleanImageUrl(img.src),
        alt: img.alt || ''
      }))

    // Extract product type
    const productType = response.data.product.product_type || undefined

    return { 
      images, 
      productType 
    }
  } catch (error) {
    console.error('Error fetching product JSON:', error)
    return { 
      images: [],
      productType: undefined 
    }
  }
}

async function crawlVariantPage(url: string): Promise<{
  price: number
  salePrice?: number
  images: string[]
  sku: string
  specifications: Record<string, string>
  highlights: Highlight[]
  handle: string
  swatchStyle?: string
  tags: string[]
}> {
  const response = await axios.get(url)
  const $ = cheerio.load(response.data)

  // Extract handle from URL
  const handle = url.split('/').pop()?.split('?')[0] || ''

  // Fetch JSON data for the variant
  let tags: string[] = []
  try {
    const jsonUrl = `https://interioricons.com/products/${handle}.json`
    const jsonResponse = await axios.get(jsonUrl)
    tags = jsonResponse.data.product.tags?.split(',').map(tag => tag.trim()) || []
  } catch (error) {
    console.error(`Error fetching JSON for variant ${handle}:`, error)
  }

  // Extract swatch style
  const swatchStyle = $('li.swatch.active').attr('style') || 
                     $(`a[href*="${handle}"]`).attr('style')

  // Extract prices from data-amount attributes
  const originalPrice = parseInt($('.old-price').eq(1).attr('data-amount') || '0')
  const salePrice = parseInt($('.variant-price.sale-price').attr('data-amount') || '0')
  
  // Replace the image crawling section with JSON fetch
  const variantImages = await fetchProductJson(url)
  const images = variantImages.images.map(img => cleanImageUrl(img.url))

  // Extract specifications for this variant
  const specifications: Record<string, string> = {}
  $('.usp-item.pdh .specs li').each((_, element) => {
    const key = $(element).find('b').text().trim().replace(':', '').trim()
    let value = $(element).find('span[class^="js-"]').text().trim()
    
    if (key && value) {
      
      specifications[key] = value
    }
  })

  // Extract highlights
  const highlights: Highlight[] = []
  $('.mw9.pdh.product-module-wrap.lifestyle__items').find('.lifestyle__item').each((_, element) => {
    let image = $(element).find('img').attr('src')
    const title = $(element).find('h3, .hd3').text().trim()
    const content = $(element).find('p').text().trim()

    if (image && title && content) {
      // Ensure image URL starts with https
      if (!image.startsWith('http')) {
        image = `https:${image.startsWith('//') ? image : `//${image}`}`
      }
      
      highlights.push({
        image: cleanImageUrl(image),
        title,
        content
      })
    }
  })

  // Add this line after collecting all images
  const uniqueImages = removeDuplicateImages(images)

  // Remove duplicates before returning
  return {
    price: originalPrice,
    salePrice: salePrice || undefined,
    images: uniqueImages,
    sku: handle,
    specifications,
    highlights,
    handle,
    swatchStyle,
    tags
  }
}

export async function crawlProductPage(url: string): Promise<ProductDetails> {
  try {
    const response = await axios.get(url)
    const $ = cheerio.load(response.data)
    
    // Extract basic product info
    const name = $('h1').first().text().trim()
    const activeOptionValue = $('.swatch.active').attr('content')?.trim() || ''
    let subtitle = $('.product__subtitle').text().trim()

    // Remove active option value from subtitle if present
    if (activeOptionValue) {
      subtitle = subtitle
        .replace(`, ${activeOptionValue}`, '')  // Remove with comma
        .replace(` ${activeOptionValue}`, '')   // Remove without comma
        .trim()
    }

    // Convert any inch measurements in subtitle to cm
    subtitle = convertMeasurements(subtitle)

    
    // Extract base prices
    const priceText = $('h1').nextAll().find('span').first().text().trim()
    const originalPrice = parseFloat(priceText.replace(/[^0-9.]/g, '')) || 0
    
    const salePriceText = $('h1').nextAll().find('span').last().text().trim()
    const salePrice = parseFloat(salePriceText.replace(/[^0-9.]/g, ''))
    
    // Extract product options and build variant URLs
    const options: ProductOption[] = [{
      name: 'Material',
      values: []
    }]
    
    const variantUrls: string[] = []
    
    // Find all marble style options and their URLs
    $('a[name="product_button"]').each((_, element) => {
      const href = $(element).attr('href')
      const value = $(element).find('span.whitespace-nowrap').text().trim()
      
      if (value && href) {
        options[0].values.push(value)
        const variantUrl = href.startsWith('http') ? 
          href : 
          new URL(href, 'https://interioricons.com').href
        variantUrls.push(variantUrl)
      }
    })

    // If no variants found, try alternative selector
    if (options[0].values.length === 0) {
      $('div[role="radiogroup"] a').each((_, element) => {
        const href = $(element).attr('href')
        const value = $(element).find('span:not(.visually-hidden)').text().trim()
        
        if (value && href) {
          options[0].values.push(value)
          const variantUrl = href.startsWith('http') ? 
            href : 
            new URL(href, 'https://interioricons.com').href
          variantUrls.push(variantUrl)
        }
      })
    }

    // If still no variants found, create a default variant
    if (options[0].values.length === 0) {
      const defaultVariantValue = `${name}${subtitle ? ` - ${subtitle}` : ''}`
      options[0].values.push(defaultVariantValue)
      variantUrls.push(url)
    }
    
    // Crawl each variant
    const variants: ProductVariant[] = []
    for (let i = 0; i < options[0].values.length; i++) {
      const variantUrl = variantUrls[i]
      const variantValue = options[0].values[i]
      
      try {
        const variantData = await crawlVariantPage(variantUrl)
        variants.push({
          title: `${name} - ${variantValue}`,
          sku: variantData.handle,
          options: [{
            value: variantValue
          }],
          prices: [{
            amount: variantData.price,
            currency_code: 'usd'
          },
        ],
          images: variantData.images,
          metadata: {
            specifications: variantData.specifications,
            highlights: variantData.highlights,
            handle: variantData.handle,
            swatchStyle: variantData.swatchStyle,
            salePrice: variantData.salePrice || undefined,
            tags: variantData.tags,
            normalPrice: variantData.price
          }
        })
      } catch (error) {
        throw new Error(`Failed to crawl variant ${variantValue}: ${error.message}`)
      }
    }
    
    // Fetch JSON data
    const { images: rawImages, productType } = await fetchProductJson(url)
    
    // Remove duplicates based on cleaned URLs
    const uniqueUrls = new Map<string, ProductImage>()
    rawImages.forEach(img => {
      const cleanedUrl = cleanImageUrl(img.url)
      if (!uniqueUrls.has(cleanedUrl)) {
        uniqueUrls.set(cleanedUrl, { ...img, url: cleanedUrl })
      }
    })

    const images = Array.from(uniqueUrls.values())
    
    // Extract product description
    const description = $('.product-description').first().text().trim()
    
    // Extract product specifications
    const specifications: Record<string, string> = {}
    $('.usp-content .specs li').each((_, element) => {
      const key = $(element).find('b').text().trim().replace(':', '').trim()
      let value = $(element).find('span[class^="js-"]').text().trim()
      
      if (key && value) {        
        specifications[key] = value
      }
    })

    // Extract highlights
    const highlights: Highlight[] = []
    $('.mw9.pdh.product-module-wrap.lifestyle__items').find('.lifestyle__item').each((_, element) => {
      let image = $(element).find('img').attr('src')
      const title = $(element).find('.lifestyle__title').text().trim()
      const content = $(element).find('.lifestyle__info').text().trim()

      if (image && title && content) {
        // Ensure image URL starts with https
        if (!image.startsWith('http')) {
          image = `https:${image.startsWith('//') ? image : `//${image}`}`
        }
        
        highlights.push({
          image: cleanImageUrl(image),
          title,
          content
        })
      }
    })

    return {
      name,
      subtitle,
      originalPrice,
      salePrice,
      options,
      images,
      description,
      specifications,
      variants,
      metadata: {
        highlights,
        productType
      }
    }
  } catch (error) {
    throw new Error(`Failed to crawl product page: ${error.message}`)
  }
}

// Helper to convert crawled data to API format
export async function convertToApiFormat(productData: ProductDetails): Promise<CreateProductWorkflowInputDTO> {
  if (!productData.name) {
    throw new Error('Product name/title is required')
  }

  // Get first image for thumbnail
  const thumbnail = productData.images[0]?.url

  // Generate handle from subtitle
  const handle = productData.subtitle?.toLowerCase()
    .replace(/[^a-z0-9]+/g, '-') // Replace non-alphanumeric with dash
    .replace(/^-+|-+$/g, '') // Remove leading/trailing dashes
    || productData.name.toLowerCase().replace(/[^a-z0-9]+/g, '-') // Fallback to name

  // Process variants with dimension image detection
  const variants = await Promise.all(productData.variants.map(async variant => {
    let dimensionImageUrl: string | undefined = undefined;

    // Reverse the images array and loop through
    const reversedImages = [...variant.images].reverse()
    for (const imageUrl of reversedImages) {
      const isDimension = await ollamaService.isDimensionImage(imageUrl)
      if (isDimension) {
        dimensionImageUrl = imageUrl
        break
      }
    }

    // Filter out the dimension image from the images array
    const filteredImages = dimensionImageUrl 
      ? variant.images.filter(img => img !== dimensionImageUrl)
      : variant.images

    return {
      ...variant,
      allow_backorder: true,
      manage_inventory: false,
      options: {
        Material: variant.options[0].value
      },
      images: filteredImages, // Use filtered images
      metadata: {
        ...variant.metadata,
        specifications: transformSpecs(variant.metadata.specifications),
        images: filteredImages, // Also update metadata images
        dimensionImage: dimensionImageUrl,
        normalPrice: variant.prices[0].amount
      }
    }
  }))

  // Get category information
  const categoryInfo = getCategoryFromSubtitle(productData.subtitle || '')

  return {
    title: productData.name,
    subtitle: productData.subtitle,
    description: productData.description,
    material: productData.specifications['Material'],
    handle,
    options: [{
      title: "Material",
      values: productData.options[0].values
    }],
    variants,
    images: productData.images.map(img => ({
      url: img.url
    })),
    thumbnail,
    metadata: {
      specifications: transformSpecs(productData.specifications),
      category: categoryInfo.parent,
      subcategory: categoryInfo.subcategory,
      highlights: productData.metadata.highlights,
      productType: productData.metadata.productType
    },
    status: 'published',
    shipping_profile_id: 'sp_01JM18DSFFZW6A3X2BVSRWHYAK',
    sales_channels: [{ id: "sc_01JM18DQRAB13QQK6V7535YDR1" }]
  }
}

// Add these utility functions at the top of the file
function convertInchToCm(inch: string): string {
  const inchNumber = parseFloat(inch)
  return `${Math.round(inchNumber * 2.54)}cm`
}

function convertLbsToKg(lbs: string): string {
  const lbsNumber = parseFloat(lbs)
  return `${Math.round(lbsNumber * 0.45359237)}kg`
}

function convertMeasurements(value: string): string {
  // Handle dimensions like "H11.8" x W39.4" x D23.6""
  if (value.includes('H') && value.includes('W') && value.includes('D')) {
    return value.replace(/(\d+\.?\d*)"?/g, (match) => {
      return convertInchToCm(match)
    }).replace(/\s+/g, ' ').trim()
  }
  
  // Handle simple measurements like "0.7""
  if (value.match(/^\d+\.?\d*"$/)) {
    return convertInchToCm(value.replace('"', ''))
  }
  
  // Handle measurements within text (like "0.7" marble over...")
  if (value.match(/\d+\.?\d*"/)) {
    return value.replace(/(\d+\.?\d*)"(?=\s|$)/g, (match) => {
      return convertInchToCm(match.replace('"', ''))
    })
  }
  
  // Handle dimensions like "43" x 27" x 16""
  if (value.match(/\d+\.?\d*"\s*x\s*\d+\.?\d*"\s*x\s*\d+\.?\d*"/)) {
    return value.replace(/(\d+\.?\d*)"?/g, (match) => {
      return convertInchToCm(match)
    }).replace(/\s+/g, ' ').trim()
  }
  
  // Handle measurements using "in" notation like "38.2 in x 33 in x 38.6 in"
  if (value.match(/\d+\.?\d*\s*in\b/i)) {
    return value.replace(/(\d+\.?\d*)\s*in\b/gi, (_, match) => {
      return convertInchToCm(match)
    })
  }
  
  // Handle weight in parentheses like "(300 lbs)"
  if (value.includes('lbs')) {
    return value.replace(/(\d+)\s*lbs/g, (_, lbs) => {
      return convertLbsToKg(lbs)
    })
  }
  
  return value
} 
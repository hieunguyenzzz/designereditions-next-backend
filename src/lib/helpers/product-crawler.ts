import axios from 'axios'
import * as cheerio from 'cheerio'

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
}

interface Highlight {
  image: string
  title: string
  content: string
}

function cleanImageUrl(url: string): string {
  // Remove size dimensions like _1180x, _640x etc from the URL
  return url.replace(/_([\d]+)x\./i, '.')
}

function isLargeImage(url: string): boolean {
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

async function crawlVariantPage(url: string): Promise<{
  price: number
  salePrice?: number
  images: string[]
  sku: string
  specifications: Record<string, string>
  highlights: Highlight[]
  handle: string
  swatchStyle?: string
}> {
  const response = await axios.get(url)
  const $ = cheerio.load(response.data)

  // Extract handle from URL
  const handle = url.split('/').pop()?.split('?')[0] || ''

  // Extract swatch style
  const swatchStyle = $('li.swatch.active').attr('style') || 
                     $(`a[href*="${handle}"]`).attr('style')

  // Extract prices from data-amount attributes
  const originalPrice = parseInt($('.old-price').eq(1).attr('data-amount') || '0')
  const salePrice = parseInt($('.variant-price.sale-price').attr('data-amount') || '0')
  
  // Extract images specific to this variant
  const images: string[] = []
  $('.zoom-trigger').each((_, element) => {
    const img = $(element).find('img.lg\\:block').first()
    const url = img.attr('src')
    if (url && isLargeImage(url)) {
      images.push(url)
    }
  })

  // If no images found with primary selector, try fallback
  if (images.length === 0) {
    $('img[src*="/files/"]').each((_, element) => {
      const url = $(element).attr('src')
      if (url && isLargeImage(url)) {
        images.push(url)
      }
    })
  }

  // Extract specifications for this variant
  const specifications: Record<string, string> = {}
  $('.usp-item.pdh .specs li').each((_, element) => {
    const key = $(element).find('b').text().trim().replace(':', '').trim()
    const value = $(element).find('span[class^="js-"]').text().trim()
    
    if (key && value) {
      specifications[key] = value
    }
  })

  // Extract highlights
  const highlights: Highlight[] = []
  $('.mw9.pdh.product-module-wrap.lifestyle__items').find('.lifestyle__item').each((_, element) => {
    const image = $(element).find('img').attr('src')
    const title = $(element).find('h3, .hd3').text().trim()
    const content = $(element).find('p').text().trim()

    if (image && title && content) {
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
    sku: specifications['SKU'] || '',
    specifications,
    highlights,
    handle,
    swatchStyle
  }
}

export async function crawlProductPage(url: string): Promise<ProductDetails> {
  try {
    const response = await axios.get(url)
    const $ = cheerio.load(response.data)
    
    // Extract basic product info
    const name = $('h1').first().text().trim()
    const subtitle = $('.product__subtitle').text().trim()
    
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
    
    // Crawl each variant
    const variants: ProductVariant[] = []
    for (let i = 0; i < options[0].values.length; i++) {
      const variantUrl = variantUrls[i]
      const variantValue = options[0].values[i]
      
      try {
        const variantData = await crawlVariantPage(variantUrl)
        variants.push({
          title: `${name} - ${variantValue}`,
          sku: variantData.sku,
          options: [{
            value: variantValue
          }],
          prices: [{
            amount: variantData.price,
            currency_code: 'usd'
          },
          ...(variantData.salePrice ? [{
            amount: variantData.salePrice,
            currency_code: 'usd',
            price_list_id: 'plist_01JM1YCRNA1AVA96N78YBKM2XK'
          }] : [])
        ],
          images: variantData.images,
          metadata: {
            specifications: variantData.specifications,
            dimensions: variantData.specifications['Product Dimensions'],
            material: variantData.specifications['Material'],
            weight: variantData.specifications['Product Weight'],
            assembly: variantData.specifications['Assembly Requirements'],
            materialDetails: variantData.specifications['Material Details'],
            indoorOutdoorUse: variantData.specifications['Indoor or Outdoor Use'],
            tabletopHeight: variantData.specifications['Tabletop Height'],
            tabletopThickness: variantData.specifications['Tabletop Thickness'],
            packagingDimensions: variantData.specifications['Packaging Dimensions'],
            shippingCartons: variantData.specifications['No. of Shipping Cartons'],
            highlights: variantData.highlights,
            handle: variantData.handle,
            swatchStyle: variantData.swatchStyle
          }
        })
      } catch (error) {
        throw new Error(`Failed to crawl variant ${variantValue}: ${error.message}`)
      }
    }
    
    // Extract base product images
    const rawImages: ProductImage[] = []
    $('img[src*="/files/"]')
      .not('.product-recommendations img')
      .not('.you-might-also img')
      .not('.instagram-roundel img')
      .each((_, element) => {
        const url = $(element).attr('src')
        const alt = $(element).attr('alt') || ''
        if (url && isLargeImage(url)) {
          rawImages.push({ url, alt })
        }
      })

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
    $('.usp-item.pdh.show li').each((_, element) => {
      const text = $(element).text().trim()
      const [key, ...valueParts] = text.split(':')
      const value = valueParts.join(':').trim()
      if (key && value) {
        specifications[key.trim()] = value
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
      variants
    }
  } catch (error) {
    throw new Error(`Failed to crawl product page: ${error.message}`)
  }
}

// Helper to convert crawled data to API format
export function convertToApiFormat(productData: ProductDetails) {
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

  const variants = productData.variants.map(variant => ({
    ...variant,
    options: {
      Material: variant.options[0].value
    },
    metadata: {
      ...variant.metadata,
      images: variant.images
    }
  }))

  return {
    title: productData.name,
    subtitle: productData.subtitle,
    description: productData.description,
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
      specifications: productData.specifications
    },
    status: 'published'
  }
} 
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

function cleanImageUrl(url: string): string {
  // Remove query parameters and ensure https
  const cleanUrl = url.split('?')[0].replace('http://', 'https://')
  return cleanUrl
}

async function crawlVariantPage(url: string): Promise<{
  price: number
  salePrice?: number
  images: string[]
  sku: string
  specifications: Record<string, string>
}> {
  const response = await axios.get(url)
  const $ = cheerio.load(response.data)

  // Extract prices from data-amount attributes
  const originalPrice = parseInt($('.old-price').eq(1).attr('data-amount') || '0')
  const salePrice = parseInt($('.variant-price.sale-price').attr('data-amount') || '0')
  
  // Extract images specific to this variant
  const images: string[] = []
  $('img[src*="/files/"]').each((_, element) => {
    const url = $(element).attr('src')
    if (url && !images.includes(url)) {
      images.push(cleanImageUrl(url))
    }
  })

  // Extract specifications for this variant
  const specifications: Record<string, string> = {}
  $('.usp-item.pdh .specs li').each((_, element) => {
    const key = $(element).find('b').text().trim().replace(':', '').trim()
    const value = $(element).find('span[class^="js-"]').text().trim()
    
    if (key && value) {
      specifications[key] = value
    }
  })

  return {
    price: originalPrice,
    salePrice: salePrice || undefined,
    images,
    sku: specifications['SKU'] || '',
    specifications
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
            shippingCartons: variantData.specifications['No. of Shipping Cartons']
          }
        })
      } catch (error) {
        throw new Error(`Failed to crawl variant ${variantValue}: ${error.message}`)
      }
    }
    
    // Extract base product images
    const images: ProductImage[] = []
    $('img[src*="/files/"]').each((_, element) => {
      const url = $(element).attr('src')
      const alt = $(element).attr('alt') || ''
      if (url && !images.some(img => img.url === url)) {
        images.push({ url: cleanImageUrl(url), alt })
      }
    })
    
    // Extract product description
    const description = $('.product-description').text().trim() ||
                       $('div:contains("Product Description")').next().text().trim()
    
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
  
  // Convert variants to match Medusa's format
  console.log(productData.variants[0].prices);
  console.log(productData.variants[1].prices);
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
    options: [{
      title: "Material",
      values: productData.options[0].values
    }],
    variants,
    images: productData.images.map(img => ({
      url: img.url
    })),
    metadata: {
      specifications: productData.specifications
    },
    status: 'draft'
  }
} 
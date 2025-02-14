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
    currency_code: string
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

async function crawlVariantPage(url: string): Promise<{
  price: number
  salePrice?: number
  images: string[]
  sku: string
  specifications: Record<string, string>
}> {
  const response = await axios.get(url)
  const $ = cheerio.load(response.data)

  // Extract prices for this variant using the correct selectors
  const originalPriceElement = $('.old-price')
  const salePriceElement = $('.variant-price.sale-price')
  
  // Get original price
  let originalPrice = 0
  if (originalPriceElement.length) {
    // Try to get from data-amount first (gives exact amount in cents)
    const dataAmount = originalPriceElement.attr('data-amount')
    if (dataAmount) {
      originalPrice = parseInt(dataAmount) / 100
    } else {
      // Fallback to text content
      originalPrice = parseFloat(originalPriceElement.text().replace(/[^0-9.]/g, '')) || 0
    }
  }
  
  // Get sale price
  let salePrice: number | undefined
  if (salePriceElement.length) {
    // Try to get from data-amount first (gives exact amount in cents)
    const dataAmount = salePriceElement.attr('data-amount')
    if (dataAmount) {
      salePrice = parseInt(dataAmount) / 100
    } else {
      // Fallback to text content
      salePrice = parseFloat(salePriceElement.text().replace(/[^0-9.]/g, ''))
    }
  }

  // Log price information for debugging
  console.log('Price Information:')
  console.log(`- Original Price: $${originalPrice}`)
  console.log(`- Sale Price: ${salePrice ? `$${salePrice}` : 'N/A'}`)

  // Extract images specific to this variant
  const images: string[] = []
  $('img[src*="/files/"]').each((_, element) => {
    const url = $(element).attr('src')
    if (url && !images.includes(url)) {
      images.push(url)
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

  // Log specifications for debugging
  console.log('\nExtracted Specifications:')
  Object.entries(specifications).forEach(([key, value]) => {
    console.log(`${key}: ${value}`)
  })

  return {
    price: originalPrice,
    salePrice,
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
    
    // Log subtitle for debugging
    console.log('Found subtitle:', subtitle)
    
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
    
    // Find all marble style options and their URLs using the product_button links
    $('a[name="product_button"]').each((_, element) => {
      const href = $(element).attr('href')
      // Get the marble type from the span with class whitespace-nowrap
      const value = $(element).find('span.whitespace-nowrap').text().trim()
      
      if (value && href) {
        options[0].values.push(value)
        
        // Build full URL - handle both relative and absolute URLs
        const variantUrl = href.startsWith('http') ? 
          href : 
          new URL(href, 'https://interioricons.com').href
        variantUrls.push(variantUrl)

        console.log(`Found variant: ${value} -> ${variantUrl}`)
      }
    })

    // If no variants found, try alternative selector
    if (options[0].values.length === 0) {
      console.log('No variants found with primary selector, trying alternative...')
      $('div[role="radiogroup"] a').each((_, element) => {
        const href = $(element).attr('href')
        const value = $(element).find('span:not(.visually-hidden)').text().trim()
        
        if (value && href) {
          options[0].values.push(value)
          const variantUrl = href.startsWith('http') ? 
            href : 
            new URL(href, 'https://interioricons.com').href
          variantUrls.push(variantUrl)
          
          console.log(`Found variant (alternative): ${value} -> ${variantUrl}`)
        }
      })
    }
    
    // Log found variants
    console.log('\n📦 Found variants:')
    console.log('-'.repeat(80))
    options[0].values.forEach((value, index) => {
      console.log(`${index + 1}. ${value} -> ${variantUrls[index]}`)
    })
    
    // Crawl each variant
    console.log('\n📦 Crawling variants...')
    const variants: ProductVariant[] = []
    
    for (let i = 0; i < options[0].values.length; i++) {
      const variantUrl = variantUrls[i]
      const variantValue = options[0].values[i]
      
      console.log(`\nCrawling variant ${i + 1}/${options[0].values.length}: ${variantValue}`)
      console.log(`URL: ${variantUrl}`)
      
      try {
        const variantData = await crawlVariantPage(variantUrl)
        
        variants.push({
          title: `${name} - ${variantValue}`,
          sku: variantData.sku,
          options: [{
            value: variantValue
          }],
          prices: [{
            amount: variantData.salePrice ? 
              variantData.salePrice * 100 : 
              variantData.price * 100,
            currency_code: 'usd'
          }],
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
        
        console.log(`✅ Successfully crawled variant: ${variantValue}`)
      } catch (error) {
        console.error(`❌ Failed to crawl variant: ${variantValue}`)
        console.error(`Error: ${error.message}`)
      }
    }
    
    // Extract base product images
    const images: ProductImage[] = []
    $('img[src*="/files/"]').each((_, element) => {
      const url = $(element).attr('src')
      const alt = $(element).attr('alt') || ''
      if (url && !images.some(img => img.url === url)) {
        images.push({ url, alt })
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

    // Log the extracted data for debugging
    console.log('\n🔍 Extracted Elements:')
    console.log('-'.repeat(80))
    console.log('Name:', name)
    console.log('Subtitle:', subtitle)
    console.log('Options:', JSON.stringify(options, null, 2))
    console.log('Variants Count:', variants.length)
    console.log('Images Count:', images.length)
    console.log('Description length:', description.length)
    console.log('Specifications Count:', Object.keys(specifications).length)

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
    console.error('Crawling error:', error)
    throw new Error(`Failed to crawl product page: ${error.message}`)
  }
}

// Helper to convert crawled data to API format
export function convertToApiFormat(productData: ProductDetails) {
  if (!productData.name) {
    throw new Error('Product name/title is required')
  }

  // Convert variants to match Medusa's format
  const variants = productData.variants.map(variant => ({
    title: variant.title,
    sku: variant.sku,
    options: {
      Material: variant.options[0].value // Convert array to Record<string, string>
    },
    prices: variant.prices,
    metadata: variant.metadata
  }))

  return {
    title: productData.name,
    description: productData.description,
    options: [{
      title: "Material",
      values: productData.options[0].values
    }],
    variants,
    metadata: {
      subtitle: productData.subtitle,
      specifications: productData.specifications
    },
    status: 'draft'
  }
} 
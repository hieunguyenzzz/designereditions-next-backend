import { 
  MedusaRequest, 
  MedusaResponse 
} from "@medusajs/framework/http"
import { createProduct } from "../../../lib/helpers/product-creator"
import { crawlProductPage, convertToApiFormat } from "../../../lib/helpers/product-crawler"
import { z } from "zod"
import axios from 'axios'
import { Modules } from "@medusajs/framework/utils"

// Function to extract handle from URL
function extractHandleFromUrl(url: string): string {
  const urlParts = url.split('/products/')
  return urlParts.length > 1 ? urlParts[1].split('?')[0] : ''
}

// Update the validation schema to handle URL encoding
const CreateProductSchema = z.object({
  productUrl: z.string().url().optional(),
  sitemapUrl: z.string().transform(url => {
    // Decode URL if it's encoded
    try {
      return decodeURIComponent(url)
    } catch {
      return url
    }
  }).optional(),
  title: z.string().min(1).optional(),
  description: z.string().optional(),
  colors: z.array(z.string()).optional(),
  sizes: z.array(z.string()).optional()
}).refine(data => data.productUrl || data.sitemapUrl, {
  message: "Either productUrl or sitemapUrl must be provided"
});

async function extractProductUrlsFromSitemap(sitemapUrl: string): Promise<string[]> {
  try {
    const { data: xmlString } = await axios.get(sitemapUrl)
    
    // Regex to match URLs between <loc> tags that contain '/products/'
    const productUrlRegex = /<loc>([^<]+\/products\/[^<]+)<\/loc>/g
    const matches = [...xmlString.matchAll(productUrlRegex)]
    
    // Extract the URLs from the matches (group 1 of each match)
    const productUrls = matches.map(match => match[1])
    
    console.log(`Found ${productUrls.length} product URLs in sitemap`)
    return productUrls
  } catch (error) {
    console.error('Error fetching or parsing sitemap:', error)
    throw new Error('Failed to parse sitemap')
  }
}

export const POST = async (
  req: MedusaRequest,
  res: MedusaResponse
) => {
  try {
    const validatedBody = CreateProductSchema.parse(req.body)
    const createdProducts: any[] = []


    const productService = req.scope.resolve(Modules.PRODUCT)

    if (validatedBody.sitemapUrl) {
      
      const productUrls = await extractProductUrlsFromSitemap(validatedBody.sitemapUrl)
      console.log(`\n📋 Found ${productUrls.length} product URLs`)

      // Process products one by one
      for (const url of productUrls) {
        try {
          // Extract handle and check if product exists
          const handle = extractHandleFromUrl(url)
          const [existingVariants, count] = await productService.listAndCountProductVariants({
            q: handle
          })

          // Skip if product already exists
          if (count > 0) {
            console.log(`\n⏩ Skipping existing product: ${url}`)
            continue
          }

          const [existingProducts] = await productService.listAndCountProducts({
            q: handle
          })

          if (existingProducts.length > 0) {
            console.log(`\n⏩ Skipping existing product: ${url}`)
            continue
          }

          console.log(`\n🌐 Crawling URL (${productUrls.indexOf(url) + 1}/${productUrls.length}):`, url)
          const crawledData = await crawlProductPage(url)
          const productData = await convertToApiFormat(crawledData)
          const product = await createProduct(req.scope, productData)
          
          if (product) {
            createdProducts.push(product)
          }
        } catch (error) {
          console.error(`\n❌ Error processing ${url}:`, error.message)
        }
      }

      res.status(201).json({ 
        products: createdProducts,
        total: createdProducts.length
      })
    } else if (validatedBody.productUrl) {
      
      
      // Extract handle and check if product exists
      const handle = extractHandleFromUrl(validatedBody.productUrl)
      const [existingVariants, count] = await productService.listAndCountProductVariants({
        q: handle
      })

      // Skip if product already exists
      if (count > 0) {
        return res.status(200).json({ 
          message: 'Product already exists',
          handle: handle 
        })
      }
      console.log('\n🌐 Crawling single URL:', validatedBody.productUrl)
      
      const crawledData = await crawlProductPage(validatedBody.productUrl)
      const productData = await convertToApiFormat(crawledData)
      const product = await createProduct(req.scope, productData)
      res.status(201).json({ product })
    }
  } catch (error) {
    console.error('\n❌ Error:', error.message)
    res.status(500).json({
      message: "An error occurred while creating the product(s)",
      error: error.message
    })
  }
} 
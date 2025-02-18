import { 
  MedusaRequest, 
  MedusaResponse 
} from "@medusajs/framework/http"
import { createProduct } from "../../../lib/helpers/product-creator"
import { crawlProductPage, convertToApiFormat } from "../../../lib/helpers/product-crawler"
import { z } from "zod"
import axios from 'axios'
import type { Product } from "@medusajs/medusa"
import util from "util"

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
    const createdProducts: Product[] = []

    if (validatedBody.sitemapUrl) {
      console.log('\n🗺️ Processing sitemap:', validatedBody.sitemapUrl)
      
      const productUrls = await extractProductUrlsFromSitemap(validatedBody.sitemapUrl)
      console.log(`\n📋 Found ${productUrls.length} product URLs`)

      // Process products in batches to avoid overwhelming the server
      const batchSize = 5
      for (let i = 0; i < productUrls.length; i += batchSize) {
        const batch = productUrls.slice(i, i + batchSize)
        const batchPromises = batch.map(async (url) => {
          try {
            console.log(`\n🌐 Crawling URL (${i + 1}/${productUrls.length}):`, url)
            const crawledData = await crawlProductPage(url)
            const productData = convertToApiFormat(crawledData)
            const product = await createProduct(req.scope, productData)
            return product
          } catch (error) {
            console.error(`\n❌ Error processing ${url}:`, error.message)
            return null
          }
        })

        const batchResults = await Promise.all(batchPromises)
        createdProducts.push(...batchResults.filter(p => p !== null))
      }

      res.status(201).json({ 
        products: createdProducts,
        total: createdProducts.length
      })
    } else if (validatedBody.productUrl) {
      console.log('\n🌐 Crawling single URL:', validatedBody.productUrl)
      
      const crawledData = await crawlProductPage(validatedBody.productUrl)
      const productData = convertToApiFormat(crawledData)
      console.log(util.inspect(productData, { depth: null, colors: true }));
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
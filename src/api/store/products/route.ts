import { 
  MedusaRequest, 
  MedusaResponse 
} from "@medusajs/framework/http"
import { createProduct } from "../../../lib/helpers/product-creator"
import { crawlProductPage, convertToApiFormat } from "../../../lib/helpers/product-crawler"
import { z } from "zod"


// Validation schema
const CreateProductSchema = z.object({
  productUrl: z.string().url(),
  // Keep other fields optional as they'll come from crawler
  title: z.string().min(1).optional(),
  description: z.string().optional(),
  colors: z.array(z.string()).optional(),
  sizes: z.array(z.string()).optional()
})

export const POST = async (
  req: MedusaRequest,
  res: MedusaResponse
) => {
  try {
    const validatedBody = CreateProductSchema.parse(req.body)

    if (validatedBody.productUrl) {
      console.log('\n🌐 Crawling URL:', validatedBody.productUrl)
      
      const crawledData = await crawlProductPage(validatedBody.productUrl)
      const productData = convertToApiFormat(crawledData)
      
      const product = await createProduct(req.scope, productData)
      res.status(201).json({ product })
    } else {
      res.status(400).json({
        message: "Product URL is required"
      })
    }
  } catch (error) {
    console.error('\n❌ Error:', error.message)
    res.status(500).json({
      message: "An error occurred while creating the product",
      error: error.message
    })
  }
} 
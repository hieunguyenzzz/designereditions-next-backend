import { 
  MedusaRequest, 
  MedusaResponse 
} from "@medusajs/framework/http"
import { createProduct } from "../../../lib/helpers/product-creator"
import { z } from "zod"

// Validation schema
const CreateProductSchema = z.object({
  title: z.string().min(1),
  description: z.string().optional(),
  colors: z.array(z.string()).optional(),
  sizes: z.array(z.string()).optional()
})

export const POST = async (
  req: MedusaRequest,
  res: MedusaResponse
) => {
  try {
    // Validate request body
    const validatedBody = CreateProductSchema.parse(req.body)

    // Create product using helper
    const product = await createProduct(req.scope, validatedBody)

    res.status(201).json({ product })
  } catch (error) {
    if (error instanceof z.ZodError) {
      res.status(400).json({
        message: "Invalid request body",
        errors: error.errors
      })
      return
    }

    res.status(500).json({
      message: "An error occurred while creating the product"
    })
  }
} 
import { MedusaContainer } from "@medusajs/framework/types"
import { createProductsWorkflow } from "@medusajs/medusa/core-flows"
import { CreateProductWorkflowInputDTO } from "@medusajs/framework/types"

export type ProductOption = {
  title: string
  values: string[]
}

export type ProductPrice = {
  amount: number
  currency_code: string
  price_list_id?: string
}

export type CreateProductInput = {
  title: string
  subtitle?: string
  description?: string
  options: ProductOption[]
  variants?: {
    title: string
    sku?: string
    options: Record<string, string>
    prices: ProductPrice[]
    metadata?: Record<string, any>
  }[]
  images?: { url: string }[]
  thumbnail?: string
  metadata?: Record<string, any>
  status?: "draft" | "proposed" | "published" | "rejected"
}

export async function createProduct(
  container: MedusaContainer,
  input: CreateProductWorkflowInputDTO
) {
  

  const productData: CreateProductWorkflowInputDTO = {
    ...input,
    // Required by Medusa core
    shipping_profile_id: "sp_01JM18DSFFZW6A3X2BVSRWHYAK"
  }

  // Create product using workflow
  const { result: products } = await createProductsWorkflow(container).run({
    input: {
      products: [productData]
    }
  })

  return products[0]
} 
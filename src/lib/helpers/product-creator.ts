import { MedusaContainer } from "@medusajs/framework/types"
import { createProductsWorkflow } from "@medusajs/medusa/core-flows"
import { CreateProductWorkflowInputDTO } from "@medusajs/framework/types"
import { Modules } from "@medusajs/framework/utils"

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
  // Check for existing variants with same handles
  const productService = container.resolve(Modules.PRODUCT)
  
  for (const variant of input.variants) {
    const variantHandle = variant.metadata?.handle
    if (variantHandle) {
      const [existingVariants] = await productService.listAndCountProductVariants({
        metadata: {
          handle: variantHandle
        }
      })
      
      if (existingVariants.length > 0) {
        throw new Error(`Product variant with handle "${variantHandle}" already exists`)
      }
    }
  }

  const productData: CreateProductWorkflowInputDTO = {
    ...input,
    shipping_profile_id: "sp_01JM18DSFFZW6A3X2BVSRWHYAK"
  }

  const { result: products } = await createProductsWorkflow(container).run({
    input: {
      products: [productData]
    }
  })

  return products[0]
} 
import { MedusaContainer } from "@medusajs/framework/types"
import { createProductsWorkflow } from "@medusajs/medusa/core-flows"
import { CreateProductWorkflowInputDTO } from "@medusajs/framework/types"
import { Modules } from "@medusajs/framework/utils"

export async function createProduct(
  container: MedusaContainer,
  input: CreateProductWorkflowInputDTO
) {
  // Check for existing variants with same handles
  const productService = container.resolve(Modules.PRODUCT)
  
  if (input.variants) {
    for (const variant of input.variants) {
      const variantHandle = variant.metadata?.handle
      if (variantHandle) {
        // Search by SKU instead since we can't filter by metadata
        const [existingVariants] = await productService.listAndCountProductVariants({
          q: variant.sku
        })
        
        if (existingVariants.length > 0) {
          throw new Error(`Product variant with handle "${variantHandle}" already exists`)
        }
      }
    }
  }
  
  const { result: products } = await createProductsWorkflow(container).run({
    input: {
      products: [input]
    }
  })

  return products[0]
} 
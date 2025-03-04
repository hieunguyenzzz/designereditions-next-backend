import { MedusaContainer } from "@medusajs/framework/types"
import { createProductsWorkflow, createPriceListsWorkflow } from "@medusajs/medusa/core-flows"

import { CreateProductWorkflowInputDTO, CreatePriceListWorkflowInputDTO } from "@medusajs/framework/types"
import { Modules } from "@medusajs/framework/utils"

export async function createProduct(
  container: MedusaContainer,
  input: CreateProductWorkflowInputDTO
) {
  const productService = container.resolve(Modules.PRODUCT)
  const pricingModuleService = container.resolve(Modules.PRICING)
  // Check for existing SKUs
  if (input.variants) {
    for (const variant of input.variants) {
      if (variant.sku) {
        const [existingVariants, count] = await productService.listAndCountProductVariants({
          q: variant.sku
        })
        
        if (existingVariants.length > 0) {
          console.log(`Product with SKU ${variant.sku} already exists, skipping...`)
          return existingVariants[0].product
        }
      }
    }
  }

  // Step 1: Create the product
  const { result: products } = await createProductsWorkflow(container).run({
    input: {
      products: [input]
    }
  })

  const product = products[0]
  

  return product
} 
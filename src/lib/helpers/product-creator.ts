import { MedusaContainer } from "@medusajs/framework/types"
import { createProductsWorkflow, createPriceListsWorkflow } from "@medusajs/medusa/core-flows"

import { CreateProductWorkflowInputDTO, CreatePriceListWorkflowInputDTO } from "@medusajs/framework/types"
import { Modules } from "@medusajs/framework/utils"
import type { 
  ProductVariant, 
  PriceList 
} from "@medusajs/medusa/dist/models"

export async function createProduct(
  container: MedusaContainer,
  input: CreateProductWorkflowInputDTO
) {
  const productService = container.resolve(Modules.PRODUCT)
  
  // Check for existing SKUs
  if (input.variants) {
    for (const variant of input.variants) {
      if (variant.sku) {
        const [existingVariants] = await productService.listAndCountProductVariants({
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

  // Step 2: Create price rules for variants with sale prices
  const variantsWithSalePrices = (input.variants || []).filter(variant => 
    variant.prices?.some(price => price.price_list_id)
  )

  console.log('Variants with sale prices:', JSON.stringify(variantsWithSalePrices, null, 2))

  if (variantsWithSalePrices.length > 0) {
    const priceListPrices = variantsWithSalePrices.flatMap(inputVariant => {
      console.log('Processing variant:', inputVariant.sku)
      console.log('Variant prices:', JSON.stringify(inputVariant.prices, null, 2))
      
      const createdVariant = product.variants.find(v => v.sku === inputVariant.sku)
      if (!createdVariant) {
        console.log('No matching created variant found for SKU:', inputVariant.sku)
        return []
      }

      const salePrices = (inputVariant.prices || [])
        .filter(price => price.price_list_id)
        .map(price => ({
          variant_id: createdVariant.id,
          amount: Number(price.amount),
          currency_code: price.currency_code
        }))

      console.log('Sale prices for variant:', JSON.stringify(salePrices, null, 2))
      return salePrices
    })

    if (priceListPrices.length > 0) {
      try {
        await createPriceListsWorkflow(container).run({
          input: {
            price_lists_data: [{
              title: `${product.title} Sale Prices`,
              description: `Sale prices for ${product.title}`,
              status: "active",
              prices: priceListPrices.map(price => ({
                variant_id: price.variant_id,
                amount: Number(price.amount),
                currency_code: price.currency_code
              }))
            }]
          }
        })
      } catch (error) {
        console.error('Error creating price list:', error)
        console.log('Price list data:', {
          name: `${product.title} Sale Prices`,
          prices: priceListPrices
        })
      }
    }
  }

  return product
} 
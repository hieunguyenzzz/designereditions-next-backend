import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { Modules } from "@medusajs/framework/utils"
import { createPriceListsWorkflow } from "@medusajs/medusa/core-flows"

export const POST = async (
  req: MedusaRequest,
  res: MedusaResponse
) => {
  try {
    const productService = req.scope.resolve(Modules.PRODUCT)
    const pricingModuleService = req.scope.resolve(Modules.PRICING)

    // Fetch all products with variants
    const [products] = await productService.listAndCount({
      relations: ['variants']
    })

    // Collect variants with sale prices from metadata
    const priceListPrices: Array<{
      variant_id: string
      amount: number
      currency_code: string
    }> = []

    for (const product of products) {
      for (const variant of product.variants) {
        // Check if variant has a sale price in metadata
        const salePrice = variant.metadata?.salePrice
        if (salePrice) {
          priceListPrices.push({
            variant_id: variant.id,
            amount: Number(salePrice),
            currency_code: 'usd'
          })
        }
      }
    }

    // Create price lists if there are sale prices
    if (priceListPrices.length > 0) {
      await createPriceListsWorkflow(req.scope).run({
        input: {
          price_lists_data: [{
            title: 'Site-wide Sale Prices',
            description: 'Automated sale prices for all variants',
            status: 'active',
            starts_at: new Date().toISOString(),
            ends_at: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString(), // 1 year from now
            prices: priceListPrices
          }]
        }
      })

      return res.status(201).json({
        message: 'Price lists created successfully',
        total_variants_with_sale_price: priceListPrices.length
      })
    } else {
      return res.status(200).json({
        message: 'No sale prices found',
        total_variants_with_sale_price: 0
      })
    }
  } catch (error) {
    console.error('Error creating price lists:', error)
    return res.status(500).json({
      message: 'Failed to create price lists',
      error: error.message
    })
  }
} 
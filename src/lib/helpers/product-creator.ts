import { MedusaContainer } from "@medusajs/framework/types"
import { 
  createProductsWorkflow 
} from "@medusajs/medusa/core-flows"

import { CreateProductWorkflowInputDTO } from "@medusajs/framework/types";

export type ProductOption = {
  title: string
  values: string[]
}

export type ProductVariant = {
  title: string
  options: Record<string, string>
  prices: {
    amount: number
    currency_code: string
  }[]
  inventory_quantity?: number
}

export type CreateProductInput = {
  title: string
  description?: string
  options: ProductOption[]
  variants?: ProductVariant[]
  status?: string
  metadata?: Record<string, any>
}

export async function createProduct(
  container: MedusaContainer,
  input: CreateProductInput
) {
  const { 
    title, 
    description, 
    options = [], 
    variants = [],
    status = "published",
    metadata = {}
  } = input

  // Create product data
  const productData: CreateProductWorkflowInputDTO = {
    title,
    description: description || `Description for ${title}`,
    status,
    metadata,
    shipping_profile_id: "sp_01JM18DSFFZW6A3X2BVSRWHYAK",
    options,
    variants: variants.length > 0 ? variants : generateDefaultVariants(title, options)
  }

  // Create the product using workflow
  const { result: products } = await createProductsWorkflow(container).run({
    input: {
      products: [productData]
    }
  })

  return products[0]
}

function generateDefaultVariants(
  title: string, 
  options: ProductOption[]
): ProductVariant[] {
  if (options.length === 0) {
    return [{
      title,
      options: {},
      prices: [{
        amount: 1000,
        currency_code: "usd"
      }],
      inventory_quantity: 100
    }]
  }

  // Generate all possible combinations of option values
  const combinations = options.reduce<Record<string, string>[]>(
    (acc, option) => {
      if (acc.length === 0) {
        return option.values.map(value => ({ [option.title]: value }))
      }
      return acc.flatMap(combo => 
        option.values.map(value => ({
          ...combo,
          [option.title]: value
        }))
      )
    }, 
    []
  )

  // Create variants from combinations
  return combinations.map(combo => ({
    title: `${title} - ${Object.values(combo).join(' ')}`,
    options: combo,
    prices: [{
      amount: 1000,
      currency_code: "usd"
    }],
    inventory_quantity: 100
  }))
} 
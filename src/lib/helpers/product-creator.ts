import { 
  ProductStatus,
  ProductVariant 
} from "@medusajs/medusa"
import { MedusaContainer } from "@medusajs/framework/types"
import { 
  createProductsWorkflow 
} from "@medusajs/medusa/core-flows"

export type CreateProductInput = {
  title: string
  description?: string
  colors?: string[]
  sizes?: string[]
}

export async function createProduct(
  container: MedusaContainer,
  input: CreateProductInput
) {
  const { title, description, colors = ["Black", "White"], sizes = ["S", "M", "L", "XL"] } = input

  // Create product data
  const productData = {
    title,
    description: description || `Description for ${title}`,
    status: ProductStatus.PUBLISHED,
    options: [
      {
        title: "Color",
        values: colors,
      },
      {
        title: "Size", 
        values: sizes,
      }
    ],
    // Generate variants for each color/size combination
    variants: colors.flatMap(color =>
      sizes.map(size => ({
        title: `${title} - ${color} ${size}`,
        options: {
          Color: color,
          Size: size
        },
        prices: [{
          amount: 1000, // $10.00
          currency_code: "usd"
        }],
        inventory_quantity: 100
      }))
    )
  }

  // Create the product using workflow
  const { result: products } = await createProductsWorkflow(container).run({
    input: {
      products: [productData]
    }
  })

  return products[0]
} 
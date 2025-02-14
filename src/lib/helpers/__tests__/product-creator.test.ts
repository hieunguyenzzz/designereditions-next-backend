import { createProduct } from "../product-creator"
import { MedusaContainer } from "@medusajs/framework/types"


// Mock the createProductsWorkflow
jest.mock("@medusajs/medusa/core-flows", () => ({
  createProductsWorkflow: jest.fn().mockImplementation(() => ({
    run: jest.fn().mockImplementation(({ input }) => ({
      result: [
        {
          id: "test_product_id",
          ...input.products[0]
        }
      ]
    }))
  }))
}))

describe("Product Creator Helper", () => {
  let container: MedusaContainer
  let productService: any
  let createdProductId: string | null = null

  beforeAll(() => {
    container = global.container as MedusaContainer
    productService = container.resolve("productService")
  })

  afterEach(async () => {
    // Clean up: delete the product if it was created
    if (createdProductId) {
      await productService.delete(createdProductId)
      createdProductId = null
    }
  })

  it("should create a product with default options", async () => {
    const input = {
      title: "Test Product",
      description: "Test Description"
    }

    const product = await createProduct(container, input)
    createdProductId = product.id

    expect(product).toMatchObject({
      title: "Test Product",
      description: "Test Description",
      status: "published",
      options: [
        {
          title: "Color",
          values: ["Black", "White"]
        },
        {
          title: "Size",
          values: ["S", "M", "L", "XL"]
        }
      ]
    })

    // Should create 8 variants (2 colors * 4 sizes)
    expect(product.variants.length).toBe(8)

    // Verify product exists in database
    const foundProduct = await productService.retrieve(product.id, {
      relations: ["variants", "options"]
    })
    expect(foundProduct).toBeTruthy()
  })

  it("should create a product with custom colors and sizes", async () => {
    const input = {
      title: "Custom Product",
      colors: ["Red", "Blue"],
      sizes: ["Small", "Large"]
    }

    const product = await createProduct(container, input)
    createdProductId = product.id

    expect(product.options[0].values).toEqual(["Red", "Blue"])
    expect(product.options[1].values).toEqual(["Small", "Large"])
    
    // Should create 4 variants (2 colors * 2 sizes)
    expect(product.variants.length).toBe(4)

    // Verify variants in database
    const foundProduct = await productService.retrieve(product.id, {
      relations: ["variants", "options"]
    })
    expect(foundProduct.variants.length).toBe(4)
  })
}) 
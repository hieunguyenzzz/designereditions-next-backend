import { createProduct } from "../product-creator"

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
  const mockContainer = {
    // Add any required container dependencies
  } as any

  it("should create a product with default options", async () => {
    const input = {
      title: "Test Product",
      description: "Test Description"
    }

    const product = await createProduct(mockContainer, input)

    expect(product).toMatchObject({
      id: "test_product_id",
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
  })

  it("should create a product with custom colors and sizes", async () => {
    const input = {
      title: "Custom Product",
      colors: ["Red", "Blue"],
      sizes: ["Small", "Large"]
    }

    const product = await createProduct(mockContainer, input)

    expect(product.options[0].values).toEqual(["Red", "Blue"])
    expect(product.options[1].values).toEqual(["Small", "Large"])
    
    // Should create 4 variants (2 colors * 2 sizes)
    expect(product.variants.length).toBe(4)
  })
}) 
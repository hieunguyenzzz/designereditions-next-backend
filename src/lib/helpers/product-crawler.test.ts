import { crawlProductPage } from './product-crawler'

describe('crawlProductPage', () => {
  // Increase timeout since we're making real HTTP requests
  jest.setTimeout(30000)

  it('should correctly crawl the Plinth coffee table product page', async () => {
    return // temporary disabled
    const url = 'https://interioricons.com/products/plinth-coffee-table-kunis-breccia'
    const result = await crawlProductPage(url)

    // Test basic product information
    expect(result.name).toBe('Plinth')
    // If subtitle contains measurements, expect them to be in cm
    expect(result.subtitle).toMatch(/Coffee Table/)
    if (result.subtitle?.includes('"')) {
      expect(result.subtitle).toMatch(/\d+cm/)
    } else {
      expect(result.subtitle).toBe('Plinth Coffee Table Marble')
    }
    
    // Test variants pricing instead of originalPrice
    expect(result.variants[0].prices[0].amount).toBeGreaterThan(1000)
    
    // Test product options
    expect(result.options).toHaveLength(1)
    expect(result.options[0].name).toBe('Material')
    expect(result.options[0].values).toEqual(
      expect.arrayContaining([
        'Kunis Breccia',
        'Modellato Marble',
        'White Marble',
        'Rosso Levanto Marble',
        'Rojo Alicante'
      ])
    )

    // Test product images
    expect(result.images).toBeInstanceOf(Array)
    expect(result.images.length).toBeGreaterThan(0)
    result.images.forEach(image => {
      expect(image).toMatchObject({
        url: expect.stringMatching(/^https:\/\//),
        alt: expect.any(String)
      })
      // Verify no URL parameters or size dimensions
      expect(image.url).not.toContain('?')
      expect(image.url).not.toMatch(/_[\d]+x\./)
      expect(image.url).not.toContain('lifestyle')
    })

    // Test product description
    expect(result.description).toContain('Designed with an intentionally modest silhouette')
    
    

    /**
     * TODO: Add test for specifications
     */
    // Test specifications
    const expectedSpecs = {
      'Product Dimensions': 'H30cm x W100cm x D60cm',
      'Tabletop Height': '30cm',
      'Material': 'Modellato Marble',
      'Assembly Requirements': 'None required',
      'Indoor or Outdoor Use': 'Suitable for both indoor and outdoor use',
      'Material Details': 'Marble is sealed, making it weather resistant and suitable for outdoor use',
      'Tabletop Thickness': '2cm marble over concrete composite core',
      'Product Weight': '136kg',
      'Packaging Dimensions': '109cm x 69cm x 41cm (136kg)',
    }

    // Test that each specification exists and matches expected format
    Object.entries(expectedSpecs).forEach(([key, _]) => {
      expect(result.specifications).toHaveProperty(key)
      if (key === 'Product Dimensions') {
        expect(result.specifications[key]).toMatch(/H\d+cm x W\d+cm x D\d+cm/)
      } else if (key === 'Tabletop Height') {
        expect(result.specifications[key]).toMatch(/\d+cm/)
      } else if (key === 'Tabletop Thickness') {
        expect(result.specifications[key]).toMatch(/\d+cm marble over/)
      } else if (key === 'Product Weight') {
        expect(result.specifications[key]).toMatch(/\d+kg/)
      } else if (key === 'Packaging Dimensions') {
        expect(result.specifications[key]).toMatch(/\d+cm x \d+cm x \d+cm \(\d+kg\)/)
      }
    })

    // Test variants
    expect(result.variants).toBeInstanceOf(Array)
    expect(result.variants.length).toBeGreaterThan(0)
    
    // Test first variant (Kunis Breccia)
    const firstVariant = result.variants[0]
    expect(firstVariant).toMatchObject({
      title: expect.stringContaining('Plinth'),
      prices: expect.arrayContaining([
        expect.objectContaining({
          amount: 233200,
          currency_code: 'usd'
        })
      ]),
      options: expect.arrayContaining([
        expect.objectContaining({
          value: 'Modellato Marble'
        })
      ]),
      metadata: expect.objectContaining({
        specifications: expect.any(Object),
        handle: expect.stringMatching(/plinth-.*/)
      })
    })

    // Test variant images
    firstVariant.images.forEach(imageUrl => {
      expect(imageUrl).toMatch(/^https:\/\//)
      expect(imageUrl).not.toContain('lifestyle')
    })
  })

  it('should correctly crawl a product without variants (Rocker Chair)', async () => {
    const url = 'https://interioricons.com/products/rocker-chair-white'
    const result = await crawlProductPage(url)

    // Test basic product information
    expect(result.name).toBe('Rocker')
    expect(result.subtitle).toBe('Rocker Chair, White')
    
    // Test pricing
    expect(result.variants[0].prices).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          amount: 26500,
          currency_code: 'usd'
        }),
        expect.objectContaining({
          amount: 15900,
          currency_code: 'usd',
          price_list_id: expect.any(String)
        })
      ])
    )
    
    // Test product options (should be empty or minimal)
    expect(result.options).toHaveLength(1)
    expect(result.options[0].name).toBe('Material')
    expect(result.options[0].values).toHaveLength(1)

    // Test product images
    expect(result.images).toBeInstanceOf(Array)
    expect(result.images.length).toBeGreaterThan(0)
    result.images.forEach(image => {
      expect(image).toMatchObject({
        url: expect.stringMatching(/^https:\/\//),
        alt: expect.any(String)
      })
    })

    // Test specifications with converted measurements
    const expectedSpecs = {
      'Product Dimensions': 'H67cm x W64cm x D69cm',
      'Material': 'Polypropylene',
      'Assembly Requirements': expect.any(String),
      'Indoor or Outdoor Use': expect.stringContaining('indoors'),
      'Base Material': 'FSC certified FAS grade beech wood',
      'Seat Height': '42cm',
      'Weight Limit': '100kg',
      'Product Weight': '6kg',
      'Tools & Fixings Included': 'Yes',
      'Packaging Dimensions': '71cm x 64cm x 42cm (7kg)',
      'No. of Shipping Cartons': '1',
      'SKU': '1062'
    }

    // Test that each specification exists and matches expected format
    Object.entries(expectedSpecs).forEach(([key, expectedValue]) => {
      expect(result.specifications).toHaveProperty(key)
      if (typeof expectedValue === 'string') {
        if (key === 'Product Dimensions') {
          expect(result.specifications[key]).toMatch(/H\d+cm x W\d+cm x D\d+cm/)
        } else if (key === 'Seat Height') {
          expect(result.specifications[key]).toMatch(/\d+cm/)
        } else if (key === 'Product Weight') {
          expect(result.specifications[key]).toMatch(/\d+kg/)
        } else if (key === 'Weight Limit') {
          expect(result.specifications[key]).toMatch(/\d+kg/)
        } else if (key === 'Packaging Dimensions') {
          expect(result.specifications[key]).toMatch(/\d+cm x \d+cm x \d+cm \(\d+kg\)/)
        }
      }
    })

    // Test single variant
    // expect(result.variants).toHaveLength(1)
    // const variant = result.variants[0]
    // expect(variant).toMatchObject({
    //   title: 'Rocker - White',
    //   sku: '1062',
    //   options: [{
    //     value: 'White'
    //   }],
    //   metadata: expect.objectContaining({
    //     specifications: expect.any(Object),
    //     dimensions: expect.stringMatching(/H\d+cm x W\d+cm x D\d+cm/),
    //     material: 'Polypropylene',
    //     weight: expect.stringMatching(/\d+kg/),
    //     assembly: expect.any(String),
    //     handle: 'rocker-chair-white'
    //   })
    // })

    // Test variant images
    // variant.images.forEach(imageUrl => {
    //   expect(imageUrl).toMatch(/^https:\/\//)
    //   expect(imageUrl).not.toContain('lifestyle')
    // })
  })

  it('should handle errors gracefully', async () => {
    const invalidUrl = 'https://interioricons.com/products/nonexistent-product'
    
    await expect(crawlProductPage(invalidUrl))
      .rejects
      .toThrow('Failed to crawl product page')
  })
}) 
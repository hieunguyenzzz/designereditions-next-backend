export async function createShopifyProduct(session: Session, product: any) {
  try {
    const client = new shopify.clients.Graphql({ session });
    
    const response = await client.query({
      data: {
        query: `
          mutation productCreate($input: ProductInput!) {
            productCreate(input: $input) {
              product {
                id
                title
                handle
              }
              userErrors {
                field
                message
              }
            }
          }
        `,
        variables: {
          input: product
        },
      },
    });

    const result = response.body.data.productCreate;
    
    if (result.userErrors && result.userErrors.length > 0) {
      // Format user errors into a string
      const errorMessages = result.userErrors.map(err => 
        `${err.field}: ${err.message}`
      ).join(', ');
      throw new Error(`Shopify API Error: ${errorMessages}`);
    }

    return result.product;
  } catch (error) {
    // Handle network/other errors
    const message = error instanceof Error ? error.message : 'Unknown error occurred';
    throw new Error(`Error creating Shopify product: ${message}`);
  }
} 
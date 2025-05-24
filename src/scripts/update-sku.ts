import { 
  ExecArgs,
} from "@medusajs/framework/types"
import { Modules } from "@medusajs/framework/utils"
import { updateProductsWorkflow } from "@medusajs/medusa/core-flows"

export default async function updateSku({
  container
}: ExecArgs) {
  const logger = container.resolve("logger")
  const productService = container.resolve(Modules.PRODUCT)
  
  try {
    logger.info("Starting SKU metadata update process...")
    
    // Fetch all product variants
    const [variants, count] = await productService.listAndCountProductVariants({})
    
    logger.info(`Found ${count} variants to process`)
    
    let updatedCount = 0
    let skippedCount = 0
    let errorCount = 0
    
    // Process each variant
    for (const variant of variants) {
      try {
        
        // Check if specifications exist in metadata
        const specs = variant.metadata?.specifications as Record<string, string> | undefined
        if (!specs || !('SKU' in specs)) {
          logger.info(`Variant ${variant.title} (id: ${variant.id}) has no SKU in specifications`)
          skippedCount++
          continue
        }
        
        const skuFromSpecs = specs.SKU
        
        
        // Update the variant using updateProductsWorkflow
        const productId = variant.product_id
        
        if (!productId) {
          logger.error(`Variant ${variant.title} has no associated product_id, skipping update`)
          errorCount++
          continue
        }
        
        await productService.updateProductVariants(
          variant.id,
          {
            sku: skuFromSpecs
          }
        )
        
        updatedCount++
        logger.info(`Updated variant ${variant.title} (id: ${variant.id}) with SKU metadata: ${skuFromSpecs}`)
      } catch (error) {
        logger.error(`Error processing variant ${variant.title} (id: ${variant.id}): ${error.message}`)
        errorCount++
      }
    }
    
    // Print summary
    console.log("----------- SUMMARY -----------")
    console.log(`Total variants processed: ${count}`)
    console.log(`Updated with SKU metadata: ${updatedCount}`)
    console.log(`Skipped (already had SKU or no specifications): ${skippedCount}`)
    console.log(`Errors: ${errorCount}`)
    
  } catch (error) {
    logger.error(`Error in SKU update process: ${error.message}`)
  }
} 
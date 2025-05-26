import { 
  ExecArgs,
} from "@medusajs/framework/types"
import * as fs from "fs"
import * as path from "path"
import { Modules } from "@medusajs/framework/utils"

export default async function exportVariants({
  container
}: ExecArgs) {
  const logger = container.resolve("logger")
  const productService = container.resolve(Modules.PRODUCT)
  
  try {
    logger.info("Starting variant export process...")
    
    // Fetch all product variants
    const [variants, count] = await productService.listAndCountProductVariants({})
    
    logger.info(`Found ${count} variants to export`)
    
    // Prepare CSV data
    const csvRows: string[][] = []
    
    // CSV header - added Images column
    csvRows.push(['SKU', 'Title', 'Product ID', 'Variant ID', 'Specifications', 'Images'])
    
    // Process each variant
    for (const variant of variants) {
      try {
        const sku = variant.sku || 'N/A'
        const title = variant.title || 'N/A'
        const productId = variant.product_id || 'N/A'
        const variantId = variant.id || 'N/A'
        
        // Get specifications from metadata
        const specs = variant.metadata?.specifications as Record<string, string> | undefined
        
        let specificationsString = 'N/A'
        if (specs && typeof specs === 'object') {
          // Convert specifications object to readable string format - each spec on its own line
          const specEntries = Object.entries(specs).map(([key, value]) => `${key}: ${value}`)
          specificationsString = specEntries.join('\n')
        }
        
        // Get images from metadata
        const images = variant.metadata?.images as string[] | undefined
        
        let imagesString = 'N/A'
        if (images && Array.isArray(images) && images.length > 0) {
          // Format images line by line for readability
          imagesString = images.join('\n')
        }
        
        // Add row to CSV data - included images column
        csvRows.push([sku, title, productId, variantId, specificationsString, imagesString])
        
        logger.info(`Processed variant: ${title} (SKU: ${sku})`)
      } catch (error) {
        logger.error(`Error processing variant ${variant.id}: ${error.message}`)
      }
    }
    
    // Convert to CSV format
    const csvContent = csvRows.map(row => 
      row.map(field => `"${String(field).replace(/"/g, '""')}"`)
        .join(',')
    ).join('\n')
    
    // Write to file
    const rootDir = process.cwd()
    const fileName = `variants_export_${new Date().toISOString().split('T')[0]}.csv`
    const filePath = path.join(rootDir, fileName)
    
    fs.writeFileSync(filePath, csvContent, 'utf8')
    
    // Print summary
    console.log("----------- EXPORT COMPLETE -----------")
    console.log(`Total variants exported: ${csvRows.length - 1}`) // -1 for header
    console.log(`File saved to: ${filePath}`)
    console.log(`File name: ${fileName}`)
    
  } catch (error) {
    logger.error(`Error in variant export process: ${error.message}`)
  }
} 
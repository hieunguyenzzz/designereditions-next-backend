import { 
  ExecArgs,
} from "@medusajs/framework/types"
import * as fs from "fs"
import * as path from "path"
import { parse } from "csv-parse/sync"
import { Modules } from "@medusajs/framework/utils"
import { updateProductsWorkflow } from "@medusajs/medusa/core-flows"

export default async function readCSV({
  container
}: ExecArgs) {
  const logger = container.resolve("logger")
  const productService = container.resolve(Modules.PRODUCT)
  
  try {
    // Get the root directory of the project
    const rootDir = process.cwd()
    const filePath = path.join(rootDir, "products_export_no_cbm.csv")
    
    // Check if file exists
    if (!fs.existsSync(filePath)) {
      logger.error(`File not found: ${filePath}`)
      return
    }
    
    // Read the file content
    const fileContent = fs.readFileSync(filePath, 'utf8')
    
    // Parse CSV content
    const records = parse(fileContent, {
      columns: true,
      skip_empty_lines: true,
    })
    
    logger.info(`Found ${records.length} records in the CSV file`)
    
    // Fetch all product variants
    const [allVariants, variantCount] = await productService.listAndCountProductVariants({})
    logger.info(`Fetched ${variantCount} variants from the database`)
    
    // Create a map of SKU to variant for quick lookup
    const variantMap = new Map()
    allVariants.forEach(variant => {
      let sku = variant.metadata?.["SKU"] || variant.metadata?.specifications?.["SKU"];
      if (sku) {
        variantMap.set(sku, variant)
      }
    })
    
    // Track SKUs that don't have variants
    const missingVariants: string[] = []
    let foundVariants = 0
    let updatedVariants = 0
    
    // Process each record
    for (const record of records) {
      const sku = record.SKU
      
      if (!sku) {
        logger.warn("Record missing SKU, skipping")
        continue
      }
      
      try {
        // Find the variant by SKU from our map
        const variant = variantMap.get(sku)
        
        if (!variant) {
          missingVariants.push(sku)
          continue
        }
        
        foundVariants++
        logger.info(`Found variant for SKU ${sku}: ${variant.title}`)
        
        // Extract price information from the CSV
        const normalPrice = record["Selling Price"] ? parseFloat(record["Selling Price"].replace(/,/g, "")) : null
        const salePrice = record["FINAL"] ? parseFloat(record["FINAL"].replace(/,/g, "")) : null
        
        if (normalPrice !== null || salePrice !== null) {
          // Get current metadata
          const currentMetadata = variant.metadata || {}
          const updatedMetadata = { ...currentMetadata }
          
          // Update metadata with price information
          if (normalPrice !== null) {
            updatedMetadata.normalPrice = normalPrice
          }
          
          if (salePrice !== null) {
            updatedMetadata.salePrice = salePrice
          }
          
          // Update the variant using updateProductsWorkflow
          try {
            const productId = variant.product_id
            
            if (!productId) {
              logger.error(`Variant ${sku} has no associated product_id, skipping update`)
              continue
            }
            
            await updateProductsWorkflow(container).run({
              input: {
                selector: { id: productId },
                update: {
                  variants: [
                    {
                      id: variant.id,
                      metadata: updatedMetadata
                    }
                  ]
                }
              }
            })
            
            updatedVariants++
            console.log(`Updated variant ${sku} metadata: normalPrice=${normalPrice}, salePrice=${salePrice}`)
          } catch (updateError) {
            console.log(`Error updating variant ${sku} metadata: ${updateError.message}`)
          }
        }
      } catch (error) {
        logger.error(`Error processing variant with SKU ${sku}: ${error.message}`)
        missingVariants.push(sku)
      }
    }
    
    // Print summary
    console.log("----------- SUMMARY -----------")
    console.log(`Total SKUs in CSV: ${records.length}`)
    console.log(`Found variants: ${foundVariants}`)
    console.log(`Updated variants with price metadata: ${updatedVariants}`)
    console.log(`Missing variants: ${missingVariants.length}`)
    console.log("SKUs without associated variants:")
    console.log(missingVariants.join(', '))
    
  } catch (error) {
    logger.error(`Error processing CSV file: ${error.message}`)
  }
} 
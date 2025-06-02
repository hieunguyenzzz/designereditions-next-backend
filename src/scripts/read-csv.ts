import { 
  ExecArgs,
} from "@medusajs/framework/types"
import * as fs from "fs"
import * as path from "path"
import { parse } from "csv-parse/sync"
import { Modules } from "@medusajs/framework/utils"
// import { updateProductsWorkflow } from "@medusajs/medusa/core-flows"
import { updateProductVariantsWorkflow } from "@medusajs/medusa/core-flows"

export default async function readCSV({
  container
}: ExecArgs) {
  const logger = container.resolve("logger")
  const productService = container.resolve(Modules.PRODUCT)
  const productModuleService = container.resolve(Modules.PRODUCT)
  
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
    
    // Create a map of Type+SKU to variant for quick lookup
    const variantMap = new Map()
    allVariants.forEach(variant => {
      let sku = variant.metadata?.["SKU"] || variant.metadata?.specifications?.["SKU"] || variant.sku;
      if (sku) {
        // Try to extract type from variant title (assuming format like "ProductType - VariantName")
        const titleParts = variant.title?.split(' - ') || []
        const productType = titleParts[0] || ''
        const typeSkuKey = `${productType}:${sku}`
        variantMap.set(typeSkuKey, variant)
      }
    })
    
    // Track Type+SKUs that don't have variants
    const missingVariants: string[] = []
    let foundVariants = 0
    let updatedVariants = 0
    
    // Process each record
    for (const record of records) {
      const sku = record.SKU
      const type = record.Type
      if (!sku || !type) {
        logger.warn("Record missing SKU or Type, skipping")
        continue
      }
      
      const typeSkuKey = `${type}:${sku}`
      
      try {
        // Find the variant by Type+SKU from our map
        const variant = variantMap.get(typeSkuKey)
        
        if (!variant) {
          missingVariants.push(typeSkuKey)
          continue
        }
        
        foundVariants++
        logger.info(`Found variant for Type+SKU ${typeSkuKey}: ${variant.title}`)
        
        // Extract price information from the CSV
        const normalPrice = record["FINAL"] ? parseFloat(record["FINAL"].replace(/,/g, "")) * 100 : null
        const salePrice = record["Discounted"] ? parseFloat(record["Discounted"].replace(/,/g, "")) * 100 : null
        
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
          
          // Update the variant using productModuleService
          try {
            await productModuleService.updateProductVariants(
              variant.id,
              {
                metadata: updatedMetadata,
              }
            )

            await updateProductVariantsWorkflow(container).run({
              input: {
                product_variants: [
                  {
                    id: variant.id,
                    prices: [
                      {
                        amount: updatedMetadata.normalPrice / 100,
                        currency_code: "gbp"
                      }
                    ]
                  }
                ]
              }
            })
            
            updatedVariants++
            console.log(`Updated variant ${typeSkuKey} metadata: normalPrice=${normalPrice}, salePrice=${salePrice}`)
          } catch (updateError) {
            console.log(`Error updating variant ${typeSkuKey} metadata: ${updateError.message}`)
          }
        }
      } catch (error) {
        logger.error(`Error processing variant with Type+SKU ${typeSkuKey}: ${error.message}`)
        missingVariants.push(typeSkuKey)
      }
    }
    
    // Print summary
    console.log("----------- SUMMARY -----------")
    console.log(`Total SKUs in CSV: ${records.length}`)
    console.log(`Found variants: ${foundVariants}`)
    console.log(`Updated variants with price metadata: ${updatedVariants}`)
    console.log(`Missing variants: ${missingVariants.length}`)
    console.log("Type+SKUs without associated variants:")
    console.log(missingVariants.join(', '))
    
  } catch (error) {
    logger.error(`Error processing CSV file: ${error.message}`)
  }
} 
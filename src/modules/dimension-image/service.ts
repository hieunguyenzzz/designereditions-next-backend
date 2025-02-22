import { MedusaService } from "@medusajs/framework/utils"
import { DimensionImage } from "./models/dimension-image"

class DimensionImageModuleService extends MedusaService({
  DimensionImage,
}) {}

export default DimensionImageModuleService
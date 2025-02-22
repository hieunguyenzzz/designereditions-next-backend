import { Module } from "@medusajs/framework/utils"
import DimensionImageModuleService from "./service"

export const DIMENSION_IMAGE_MODULE_NAME = "dimension-image"

export default Module(DIMENSION_IMAGE_MODULE_NAME, {
  service: DimensionImageModuleService,
})
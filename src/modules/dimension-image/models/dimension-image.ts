import { model } from "@medusajs/framework/utils"

export const DimensionImage = model.define("dimension_image", {
  id: model.id().primaryKey(),
  url: model.text(),
  ref: model.text(),
  // Add any other properties you need
})
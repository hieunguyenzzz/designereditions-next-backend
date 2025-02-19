interface CategoryMap {
  [key: string]: {
    parent: string
    subcategory: string
  }
}

const categoryMap: CategoryMap = {
  // Chairs
  "Lounge Chair": { parent: "CHAIRS", subcategory: "Lounge Chairs" },
  "Dining Chair": { parent: "CHAIRS", subcategory: "Dining Chairs" },
  "Bar Stool": { parent: "CHAIRS", subcategory: "Bar & Counter Stools" },
  "Counter Stool": { parent: "CHAIRS", subcategory: "Bar & Counter Stools" },
  "Desk Chair": { parent: "CHAIRS", subcategory: "Desk Chairs" },
  "Ottoman": { parent: "CHAIRS", subcategory: "Stools & Ottomans" },
  "Stool": { parent: "CHAIRS", subcategory: "Stools & Ottomans" },
  "Bench": { parent: "CHAIRS", subcategory: "Benches & Daybeds" },

  // Sofas
  "2 Seater": { parent: "SOFAS", subcategory: "2 Seaters" },
  "3 Seater": { parent: "SOFAS", subcategory: "3 Seaters" },
  "Sectional": { parent: "SOFAS", subcategory: "Sectionals" },
  "Module": { parent: "SOFAS", subcategory: "Modules" },

  // Tables
  "Dining Table": { parent: "TABLES", subcategory: "Dining Tables" },
  "Coffee Table": { parent: "TABLES", subcategory: "Coffee Tables" },
  "Side Table": { parent: "TABLES", subcategory: "Side Tables" },
  "Desk": { parent: "TABLES", subcategory: "Desks" },
  "Console Table": { parent: "TABLES", subcategory: "Console Tables" },

  // Beds
  "Daybed": { parent: "BEDS", subcategory: "Daybeds" },
  "King Size Bed": { parent: "BEDS", subcategory: "King Size Beds" },

  // Lighting
  "Ceiling Lamp": { parent: "LIGHTING", subcategory: "Ceiling Lamps" },
  "Floor Lamp": { parent: "LIGHTING", subcategory: "Floor Lamps" },
  "Table Lamp": { parent: "LIGHTING", subcategory: "Table Lamps" },
  "Wall Lamp": { parent: "LIGHTING", subcategory: "Wall Lamps" },

  // Storage
  "Sideboard": { parent: "STORAGE", subcategory: "Sideboards" },
  "Media Console": { parent: "STORAGE", subcategory: "Media Consoles" },
  "Nightstand": { parent: "STORAGE", subcategory: "Nightstands" },
  "Dresser": { parent: "STORAGE", subcategory: "Dressers" },
  "Coat Rack": { parent: "STORAGE", subcategory: "Coat Racks" },

  // Decor
  "Mirror": { parent: "DECOR", subcategory: "Mirrors" },
  "Clock": { parent: "DECOR", subcategory: "Clocks" },
  "Vase": { parent: "DECOR", subcategory: "Vases" },
  "Tray": { parent: "DECOR", subcategory: "Trays" },

  // Outdoor
  "Outdoor Sectional": { parent: "OUTDOOR", subcategory: "Outdoor Sectionals" },
  "Outdoor Chair": { parent: "OUTDOOR", subcategory: "Outdoor Chairs" },
  "Outdoor Table": { parent: "OUTDOOR", subcategory: "Outdoor Tables" },
  "Outdoor Lamp": { parent: "OUTDOOR", subcategory: "Outdoor Lamps" }
}

export function getCategoryFromSubtitle(subtitle: string): { 
  parent: string | null
  subcategory: string | null 
} {
  // Default return if no match is found
  const defaultReturn = { parent: null, subcategory: null }
  
  if (!subtitle) return defaultReturn

  // Try to match the subtitle with our category map
  for (const [key, value] of Object.entries(categoryMap)) {
    if (subtitle.toLowerCase().includes(key.toLowerCase())) {
      return value
    }
  }

  return defaultReturn
} 
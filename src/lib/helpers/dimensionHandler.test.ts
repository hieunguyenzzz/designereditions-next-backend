import { transformSpecs } from './dimensionHandler';

describe('dimensionHandler', () => {
  describe('transformSpecs', () => {
    it('should convert all forms of inches and pounds in product specifications', () => {
      const input = {
        "SKU": "2369",
        "Material": "Plush velvet",
        "Seat Depth": "40.5\"",
        "Seat Height": "15.8\"",
        "Product Weight": "43 lbs",
        "Frame Construction": "Solid wood",
        "Product Dimensions": "W39.8“ x D39.8” x H15.8“",
        "Cushion Information": "High density foam",
        "Packaging Dimensions": "39” x 38.2“ x 17.7”",
        "Indoor or Outdoor Use": "Indoor",
        "No. of Shipping Cartons": "1"
      };
      
      const result = transformSpecs(input) as Record<string, string>;
      
      // Test inch to centimeter conversions with various formats
      expect(result["Seat Depth"]).toBe("103 cm");
      expect(result["Seat Height"]).toBe("40 cm");
      expect(result["Product Weight"]).toBe("20 kg");
      expect(result["Product Dimensions"]).toBe("W101 cm x D101 cm x H40 cm");
      expect(result["Packaging Dimensions"]).toBe("99 cm x 97 cm x 45 cm");
      
      // Test non-measurement fields remain unchanged
      expect(result.SKU).toBe("2369");
      expect(result.Material).toBe("Plush velvet");
      expect(result["Frame Construction"]).toBe("Solid wood");
      expect(result["Indoor or Outdoor Use"]).toBe("Indoor");
      expect(result["No. of Shipping Cartons"]).toBe("1");
    });
    
    it('should normalize and convert different inch symbol formats', () => {
      // Use a mix of regular quotes and Unicode escape sequences for special characters
      const input = {
        "Item 1": "30\"", // Escaped double quote
        "Item 2": "25\u2033", // Unicode double prime (″)
        "Item 3": "20\"", // Standard escaped quote
        "Item 4": "15''", // Two single quotes
        "Item 5": "W35\" x D30\" x H20\"" // Multiple dimensions with quotes
      };
      
      const result = transformSpecs(input) as Record<string, string>;
      
      // All inch symbols should be normalized and converted to centimeters
      expect(result["Item 1"]).toBe("76 cm");
      expect(result["Item 2"]).toBe("64 cm");
      expect(result["Item 3"]).toBe("51 cm");
      expect(result["Item 4"]).toBe("38 cm");
      expect(result["Item 5"]).toBe("W89 cm x D76 cm x H51 cm");
    });
  });
}); 
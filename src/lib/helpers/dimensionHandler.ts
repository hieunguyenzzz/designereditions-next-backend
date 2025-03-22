// Constants
const LBS_TO_KG = 0.45359237;
const INCH_TO_CM = 2.54;

/**
 * Convert imperial measurements to metric units
 * @param value Input string containing measurements to convert
 * @returns String with measurements converted to metric units
 */
function convertMeasurements(value: string): string {
  if (!value || typeof value !== 'string') {
    return '';
  }
  
  // Step 1: Normalize all inch symbols to standard double quote (")
  // This includes fancy quotes, double prime, consecutive single quotes, etc.
  let result = value;
  
  // Replace curly/smart quotes and double prime with standard quote
  result = result.replace(/[""″]/g, '"');

  result = result.replace(/[\u201C\u201D]/g, '"');
  
  // Handle consecutive single quotes as inch symbol
  result = result.replace(/(\d+\.?\d*)(''){1}/g, '$1"');
  
  // Replace escaped quotes with standard quote
  result = result.replace(/\\"/g, '"');
  
  // Step 2: Convert pounds to kilograms
  result = result.replace(/(\d+\.?\d*)\s*(lb|lbs|pound|pounds)\b/gi, (match, weight) => {
    const kg = Math.round(parseFloat(weight) * LBS_TO_KG);
    return `${kg} kg`;
  });
  
  // Step 3: Handle three-part dimensions in various formats
  
  // Format: W39.8" x D39.8" x H15.8"
  result = result.replace(/([WHD])(\d+\.?\d*)"(\s*x\s*)([WHD])(\d+\.?\d*)"(\s*x\s*)([WHD])(\d+\.?\d*)"/g, 
    (match, p1, n1, x1, p2, n2, x2, p3, n3) => {
      const cm1 = Math.round(parseFloat(n1) * INCH_TO_CM);
      const cm2 = Math.round(parseFloat(n2) * INCH_TO_CM);
      const cm3 = Math.round(parseFloat(n3) * INCH_TO_CM);
      return `${p1}${cm1} cm${x1}${p2}${cm2} cm${x2}${p3}${cm3} cm`;
    }
  );
  
  // Format: 39" x 38.2" x 17.7"
  result = result.replace(/(\d+\.?\d*)"(\s*x\s*)(\d+\.?\d*)"(\s*x\s*)(\d+\.?\d*)"/g, 
    (match, n1, x1, n2, x2, n3) => {
      const cm1 = Math.round(parseFloat(n1) * INCH_TO_CM);
      const cm2 = Math.round(parseFloat(n2) * INCH_TO_CM);
      const cm3 = Math.round(parseFloat(n3) * INCH_TO_CM);
      return `${cm1} cm${x1}${cm2} cm${x2}${cm3} cm`;
    }
  );
  
  // Step 4: Handle simpler inch formats
  
  // Handle prefixed dimensions like W39.8"
  result = result.replace(/([WHD])(\d+\.?\d*)"/g, (match, prefix, number) => {
    const cm = Math.round(parseFloat(number) * INCH_TO_CM);
    return `${prefix}${cm} cm`;
  });
  
  // Handle standalone inches like 40.5"
  result = result.replace(/(\d+\.?\d*)"/g, (match, number) => {
    const cm = Math.round(parseFloat(number) * INCH_TO_CM);
    return `${cm} cm`;
  });
  
  // Handle other inch formats (inch, inches, in)
  result = result.replace(/(\d+\.?\d*)\s*(inch|inches|in)\b/gi, (match, number) => {
    const cm = Math.round(parseFloat(number) * INCH_TO_CM);
    return `${cm} cm`;
  });
  
  // Step 5: Standardize spacing around cm
  result = result.replace(/(\d+)\.?\d*\s*cm/g, '$1 cm');
  
  return result;
}

/**
 * Transform product specifications by converting imperial measurements to metric
 * @param specs Array or object containing string specifications to transform
 * @returns Transformed specifications with same structure as input
 */
export function transformSpecs(specs: string[] | Record<string, string>): string[] | Record<string, string> {
  // Handle arrays
  if (Array.isArray(specs)) {
    return specs.map(item => convertMeasurements(String(item)));
  }
  
  // Handle objects
  if (specs && typeof specs === 'object') {
    const result: Record<string, string> = {};
    
    for (const [key, value] of Object.entries(specs)) {
      result[key] = convertMeasurements(String(value));
    }
    
    return result;
  }
  
  // Return empty result for invalid inputs
  return Array.isArray(specs) ? [] : {};
}
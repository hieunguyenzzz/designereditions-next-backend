/**
 * Interface for image detection services
 */
export interface ImageDetectorService {
  /**
   * Check if an image URL depicts a product dimension/measurement image
   */
  isDimensionImage(imageUrl: string): Promise<boolean>;
} 
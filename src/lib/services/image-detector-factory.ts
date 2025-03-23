import { ImageDetectorService } from './image-detector.interface'
import { OpenAIService, openaiService } from './openai'
import { OllamaService, ollamaService } from './ollama'

/**
 * Factory to provide the appropriate image detector service based on configuration
 */
export class ImageDetectorFactory {
  /**
   * Get the configured image detector service
   */
  static getService(): ImageDetectorService {
    // Choose based on environment variable
    const serviceType = process.env.IMAGE_DETECTOR_SERVICE?.toLowerCase() || 'openai'
    
    if (serviceType === 'ollama') {
      return ollamaService
    }
    
    // Default to OpenAI
    return openaiService
  }
}

// Export a singleton instance of the image detector service
export const imageDetectorService = ImageDetectorFactory.getService() 
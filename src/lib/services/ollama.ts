import axios from 'axios'
import { ImageDetectorService } from './image-detector.interface'
import { RedisCacheService } from './redis-cache'

/**
 * Service to handle Ollama API calls with Redis caching
 */
export class OllamaService implements ImageDetectorService {
  private ollamaBaseUrl: string
  private model: string
  private cacheService: RedisCacheService

  constructor() {
    this.ollamaBaseUrl = process.env.OLLAMA_API_URL || 'http://localhost:11434'
    this.model = process.env.OLLAMA_MODEL || 'llava'
    
    // Initialize Redis cache service
    this.cacheService = new RedisCacheService('openai:dimension-image:')
  }

  /**
   * Fetch image data as base64
   */
  private async getImageAsBase64(imageUrl: string): Promise<string> {
    try {
      const response = await axios.get(imageUrl, {
        responseType: 'arraybuffer'
      })
      const buffer = Buffer.from(response.data, 'binary')
      return buffer.toString('base64')
    } catch (error) {
      console.error('Error fetching image:', error)
      throw new Error('Failed to fetch image')
    }
  }

  /**
   * Check if an image URL depicts a product dimension/measurement image
   * Uses Redis caching to avoid repeated API calls for the same URL
   */
  async isDimensionImage(imageUrl: string): Promise<boolean> {
    // Generate a hash for the image URL to use as cache key
    const urlHash = this.cacheService.getUrlHash(imageUrl)
    
    // Check if we have a cached result
    const cachedResult = await this.cacheService.getCachedValue(urlHash)
    if (cachedResult !== null) {
      return cachedResult
    }
    
    try {
      // Get image as base64
      const imageBase64 = await this.getImageAsBase64(imageUrl)
      
      // Call Ollama API
      const response = await axios.post(`${this.ollamaBaseUrl}/api/generate`, {
        model: this.model,
        prompt: "Is this a product dimension/measurement image? Please respond with just 'true' or 'false'.",
        images: [imageBase64],
        stream: false
      })
      
      // Extract the simple true/false response from Ollama
      const responseText = response.data.response.trim().toLowerCase()
      const result = responseText === 'true'
      
      // Cache the result
      await this.cacheService.setCachedValue(urlHash, result)
      
      return result
    } catch (error) {
      console.error('Error detecting dimension image with Ollama:', error)
      return false
    }
  }
}

// Export a singleton instance
export const ollamaService = new OllamaService() 
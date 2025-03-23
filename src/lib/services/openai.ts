import OpenAI from 'openai'
import { ImageDetectorService } from './image-detector.interface'
import { RedisCacheService } from './redis-cache'

/**
 * Service to handle OpenAI API calls with Redis caching
 */
export class OpenAIService implements ImageDetectorService {
  private openai: OpenAI
  private cacheService: RedisCacheService

  constructor() {
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    })
    
    // Initialize Redis cache service
    this.cacheService = new RedisCacheService('openai:dimension-image:')
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
      const response = await this.openai.chat.completions.create({
        model: "gpt-4o-mini",
        messages: [
          {
            role: "user",
            content: [
              { 
                type: "text", 
                text: "Is this a product dimension/measurement image? Please respond with just 'true' or 'false'." 
              },
              {
                type: "image_url",
                image_url: {
                  url: `${imageUrl}`,
                  detail: "low"
                }
              }
            ],
          },
        ],
        max_tokens: 300,
      });

      const result = response.choices[0].message.content?.toLowerCase() === 'true'
      
      // Cache the result
      await this.cacheService.setCachedValue(urlHash, result)
      
      return result
    } catch (error) {
      console.error('Error detecting dimension image:', error)
      return false
    }
  }
}

// Export a singleton instance
export const openaiService = new OpenAIService() 
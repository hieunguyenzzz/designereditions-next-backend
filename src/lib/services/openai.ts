import OpenAI from 'openai'
import crypto from 'crypto'
import { createClient } from 'redis'

/**
 * Service to handle OpenAI API calls with Redis caching
 */
export class OpenAIService {
  private openai: OpenAI
  private redisClient: ReturnType<typeof createClient>
  private redisReady: boolean = false
  private cachePrefix: string = 'openai:dimension-image:'

  constructor() {
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    })
    
    // Initialize Redis client
    this.initializeRedisClient()
  }

  /**
   * Initialize Redis client
   */
  private async initializeRedisClient(): Promise<void> {
    try {
      // Create Redis client using environment variable
      this.redisClient = createClient({
        url: process.env.REDIS_URL || 'redis://localhost:6379'
      })

      // Error handling for Redis client
      this.redisClient.on('error', (err) => {
        console.error('Redis client error:', err)
        this.redisReady = false
      })

      // Connect to Redis
      await this.redisClient.connect()
      this.redisReady = true
      console.log('Connected to Redis for OpenAI caching')
    } catch (error) {
      console.error('Failed to connect to Redis:', error)
      this.redisReady = false
    }
  }

  /**
   * Generate a hash for a URL to use as a cache key
   */
  private getUrlHash(url: string): string {
    return crypto.createHash('md5').update(url).digest('hex')
  }

  /**
   * Get a value from Redis cache
   */
  private async getCachedValue(key: string): Promise<boolean | null> {
    if (!this.redisReady) {
      await this.initializeRedisClient()
      if (!this.redisReady) return null
    }

    try {
      const value = await this.redisClient.get(`${this.cachePrefix}${key}`)
      return value ? value === 'true' : null
    } catch (error) {
      console.error('Error retrieving from Redis cache:', error)
      return null
    }
  }

  /**
   * Set a value in Redis cache
   */
  private async setCachedValue(key: string, value: boolean): Promise<void> {
    if (!this.redisReady) {
      await this.initializeRedisClient()
      if (!this.redisReady) return
    }

    try {
      // Cache without expiration (persist forever)
      await this.redisClient.set(
        `${this.cachePrefix}${key}`, 
        value.toString()
      )
    } catch (error) {
      console.error('Error saving to Redis cache:', error)
    }
  }

  /**
   * Check if an image URL depicts a product dimension/measurement image
   * Uses Redis caching to avoid repeated API calls for the same URL
   */
  async isDimensionImage(imageUrl: string): Promise<boolean> {
    // Generate a hash for the image URL to use as cache key
    const urlHash = this.getUrlHash(imageUrl)
    
    // Check if we have a cached result
    const cachedResult = await this.getCachedValue(urlHash)
    if (cachedResult !== null) {
      console.log('Using cached result for image:', imageUrl)
      return cachedResult
    }
    
    console.log('Checking if image is a dimension image:', imageUrl)
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
      await this.setCachedValue(urlHash, result)
      
      return result
    } catch (error) {
      console.error('Error detecting dimension image:', error)
      return false
    }
  }
}

// Export a singleton instance
export const openaiService = new OpenAIService() 
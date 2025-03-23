import crypto from 'crypto'
import { createClient } from 'redis'

/**
 * Service to handle Redis caching functionality 
 */
export class RedisCacheService {
  private redisClient: ReturnType<typeof createClient>
  private redisReady: boolean = false
  private cachePrefix: string

  /**
   * Initialize Redis cache service with a specific prefix
   */
  constructor(cachePrefix: string) {
    this.cachePrefix = cachePrefix
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
      console.log(`Connected to Redis for ${this.cachePrefix} caching`)
    } catch (error) {
      console.error('Failed to connect to Redis:', error)
      this.redisReady = false
    }
  }

  /**
   * Generate a hash for a URL to use as a cache key
   */
  getUrlHash(url: string): string {
    return crypto.createHash('md5').update(url).digest('hex')
  }

  /**
   * Get a value from Redis cache
   */
  async getCachedValue(key: string): Promise<boolean | null> {
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
  async setCachedValue(key: string, value: boolean): Promise<void> {
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
} 
// src/modules/auth/services/redis.service.ts
import { Injectable, Logger, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { createClient, RedisClientType } from 'redis';

@Injectable()
export class RedisService implements OnModuleInit, OnModuleDestroy {
  private client: RedisClientType;
  private logger = new Logger('RedisService');

  constructor() {
    const host = process.env.REDIS_HOST || 'localhost';
    const port = process.env.REDIS_PORT || '6379';

    this.client = createClient({
      url: `redis://${host}:${port}`
    });

    this.client.on('error', (err) => this.logger.error('Redis Client Error:', err));
    this.client.on('connect', () => this.logger.log('Connected to Redis'));
  }

  async onModuleInit() {
    await this.client.connect();
  }

  async onModuleDestroy() {
    await this.client.disconnect();
  }

  async addSeekerLocation(
    userId: string,
    latitude: number,
    longitude: number,
  ): Promise<void> {
    try {
      await this.client.geoAdd('active_seekers', {
        longitude: longitude,
        latitude: latitude,
        member: userId,
      });

      await this.client.setEx(
        `seeker_active:${userId}`,
        1800,
        JSON.stringify({ latitude, longitude, timestamp: Date.now() })
      );
    } catch (err) {
      this.logger.error(`Error adding seeker location: ${err}`);
      throw err;
    }
  }

  async getNearbySeekersInRadius(
    latitude: number,
    longitude: number,
    radiusKm: number = 5,
  ): Promise<string[]> {
    try {
      const members = await this.client.geoRadius(
        'active_seekers',
        { longitude, latitude },
        radiusKm,
        'km'
      );

      if (!members || members.length === 0) return [];

      const activeNearbySeekers = await Promise.all(
        members.map(async (userId) => {
          const exists = await this.client.exists(`seeker_active:${userId}`);
          return exists ? userId : null;
        })
      );

      return activeNearbySeekers.filter((id): id is string => id !== null);
    } catch (err) {
      this.logger.error(`Error getting nearby seekers: ${err}`);
      throw err;
    }
  }

  async removeSeekerLocation(userId: string): Promise<void> {
    try {
      await this.client.zRem('active_seekers', userId);
      await this.client.del(`seeker_active:${userId}`);
    } catch (err) {
      this.logger.error(`Error removing seeker: ${err}`);
      throw err;
    }
  }

  async getSeekerLocation(userId: string): Promise<{ latitude: number; longitude: number } | null> {
    try {
      const pos = await this.client.geoPos('active_seekers', userId);
      if (pos && pos[0]) {
        return {
          longitude: Number(pos[0].longitude),
          latitude: Number(pos[0].latitude),
        };
      }
      return null;
    } catch (err) {
      return null;
    }
  }

  /**
   * Distance Fix: Added proper handling for string/number conversion
   */
  async getDistance(userId1: string, userId2: string): Promise<number | null> {
    try {
      // Redis v4+ returns distance as a string or null
      const distance = await this.client.geoDist('active_seekers', userId1, userId2, 'km');
      
      if (distance === null) return null;
      
      // Convert string to number safely
      return typeof distance === 'string' ? parseFloat(distance) : distance;
    } catch (err) {
      this.logger.error(`Error calculating distance: ${err}`);
      return null;
    }
  }

  async cleanupExpiredSeekers(): Promise<number> {
    try {
      // Fix: Strings '0' and '-1'
      const members = await this.client.zRange('active_seekers', '0', '-1');
      let removedCount = 0;

      for (const userId of members) {
        const exists = await this.client.exists(`seeker_active:${userId}`);
        if (!exists) {
          await this.client.zRem('active_seekers', userId);
          removedCount++;
        }
      }
      return removedCount;
    } catch (err) {
      return 0;
    }
  }

  async getActiveSeekerCount(): Promise<number> {
    try {
      return await this.client.zCard('active_seekers');
    } catch (err) {
      return 0;
    }
  }
}
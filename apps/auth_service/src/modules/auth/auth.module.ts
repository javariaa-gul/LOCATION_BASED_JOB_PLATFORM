// src/modules/auth/auth.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { User } from './entities/user.entity';
import { Job } from './entities/job.entity'; // <--- Nayi Entity Import ki
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtStrategy } from './jwt.strategy';
import { RedisService } from './services/redis.service';

@Module({
  imports: [
    // TypeOrmModule mein 'Job' ko shamil kar diya hai
    TypeOrmModule.forFeature([User, Job]), 
    PassportModule,
    JwtModule.register({
      secret: 'SUPER_SECRET_KEY_123',
      signOptions: { expiresIn: '1d' }, // Token 1 din tak valid rahega
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy, RedisService],
  exports: [AuthService, RedisService],
})
export class AuthModule {}
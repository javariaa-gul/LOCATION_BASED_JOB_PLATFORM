// src/modules/auth/auth.service.ts
import { Injectable, ConflictException, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserRole } from './entities/user.entity';
import { Job, JobStatus } from './entities/job.entity'; // Job aur JobStatus import kiya
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { CreateJobDto } from './dto/create-job.dto'; // CreateJobDto import kiya
import { UpdateLocationDto } from './dto/update-location.dto';
import { JwtService } from '@nestjs/jwt';
import { RedisService } from './services/redis.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Job) // Job repository inject ki
    private readonly jobRepository: Repository<Job>,
    private readonly jwtService: JwtService,
    private readonly redisService: RedisService,
  ) { }

  // --- JOB METHODS ---

  async createJob(posterId: string, createJobDto: CreateJobDto): Promise<Job> {
    const newJob = this.jobRepository.create({
      ...createJobDto,
      posterId,
      status: JobStatus.OPEN, // Nayi job hamesha OPEN status mein hogi
    });

    return await this.jobRepository.save(newJob);
  }

  // --- AUTH METHODS ---

  async register(registerDto: RegisterDto): Promise<User> {
    const {
      email,
      password,
      initialRole,
      latitude,
      longitude,
      fullName,
      city,
      area
    } = registerDto;

    const existingUser = await this.userRepository.findOne({ where: { email } });
    if (existingUser) throw new ConflictException('User already exists');

    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = this.userRepository.create({
      fullName,
      email,
      password: hashedPassword,
      currentRole: initialRole,
      city,
      area,
      latitude: latitude ?? undefined,
      longitude: longitude ?? undefined,
      lastLocationUpdate: (latitude && longitude) ? new Date() : undefined,
    });

    const savedUser = await this.userRepository.save(newUser);

    if (initialRole === UserRole.SEEKER && latitude && longitude) {
      try {
        await this.redisService.addSeekerLocation(
          savedUser.id,
          latitude,
          longitude,
        );
      } catch (redisError) {
        console.error('Warning: Could not add seeker to Redis:', redisError);
      }
    }

    return savedUser;
  }

  async login(loginDto: LoginDto) {
    const { email, password } = loginDto;
    const user = await this.userRepository.createQueryBuilder('user')
      .addSelect('user.password')
      .where('user.email = :email', { email })
      .getOne();

    if (!user || !(await bcrypt.compare(password, user.password))) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const payload = { email: user.email, sub: user.id, role: user.currentRole };
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        role: user.currentRole,
        latitude: user.latitude,
        longitude: user.longitude,
      }
    };
  }

  async switchRole(userId: string): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) throw new UnauthorizedException('User not found');
    user.currentRole = user.currentRole === UserRole.POSTER ? UserRole.SEEKER : UserRole.POSTER;
    return await this.userRepository.save(user);
  }
  // auth.service.ts ke andar

  async findAllJobs() {
    return await this.jobRepository.find({
      relations: ['poster'], // Agar aapko poster ki details bhi chahiye
      order: { createdAt: 'DESC' }, // Naye kaam pehle dikhane ke liye
    });
  }

  async updateLocation(
    userId: string,
    updateLocationDto: UpdateLocationDto,
  ): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) throw new UnauthorizedException('User not found');

    if (user.currentRole !== UserRole.SEEKER) {
      throw new BadRequestException('Only seekers can update their location');
    }

    const { latitude, longitude } = updateLocationDto;

    user.latitude = latitude;
    user.longitude = longitude;
    user.lastLocationUpdate = new Date();

    const updatedUser = await this.userRepository.save(user);

    try {
      await this.redisService.addSeekerLocation(userId, latitude, longitude);
    } catch (redisError) {
      console.error('Warning: Could not update seeker location in Redis:', redisError);
    }

    return updatedUser;
  }

  async getNearbySeekersForPosting(
    latitude: number,
    longitude: number,
    radiusKm: number = 5,
  ): Promise<string[]> {
    try {
      return await this.redisService.getNearbySeekersInRadius(
        latitude,
        longitude,
        radiusKm,
      );
    } catch (error) {
      console.error('Error getting nearby seekers:', error);
      return [];
    }
  }

  async deactivateSeeker(userId: string): Promise<void> {
    try {
      await this.redisService.removeSeekerLocation(userId);
    } catch (error) {
      console.error('Warning: Could not deactivate seeker in Redis:', error);
    }
  }
}
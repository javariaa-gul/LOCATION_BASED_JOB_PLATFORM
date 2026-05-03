import { Controller, Post, Body, Patch, Param, HttpCode, HttpStatus, UseGuards, Request, Get } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { CreateJobDto } from './dto/create-job.dto'; 
import { UpdateLocationDto } from './dto/update-location.dto';
import { JwtAuthGuard } from './jwt.guard';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) { }

  @Post('register')
  async register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  // --- NAYA ENDPOINT: Jobs Fetch Karne Ke Liye ---
  @Get('all-jobs')
  @UseGuards(JwtAuthGuard)
  async getAllJobs() {
    // Ye service se saari jobs mangwayega
    return this.authService.findAllJobs(); 
  }

  @Patch('switch-role')
  @UseGuards(JwtAuthGuard)
  async switchRole(@Request() req) {
    return this.authService.switchRole(req.user.id);
  }

  @Post('jobs')
  @UseGuards(JwtAuthGuard)
  async createJob(@Request() req, @Body() createJobDto: CreateJobDto) {
    return this.authService.createJob(req.user.id, createJobDto);
  }

  @Post('location/update')
  @UseGuards(JwtAuthGuard)
  async updateLocation(
    @Request() req,
    @Body() updateLocationDto: UpdateLocationDto,
  ) {
    return this.authService.updateLocation(req.user.id, updateLocationDto);
  }

  @Post('location/nearby')
  async getNearbySeekersForPosting(
    @Body() body: { latitude: number; longitude: number; radiusKm?: number },
  ) {
    const nearbySeekersIds = await this.authService.getNearbySeekersForPosting(
      body.latitude,
      body.longitude,
      body.radiusKm || 5,
    );
    return {
      nearbySeekersCount: nearbySeekersIds.length,
      seekerIds: nearbySeekersIds,
    };
  }

  @Post('location/deactivate')
  @UseGuards(JwtAuthGuard)
  async deactivateSeeker(@Request() req) {
    await this.authService.deactivateSeeker(req.user.id);
    return { message: 'Seeker deactivated from real-time matching' };
  }
}
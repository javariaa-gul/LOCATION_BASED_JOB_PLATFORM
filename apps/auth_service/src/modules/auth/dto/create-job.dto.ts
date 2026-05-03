// src/modules/auth/dto/create-job.dto.ts
import { IsString, IsNotEmpty, IsEnum, IsNumber, IsOptional, IsBoolean, IsDateString } from 'class-validator';
import { GenderPreference } from '../entities/job.entity';

export class CreateJobDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsNotEmpty()
  description: string;

  @IsOptional()
  @IsString()
  attachments?: string;

  @IsBoolean()
  isRemote: boolean;

  @IsOptional()
  @IsNumber()
  latitude?: number;

  @IsOptional()
  @IsNumber()
  longitude?: number;

  @IsString()
  @IsNotEmpty()
  address: string;

  @IsString()
  @IsNotEmpty()
  expectedDuration: string;

  @IsDateString()
  startTime: Date;

  @IsEnum(GenderPreference)
  genderPreference: GenderPreference;

  @IsString()
  priceType: 'FIXED' | 'HOURLY';

  @IsNumber()
  priceValue: number;
}
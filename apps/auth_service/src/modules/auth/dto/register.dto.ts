// src/modules/auth/dto/register.dto.ts
import { IsEmail, IsString, IsEnum, MinLength, Matches, IsOptional, IsNumber } from 'class-validator';
import { UserRole } from '../entities/user.entity';

export class RegisterDto {
  @IsEmail({}, { message: 'Please provide a valid email address' })
  email: string;

  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters long' })
  @Matches(/((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$/, {
    message: 'Password is too weak. Must include Uppercase, Lowercase, and a Number/Special character',
  })
  password: string;

  @IsString()
  fullName: string;

  @IsString()
  city: string;

  @IsString()
  area: string;

  @IsEnum(UserRole)
  initialRole: UserRole;

  @IsOptional()
  @IsString({ each: true })
  skills?: string[];

  // Location fields - Mandatory for Seekers (frontend validation), Optional for Posters
  @IsOptional()
  @IsNumber()
  latitude?: number;

  @IsOptional()
  @IsNumber()
  longitude?: number;
}
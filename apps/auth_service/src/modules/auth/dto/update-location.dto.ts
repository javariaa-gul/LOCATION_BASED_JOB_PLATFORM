// src/modules/auth/dto/update-location.dto.ts
import { IsNumber, IsNotEmpty } from 'class-validator';

export class UpdateLocationDto {
  @IsNumber()
  @IsNotEmpty()
  latitude: number;

  @IsNumber()
  @IsNotEmpty()
  longitude: number;
}

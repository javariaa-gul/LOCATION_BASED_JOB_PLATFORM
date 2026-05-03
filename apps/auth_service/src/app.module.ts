// apps/auth_service/src/app.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './modules/auth/auth.module';
import { User } from './modules/auth/entities/user.entity';
import { Job } from './modules/auth/entities/job.entity';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: 'localhost', 
      port: 5432,
      username: 'hunar_admin',
      password: 'HunarPassword123',
      database: 'apka_hunar_db',
      entities: [User, Job],
      synchronize: true, // Automatically creates/updates tables based on entities
      logging: true,
    }),
    AuthModule,
  ],
})
export class AppModule {}
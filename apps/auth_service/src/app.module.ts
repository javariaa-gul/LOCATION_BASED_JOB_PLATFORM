import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './modules/auth/auth.module';
import { User } from './modules/auth/entities/user.entity';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: 'localhost', 
      port: 5432,
      username: 'hunar_admin',
      password: 'HunarPassword123',
      database: 'apka_hunar_db',
      entities: [User],
      synchronize: true, // Automatically creates/updates tables based on entities
      logging: true,
    }),
    AuthModule,
  ],
})
export class AppModule {}
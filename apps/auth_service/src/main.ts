import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.enableCors();

  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));

  // --- SWAGGER SETUP START ---
  const config = new DocumentBuilder()
    .setTitle('Apka-Hunar API')
    .setDescription('The Authentication Service API for Apka-Hunar Marketplace')
    .setVersion('1.0')
    .addTag('auth')
    .build();
    
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document); // 'api' is the endpoint for swagger
  // --- SWAGGER SETUP END ---

  await app.listen(3000);
  console.log(`Auth Service is live on: http://localhost:3000`);
  console.log(`Swagger UI is available on: http://localhost:3000/api`);
}
bootstrap();
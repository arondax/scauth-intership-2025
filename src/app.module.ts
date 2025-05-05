import { Inject, Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { User } from './user/user.entity';

import { WebAuthnCredentials } from './web-authn-credentials/web-authn-credentials.entity';
import { TypeOrmModule } from '@nestjs/typeorm';


@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env'],}),
      TypeOrmModule.forRootAsync({
        imports: [ConfigModule],
        inject: [ConfigService],
        useFactory: (ConfigService: ConfigService) => ({
          type: 'postgres',
          host: ConfigService.get('DB_HOST'),
          port: ConfigService.get<number>('DB_PORT'),
          username: ConfigService.get('DB_USERNAME'),
          password: ConfigService.get('DB_PASSWORD'),
          database: ConfigService.get('DB_DATABASE'),
          entities: [User, WebAuthnCredentials],
          synchronize: ConfigService.get('NODE_ENV') !== 'production',
          logging: ConfigService.get('NODE_ENV') !== 'development',
        }),
      })
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}

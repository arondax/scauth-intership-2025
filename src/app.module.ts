import 'dotenv/config'
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
      envFilePath: ['.env'],
    }),
      TypeOrmModule.forRootAsync({
        imports: [ConfigModule],
        inject: [ConfigService],
        useFactory: (ConfigService: ConfigService) => ({
          type: 'postgres',
          url:ConfigService.get<string>('DATABASE_URL'),
          entities: [User, WebAuthnCredentials],
          synchronize: true,
        }),
      })
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}

import { Module } from "@nestjs/common";
import { UserController } from "./user.controller";
import { UserService } from "./user.service";
import { User } from "./user.entity";
import { TypeOrmModule } from "@nestjs/typeorm";
import { WebAuthnCredentials } from "src/web-authn-credentials/web-authn-credentials.entity";

@Module({
    imports:[TypeOrmModule.forFeature([User, WebAuthnCredentials])],
    controllers:[UserController],
    providers:[UserService],
    exports:[UserService]
})

export class UserModule {}

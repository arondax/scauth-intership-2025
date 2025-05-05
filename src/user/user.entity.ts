import { Entity, PrimaryColumn,Column,CreateDateColumn, Admin, OneToMany } from 'typeorm';
import { UserRole } from './user.enums';
import { WebAuthnCredentials } from 'src/web-authn-credentials/web-authn-credentials.entity';

@Entity('users')
export class User {
    @PrimaryColumn({ type: 'varchar', length: 255 })
    email: string;
  
    @Column({ type: 'varchar', length: 255 })
    password_hash: string;
  
    @Column({ type: 'varchar', length: 100, nullable: true })
    name: string;
  
    @CreateDateColumn({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
    registration_date: Date;
  
    @Column({ type: 'integer', length: 1, default: 'user' })
    role: UserRole;

    @OneToMany(() => WebAuthnCredentials, (webAuthnCredentials) => webAuthnCredentials.user)
    webAuthnCredentials: WebAuthnCredentials[]; // This establishes a one-to-many relationship with the WebAuthnCredentials entity.

}


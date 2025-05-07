import { User } from "src/user/user.entity";
import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from "typeorm";

@Entity('web_authn_credentials')
export class WebAuthnCredentials {

 @PrimaryGeneratedColumn()
id: number;// This is the primary key for the table, and it is of type integer with a length of 255 characters. It is also marked as the primary column.

@Column({ type: 'varchar', length: 255 })
user_email: string; // This column stores the email of the user associated with the WebAuthn credential. It is of type varchar with a length of 255 characters.

@Column({ type: 'varchar', length: 255, nullable: true, unique: true })
credential_id: string; // This column stores the credential ID of the WebAuthn credential. It is of type varchar with a length of 255 characters.

@Column({ type: 'text', nullable: true, unique: true })
public_key: string; // This column stores the public key associated with the WebAuthn credential. It is of type varchar with a length of 255 characters.

@Column({ type: 'varchar', length: 255 })
device_type: string; // This column stores the type of device used for the WebAuthn credential. It is of type varchar with a length of 255 characters.

@Column({ type: 'text' })
origin: string; // This column stores the origin associated with the WebAuthn credential. It is of type text.

@Column({ type: 'integer' }) 
sign_count: number; // This column stores the sign count associated with the WebAuthn credential. It is of type integer with a length of 1 and has a default value of 0.

@Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
created_at: Date; // This column stores the timestamp of when the WebAuthn credential was created. It is of type timestamp and has a default value of the current timestamp.

@ManyToOne(() => User, (user) => user.webAuthnCredentials, { onDelete: 'CASCADE' })
@JoinColumn({ name: 'user_email', referencedColumnName: 'email' })
// This specifies the join column for the relationship with the User entity. It indicates that the user_email column in this entity references the email column in the User entity.
user: User; // This establishes a many-to-one relationship with the User entity. The onDelete: 'CASCADE' option means that if the user is deleted, the associated WebAuthn credentials will also be deleted.

} 

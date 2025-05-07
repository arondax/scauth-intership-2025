import 'dotenv/config'

import { Pool } from 'pg';
import { Kysely, PostgresDialect } from 'kysely';
import { UserTable } from './tables/user.table';
import { WebAuthnCredentialTable } from './tables/webauthn.table';

export interface DB {
  users: UserTable;
  webauthn_credentials: WebAuthnCredentialTable;
}

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

export const db = new Kysely<DB>({
  dialect: new PostgresDialect({
    pool,
  }),
});

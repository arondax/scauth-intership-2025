// lib/db.ts
import { Kysely, PostgresDialect } from "kysely";
import { Pool } from "pg";

// Create a Kysely instance connected to PostgreSQL
export const db = new Kysely({
  dialect: new PostgresDialect({
    pool: new Pool({
      host: "localhost", // or 'db-scauth' if running within Docker
      port: 5432,
      user: "admin",
      password: "admin",
      database: "scauth",
    }),
  }),
});

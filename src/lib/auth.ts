// lib/auth.ts
import { betterAuth } from "better-auth";
import { db } from "./db"; // Import Kysely instance

// Initialize Better Auth with the database
export const auth = betterAuth({
  database: db,
});

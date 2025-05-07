import { betterAuth } from "better-auth";
import { db } from "../kysley/db"; // Import Kysely instance

// Initialize Better Auth with the database
export const auth = betterAuth({
  database: db,
});

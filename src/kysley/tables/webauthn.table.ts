export interface WebAuthnCredentialTable {
  id: number;
  user_email: string;
  credential_id: string;
  public_key: string;
  device_type: string | null;
  origin: string | null;
  sign_count: number;
  created_at: string; // TIMESTAMP
}

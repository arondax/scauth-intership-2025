export interface UserTable {
  email: string;
  password_hash: string;
  name: string | null;
  registration_date: string; // TIMESTAMP
  role: 'admin' | 'user';
}
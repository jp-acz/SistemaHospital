const sql = require('mssql');
require('dotenv').config();

const config = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  port: parseInt(process.env.DB_PORT || '1433'),
  options: {
    encrypt: process.env.DB_ENCRYPT === 'true',
    trustServerCertificate: process.env.DB_TRUST_SERVER_CERTIFICATE === 'true'
  }
};

async function createDatabase() {
  try {
    // Conectar a master (BD del sistema)
    const pool = await sql.connect(config);
    
    // Crear BD si no existe
    await pool.request().query(`
      IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'HospitalDB')
      BEGIN
        CREATE DATABASE HospitalDB;
      END
    `);
    
    console.log('✓ Base de datos HospitalDB creada o ya existe');
    await pool.close();
    process.exit(0);
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

createDatabase();

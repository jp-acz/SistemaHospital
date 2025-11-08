// backend/src/config/database.js
const sql = require('mssql');
require('dotenv').config();

const dbConfig = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    server: process.env.DB_SERVER,
    database: process.env.DB_NAME,
    port: parseInt(process.env.DB_PORT) || 1433,
    options: {
    encrypt: process.env.DB_ENCRYPT === 'true',
    trustServerCertificate: process.env.DB_TRUST_SERVER_CERTIFICATE === 'true',
    enableArithAbort: true
},
pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000
}
};

let pool = null;

async function getConnection() {
try {
    if (pool) {
    return pool;
    }
    pool = await sql.connect(dbConfig);
    console.log('✓ Conexión exitosa a SQL Server');
    return pool;
} catch (error) {
    console.error('✗ Error al conectar con SQL Server:', error);
    throw error;
}
}

module.exports = { sql, getConnection };

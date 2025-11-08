const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const dbPath = path.join(__dirname, '../../database/hospital.db');
let db = null;

function getConnection() {
return new Promise((resolve) => {
    if (db) {
    console.log('✓ SQLite ya conectado');
    return resolve(db);
    }
    db = new sqlite3.Database(dbPath, (err) => {
    if (err) {
        console.error('✗ Error SQLite:', err.message);
    } else {
        console.log('✓ Conexión SQLite exitosa');
    }
    resolve(db);
    });
});
}

async function executeQuery(sql, params = []) {
const database = await getConnection();
return new Promise((resolve, reject) => {
    database.all(sql, params, (err, rows) => {
    if (err) reject(err);
    else resolve(rows || []);
    });
});
}

async function executeRun(sql, params = []) {
const database = await getConnection();
return new Promise((resolve, reject) => {
    database.run(sql, params, function(err) {
    if (err) reject(err);
    else resolve({ lastID: this.lastID });
    });
});
}

module.exports = { getConnection, executeQuery, executeRun };

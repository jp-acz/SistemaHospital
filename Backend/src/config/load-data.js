// Backend/src/config/load-data.js
const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');
const path = require('path');

const dbPath = path.join(__dirname, '../../database/hospital.db');
const db = new sqlite3.Database(dbPath);

function cargarCSV(tabla, archivo) {
const filePath = path.join(__dirname, `../../database/data/${archivo}`);

if (!fs.existsSync(filePath)) {
    console.log(`⚠️ Archivo no encontrado: ${archivo}`);
    return;
}

const lineas = fs.readFileSync(filePath, 'utf-8').split('\n');
const headers = lineas.split(',');

for (let i = 1; i < lineas.length; i++) {
    if (!lineas[i].trim()) continue;
    
    const valores = lineas[i].split(',');
    const placeholders = headers.map(() => '?').join(',');
    const sql = `INSERT INTO ${tabla} (${headers.join(',')}) VALUES (${placeholders})`;
    
    db.run(sql, valores, (err) => {
    if (err && err.code !== 'SQLITE_CONSTRAINT') {
        console.error(`Error insertando en ${tabla}:`, err);
    }
    });
}

console.log(`✓ Datos de ${tabla} cargados`);
}

db.serialize(() => {
cargarCSV('Pacientes', 'pacientes.csv');
cargarCSV('Doctores', 'doctores.csv');
cargarCSV('Citas', 'citas.csv');
cargarCSV('Diagnosticos', 'diagnosticos.csv');
cargarCSV('Seguros', 'seguros.csv');
});

setTimeout(() => db.close(), 2000);

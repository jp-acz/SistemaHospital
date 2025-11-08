const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');
const path = require('path');

const dbPath = path.join(__dirname, '../../database/hospital.db');
const db = new sqlite3.Database(dbPath);

function cargarCSV(tabla, archivo) {
const filePath = path.join(__dirname, `../../database/data/${archivo}`);

if (!fs.existsSync(filePath)) {
    console.log(`⚠️ ${archivo} no encontrado`);
    return;
}

const contenido = fs.readFileSync(filePath, 'utf-8');
const lineas = contenido.toString().split('\n');
const headers = lineas[0].split(',').map(h => h.trim());

for (let i = 1; i < lineas.length; i++) {
    if (!lineas[i].trim()) continue;
    
    const valores = lineas[i].split(',').map(v => v.trim());
    const placeholders = headers.map(() => '?').join(',');
    const sql = `INSERT OR IGNORE INTO ${tabla} (${headers.join(',')}) VALUES (${placeholders})`;
    
    db.run(sql, valores, (err) => {
    if (err && err.code !== 'SQLITE_CONSTRAINT') {
        // Silencioso
    }
    });
}

console.log(`✓ ${tabla} cargado`);
}

db.serialize(() => {
cargarCSV('Pacientes', 'pacientes.csv');
cargarCSV('Doctores', 'doctores.csv');
cargarCSV('Citas', 'citas.csv');
cargarCSV('Diagnosticos', 'diagnosticos.csv');
cargarCSV('Seguros', 'seguros.csv');
});

setTimeout(() => {
console.log('✓ Datos cargados');
db.close();
}, 3000);

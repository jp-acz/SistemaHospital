// database/cargar_datos.js
const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');
const csv = require('csv-parser');
const path = require('path');

const dbPath = path.join(__dirname, 'hospital.db');
const db = new sqlite3.Database(dbPath);

// Cargar pacientes
fs.createReadStream(path.join(__dirname, 'data/pacientes.csv'))
.pipe(csv())
.on('data', (row) => {
    db.run(
    'INSERT INTO Pacientes (ID, nombre, edad, direccion, telefono) VALUES (?, ?, ?, ?, ?)',
    [row.ID, row.nombre, row.edad, row.direccion, row.telefono]
    );
})
.on('end', () => console.log('✓ Pacientes cargados'));

// Repetir para otras tablas...

db.close();

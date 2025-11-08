// Backend/src/config/init-db.js
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, '../../database/hospital.db');

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error:', err);
    return;
  }
  console.log('✓ Conectado a SQLite');
  crearTablas();
});

function crearTablas() {
  db.serialize(() => {
    // Pacientes
    db.run(`
      CREATE TABLE IF NOT EXISTS Pacientes (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        edad INTEGER,
        direccion TEXT,
        telefono TEXT,
        Estado INTEGER DEFAULT 1
      )
    `, (err) => {
      if (err) console.error('Error Pacientes:', err);
      else console.log('✓ Tabla Pacientes creada');
    });

    // Doctores
    db.run(`
      CREATE TABLE IF NOT EXISTS Doctores (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        especialidad TEXT,
        telefono TEXT,
        Estado INTEGER DEFAULT 1
      )
    `, (err) => {
      if (err) console.error('Error Doctores:', err);
      else console.log('✓ Tabla Doctores creada');
    });

    // Citas
    db.run(`
    CREATE TABLE IF NOT EXISTS Citas (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        paciente_id INTEGER,
        doctor_id INTEGER,
        fecha DATE,
        hora TIME,
        FOREIGN KEY (paciente_id) REFERENCES Pacientes(ID),
        FOREIGN KEY (doctor_id) REFERENCES Doctores(ID)
    )
    `, (err) => {
    if (err) console.error('Error Citas:', err);
    else console.log('✓ Tabla Citas creada');
    });

    // Diagnosticos
    db.run(`
    CREATE TABLE IF NOT EXISTS Diagnosticos (
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        cita_id INTEGER,
        diagnostico TEXT,
        tratamiento TEXT,
        FOREIGN KEY (cita_id) REFERENCES Citas(ID)
    )
    `, (err) => {
    if (err) console.error('Error Diagnosticos:', err);
    else console.log('✓ Tabla Diagnosticos creada');
    });

    // Seguros
    db.run(`
    CREATE TABLE IF NOT EXISTS Seguros (
        id_seguro INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT,
        compañia TEXT,
        id_paciente INTEGER,
        FOREIGN KEY (id_paciente) REFERENCES Pacientes(ID)
    )
    `, (err) => {
    if (err) console.error('Error Seguros:', err);
    else console.log('✓ Tabla Seguros creada');
    });
});

setTimeout(() => db.close(), 1000);
}

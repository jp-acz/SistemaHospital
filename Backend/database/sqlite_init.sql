-- database/sqlite_init.sql

CREATE TABLE IF NOT EXISTS Pacientes (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    edad INTEGER,
    direccion TEXT,
    telefono TEXT,
    Estado INTEGER DEFAULT 1
);

CREATE TABLE IF NOT EXISTS Doctores (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    especialidad TEXT,
    telefono TEXT,
    Estado INTEGER DEFAULT 1
);

CREATE TABLE IF NOT EXISTS Citas (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    paciente_id INTEGER,
    doctor_id INTEGER,
    fecha DATE,
    hora TIME,
    FOREIGN KEY (paciente_id) REFERENCES Pacientes(ID),
    FOREIGN KEY (doctor_id) REFERENCES Doctores(ID)
);

CREATE TABLE IF NOT EXISTS Diagnosticos (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    cita_id INTEGER,
    diagnóstico TEXT,
    tratamiento TEXT,
    FOREIGN KEY (cita_id) REFERENCES Citas(ID)
);

CREATE TABLE IF NOT EXISTS Seguros (
    id_seguro INTEGER PRIMARY KEY AUTOINCREMENT,
    tipo TEXT,
    compañia TEXT,
    id_paciente INTEGER,
    FOREIGN KEY (id_paciente) REFERENCES Pacientes(ID)
);

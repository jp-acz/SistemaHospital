-- ========================================
-- SISTEMA HOSPITALARIO - CREAR TABLAS
-- ========================================
USE HospitalDB;
GO

PRINT '📋 Creando tablas...';
GO

-- Tabla: Pacientes
CREATE TABLE Pacientes (
    ID INT PRIMARY KEY IDENTITY(1,1),
    nombre CHAR(80) NOT NULL,
    edad INT NOT NULL,
    direccion VARCHAR(150),
    telefono INT,
    CONSTRAINT CK_Pacientes_Edad CHECK (edad BETWEEN 0 AND 150)
);
GO

-- Tabla: Doctores
CREATE TABLE Doctores (
    ID INT PRIMARY KEY IDENTITY(1,1),
    nombre CHAR(60) NOT NULL,
    especialidad VARCHAR(50) NOT NULL,
    telefono INT
);
GO

-- Tabla: Citas (maestra)
CREATE TABLE Citas (
    ID INT PRIMARY KEY IDENTITY(1,1),
    paciente_id INT NOT NULL,
    doctor_id INT NOT NULL,
    fecha DATETIME NOT NULL,
    CONSTRAINT FK_Citas_Paciente FOREIGN KEY (paciente_id) REFERENCES Pacientes(ID) ON DELETE CASCADE,
    CONSTRAINT FK_Citas_Doctor FOREIGN KEY (doctor_id) REFERENCES Doctores(ID) ON DELETE CASCADE
);
GO

-- Tabla: Diagnosticos (detalle de Citas)
CREATE TABLE Diagnosticos (
    ID INT PRIMARY KEY IDENTITY(1,1),
    id_cita INT NOT NULL,
    diagnostico VARCHAR(200) NOT NULL,
    tratamiento VARCHAR(300),
    CONSTRAINT FK_Diagnosticos_Cita FOREIGN KEY (id_cita) REFERENCES Citas(ID) ON DELETE CASCADE
);
GO

-- Tabla: Seguros
CREATE TABLE Seguros (
    ID INT PRIMARY KEY IDENTITY(1,1),
    compañia VARCHAR(100) NOT NULL,
    id_pac INT NOT NULL,
    CONSTRAINT FK_Seguros_Paciente FOREIGN KEY (id_pac) REFERENCES Pacientes(ID) ON DELETE CASCADE
);
GO

-- Tabla: AuditoriaEliminar (para triggers)
IF OBJECT_ID('AuditoriaEliminar', 'U') IS NULL
BEGIN
    CREATE TABLE AuditoriaEliminar (
        ID INT PRIMARY KEY IDENTITY(1,1),
        tabla VARCHAR(50) NOT NULL,
        registroID INT NOT NULL,
        usuario VARCHAR(100) DEFAULT SYSTEM_USER,
        fechaEliminacion DATETIME DEFAULT GETDATE()
    );
END
GO

-- Índices para optimización
CREATE NONCLUSTERED INDEX IDX_Pacientes_Nombre ON Pacientes(nombre);
CREATE NONCLUSTERED INDEX IDX_Citas_Fecha ON Citas(fecha);
CREATE NONCLUSTERED INDEX IDX_Doctores_Especialidad ON Doctores(especialidad);
GO

PRINT '✓ Todas las tablas creadas correctamente';
GO

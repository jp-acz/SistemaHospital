-- database/scripts/02_crear_tablas_hospital.sql
-- Crear todas las tablas del sistema hospitalario

USE HospitalDB;
GO

-- Tabla de auditoría para triggers
CREATE TABLE LOG_AUDITORIA (
    AuditoriaID INT PRIMARY KEY IDENTITY(1,1),
    TablaAfectada VARCHAR(100) NOT NULL,
    TipoOperacion VARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
    UsuarioOperacion VARCHAR(100) NOT NULL,
    FechaOperacion DATETIME NOT NULL DEFAULT GETDATE(),
    DatosAnteriores NVARCHAR(MAX),
    DatosNuevos NVARCHAR(MAX)
);
GO

-- Tabla: Pacientes
CREATE TABLE Pacientes (
    ID INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    edad INT NOT NULL,
    direccion VARCHAR(200),
    telefono VARCHAR(15),
    FechaRegistro DATETIME NOT NULL DEFAULT GETDATE(),
    Estado BIT NOT NULL DEFAULT 1, -- 1=Activo, 0=Inactivo
    CONSTRAINT CK_Edad CHECK (edad >= 0 AND edad <= 150),
    CONSTRAINT CK_Telefono CHECK (LEN(telefono) >= 7)
);
GO

-- Tabla: Doctores
CREATE TABLE Doctores (
    ID INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    especialidad VARCHAR(100) NOT NULL,
    telefono VARCHAR(15),
    FechaContratacion DATETIME NOT NULL DEFAULT GETDATE(),
    Estado BIT NOT NULL DEFAULT 1, -- 1=Activo, 0=Inactivo
    CONSTRAINT CK_Telefono_Doctores CHECK (LEN(telefono) >= 7)
);
GO

-- Tabla: Citas
CREATE TABLE Citas (
    ID INT PRIMARY KEY IDENTITY(1,1),
    paciente_id INT NOT NULL,
    doctor_id INT NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    estado VARCHAR(20) DEFAULT 'Programada', -- Programada, Completada, Cancelada
    motivo TEXT,
    FechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (paciente_id) REFERENCES Pacientes(ID),
    FOREIGN KEY (doctor_id) REFERENCES Doctores(ID),
    CONSTRAINT CK_FechaCita CHECK (fecha >= CAST(GETDATE() AS DATE))
);
GO

-- Tabla: Diagnósticos
CREATE TABLE Diagnosticos (
    ID INT PRIMARY KEY IDENTITY(1,1),
    cita_id INT NOT NULL,
    diagnostico TEXT NOT NULL,
    tratamiento TEXT NOT NULL,
    medicamentos TEXT,
    recomendaciones TEXT,
    FechaRegistro DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (cita_id) REFERENCES Citas(ID)
);
GO

-- Tabla: Seguros
CREATE TABLE Seguros (
    id_seguro INT PRIMARY KEY IDENTITY(1,1),
    tipo VARCHAR(50) NOT NULL, -- Premium, Estándar, Básico
    compañia VARCHAR(100) NOT NULL,
    id_paciente INT NOT NULL,
    numeroPoliza VARCHAR(50),
    fechaVigencia DATE,
    estado BIT NOT NULL DEFAULT 1, -- 1=Activo, 0=Inactivo
    FechaRegistro DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (id_paciente) REFERENCES Pacientes(ID),
    CONSTRAINT CK_Tipo_Seguro CHECK (tipo IN ('Premium', 'Estándar', 'Básico'))
);
GO

-- Crear índices para optimizar búsquedas
CREATE INDEX IDX_Pacientes_nombre ON Pacientes(nombre);
CREATE INDEX IDX_Doctores_especialidad ON Doctores(especialidad);
CREATE INDEX IDX_Citas_paciente ON Citas(paciente_id);
CREATE INDEX IDX_Citas_doctor ON Citas(doctor_id);
CREATE INDEX IDX_Citas_fecha ON Citas(fecha);
CREATE INDEX IDX_Diagnosticos_cita ON Diagnosticos(cita_id);
CREATE INDEX IDX_Seguros_paciente ON Seguros(id_paciente);
GO

PRINT '✓ Todas las tablas creadas exitosamente';
PRINT '✓ Índices creados para optimización';
GO
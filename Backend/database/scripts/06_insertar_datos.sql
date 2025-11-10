-- database/scripts/06_insertar_datos.sql
USE HospitalDB;
GO

PRINT '';
PRINT '═════════════════════════════════════════════════════════════';
PRINT 'INSERTANDO DATOS DE PRUEBA';
PRINT '═════════════════════════════════════════════════════════════';
PRINT '';
GO

-- Deshabilitar triggers
ALTER TABLE Pacientes DISABLE TRIGGER ALL;
ALTER TABLE Doctores DISABLE TRIGGER ALL;
ALTER TABLE Citas DISABLE TRIGGER ALL;
ALTER TABLE Diagnosticos DISABLE TRIGGER ALL;
ALTER TABLE Seguros DISABLE TRIGGER ALL;
GO

PRINT '⚠️  Triggers deshabilitados temporalmente';
GO

-- INSERTAR PACIENTES
SET IDENTITY_INSERT Pacientes ON;
INSERT INTO Pacientes (ID, nombre, edad, direccion, telefono) VALUES
(1, 'Juan Pérez', 46, 'Calle Principal 123', 5550001),
(2, 'María García', 39, 'Av. Central 456', 5550002),
(3, 'Carlos López', 53, 'Plaza Mayor 789', 5550003),
(4, 'Ana Martínez', 42, 'Calle del Sol 321', 5550004),
(5, 'Roberto Sánchez', 57, 'Av. del Mar 654', 5550005),
(6, 'Isabel Rodríguez', 34, 'Paseo Verde 987', 5550006),
(7, 'Miguel Fernández', 49, 'Calle Rosa 111', 5550007),
(8, 'Laura Jiménez', 40, 'Av. Libertad 222', 5550008),
(9, 'Diego Ruiz', 45, 'Plaza Central 333', 5550009),
(10, 'Sofía Moreno', 51, 'Calle Azul 444', 5550010),
(11, 'Pablo Navarro', 38, 'Av. Real 555', 5550011),
(12, 'Elena Castro', 47, 'Calle Blanca 666', 5550012);
SET IDENTITY_INSERT Pacientes OFF;
GO

PRINT '✓ Pacientes insertados: 12 registros';
GO

-- INSERTAR DOCTORES
SET IDENTITY_INSERT Doctores ON;
INSERT INTO Doctores (ID, nombre, especialidad, telefono) VALUES
(1, 'Dr. Luis Martín', 'Cardiología', 5551001),
(2, 'Dra. Carmen López', 'Pediatría', 5551002),
(3, 'Dr. Antonio Ruiz', 'Neurología', 5551003),
(4, 'Dra. Patricia Gómez', 'Dermatología', 5551004),
(5, 'Dr. Fernando Castro', 'Oncología', 5551005),
(6, 'Dra. Marta Flores', 'Oftalmología', 5551006);
SET IDENTITY_INSERT Doctores OFF;
GO

PRINT '✓ Doctores insertados: 6 registros';
GO

-- INSERTAR CITAS
SET IDENTITY_INSERT Citas ON;
INSERT INTO Citas (ID, paciente_id, doctor_id, fecha) VALUES
(1, 1, 1, '2025-11-10 09:00:00'),
(2, 2, 2, '2025-11-11 10:30:00'),
(3, 3, 1, '2025-11-12 14:00:00'),
(4, 4, 3, '2025-11-13 11:15:00'),
(5, 5, 4, '2025-11-14 15:45:00'),
(6, 6, 2, '2025-11-15 09:30:00'),
(7, 7, 5, '2025-11-16 13:00:00'),
(8, 8, 6, '2025-11-17 10:00:00'),
(9, 9, 1, '2025-11-18 16:30:00'),
(10, 10, 3, '2025-11-19 14:15:00'),
(11, 11, 2, '2025-11-20 09:45:00'),
(12, 12, 4, '2025-11-21 11:30:00'),
(13, 1, 2, '2025-11-22 15:00:00'),
(14, 2, 3, '2025-11-23 10:15:00'),
(15, 3, 5, '2025-11-24 13:30:00');
SET IDENTITY_INSERT Citas OFF;
GO

PRINT '✓ Citas insertadas: 15 registros';
GO

-- INSERTAR DIAGNÓSTICOS
SET IDENTITY_INSERT Diagnosticos ON;
INSERT INTO Diagnosticos (ID, id_cita, diagnostico, tratamiento) VALUES
(1, 1, 'Hipertensión arterial', 'Enalapril 10mg cada 12 horas'),
(2, 2, 'Faringitis aguda', 'Ibuprofeno 400mg cada 8 horas'),
(3, 3, 'Arritmia cardíaca', 'Betabloqueadores y seguimiento'),
(4, 4, 'Migraña crónica', 'Sumatriptán en crisis'),
(5, 5, 'Dermatitis atópica', 'Crema de hidrocortisona'),
(6, 6, 'Bronquitis alérgica', 'Antihistamínicos y broncodilatadores'),
(7, 7, 'Control oncológico', 'Continuar con quimioterapia'),
(8, 8, 'Miopía progresiva', 'Actualización de lentes'),
(9, 9, 'Insuficiencia cardíaca', 'Diuréticos y reposo'),
(10, 10, 'Cefalea tensional', 'Relajantes musculares'),
(11, 11, 'Asma infantil', 'Inhalador de salbutamol'),
(12, 12, 'Psoriasis', 'Fototerapia UVB'),
(13, 13, 'Otitis media', 'Amoxicilina 500mg cada 8 horas'),
(14, 14, 'Epilepsia', 'Ajuste de dosis de anticonvulsivos'),
(15, 15, 'Revisión post-operatoria', 'Evolución satisfactoria');
SET IDENTITY_INSERT Diagnosticos OFF;
GO

PRINT '✓ Diagnósticos insertados: 15 registros';
GO

-- INSERTAR SEGUROS
SET IDENTITY_INSERT Seguros ON;
INSERT INTO Seguros (ID, compañia, id_pac) VALUES
(1, 'MAPFRE', 1),
(2, 'Sanitas', 2),
(3, 'Adeslas', 3),
(4, 'DKV', 4),
(5, 'ASISA', 5),
(6, 'MAPFRE', 6),
(7, 'Sanitas', 7),
(8, 'Adeslas', 8),
(9, 'DKV', 9),
(10, 'ASISA', 10),
(11, 'MAPFRE', 11),
(12, 'Sanitas', 12);
SET IDENTITY_INSERT Seguros OFF;
GO

PRINT '✓ Seguros insertados: 12 registros';
GO

-- Rehabilitar triggers
ALTER TABLE Pacientes ENABLE TRIGGER ALL;
ALTER TABLE Doctores ENABLE TRIGGER ALL;
ALTER TABLE Citas ENABLE TRIGGER ALL;
ALTER TABLE Diagnosticos ENABLE TRIGGER ALL;
ALTER TABLE Seguros ENABLE TRIGGER ALL;
GO

PRINT '✓ Triggers rehabilitados';
PRINT '';
PRINT '═════════════════════════════════════════════════════════════';
PRINT '✅ TODOS LOS DATOS INSERTADOS CORRECTAMENTE';
PRINT '═════════════════════════════════════════════════════════════';
PRINT '';
GO

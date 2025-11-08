-- database/scripts/01_crear_bd_hospital.sql
-- Crear base de datos de Hospital

USE master;
GO

-- Eliminar BD si existe
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'HospitalDB')
BEGIN
    ALTER DATABASE HospitalDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HospitalDB;
END
GO

-- Crear la base de datos
CREATE DATABASE HospitalDB;
GO

USE HospitalDB;
GO

PRINT '✓ Base de datos HospitalDB creada exitosamente';
GO
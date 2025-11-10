const express = require('express');
const router = express.Router();
const { executeQuery } = require('../config/database');

const tablasConfig = {
    'Pacientes': {
        nombre: 'Pacientes',
        columnas: ['ID', 'nombre', 'edad', 'direccion', 'telefono'],
        descripcion: 'Información de pacientes del hospital'
    },
    'Doctores': {
        nombre: 'Doctores',
        columnas: ['ID', 'nombre', 'especialidad', 'telefono'],
        descripcion: 'Información de doctores y especialidades'
    },
    'Citas': {
        nombre: 'Citas',
        columnas: ['ID', 'paciente_id', 'doctor_id', 'fecha'],
        descripcion: 'Registro de citas médicas'
    },
    'Diagnosticos': {
        nombre: 'Diagnosticos',
        columnas: ['ID', 'id_cita', 'diagnostico', 'tratamiento'],
        descripcion: 'Diagnósticos y tratamientos médicos'
    },
    'Seguros': {
        nombre: 'Seguros',
        columnas: ['ID', 'compañia', 'id_pac'],
        descripcion: 'Seguros médicos de pacientes'
    },
    'AuditoriaEliminar': {
        nombre: 'AuditoriaEliminar',
        columnas: ['ID', 'tabla', 'registroID', 'usuario', 'fechaEliminacion'],
        descripcion: 'Registros de auditoría de eliminaciones'
    }
};

// Endpoint para obtener lista de tablas disponibles
router.get('/', async (req, res) => {
    try {
        const tablas = Object.keys(tablasConfig).map(key => ({
            nombre: tablasConfig[key].nombre,
            descripcion: tablasConfig[key].descripcion,
            columnas: tablasConfig[key].columnas
        }));
        res.json({ success: true, tablas });
    } catch (error) {
        console.error('Error obteniendo lista de tablas:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Endpoint para obtener datos de una tabla específica
router.get('/:tabla', async (req, res) => {
    try {
        const { tabla } = req.params;
        
        if (!tablasConfig[tabla]) {
            return res.status(400).json({
                success: false,
                message: 'Tabla no permitida'
            });
        }

        const config = tablasConfig[tabla];
        const data = await executeQuery(`SELECT * FROM ${tabla}`);
        
        res.json({ 
            success: true, 
            tabla: config.nombre,
            descripcion: config.descripcion,
            columnas: config.columnas,
            data 
        });
    } catch (error) {
        console.error(`Error obteniendo datos de ${req.params.tabla}:`, error);
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;

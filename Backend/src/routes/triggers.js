const express = require('express');
const router = express.Router();
const { executeQuery } = require('../config/database');

// GET - Obtener registros de auditoría de eliminaciones
router.get('/auditoria', async (req, res) => {
    try {
        const query = `
            SELECT TOP 100 
                ID, 
                tabla, 
                registroID, 
                usuario, 
                fechaEliminacion 
            FROM AuditoriaEliminar 
            ORDER BY fechaEliminacion DESC
        `;
        const data = await executeQuery(query);
        
        res.json({
            success: true,
            titulo: 'Auditoría de Eliminaciones',
            descripcion: 'Registros eliminados capturados por triggers',
            data
        });
    } catch (error) {
        console.error('Error en /auditoria:', error);
        res.status(500).json({ 
            success: false, 
            error: error.message 
        });
    }
});

module.exports = router;

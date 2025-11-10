const { executeQuery } = require('../config/database');

// GET ALL
exports.getAll = async (req, res) => {
    try {
        const data = await executeQuery('SELECT ID, nombre, edad, direccion, telefono FROM Pacientes ORDER BY nombre');
        res.json({ success: true, data });
    } catch (error) {
        console.error('Error en getAll:', error);
        res.status(500).json({ success: false, error: error.message });
    }
};

// GET BY ID
exports.getById = async (req, res) => {
    try {
        const { id } = req.params;
        const data = await executeQuery(
            'SELECT ID, nombre, edad, direccion, telefono FROM Pacientes WHERE ID = @id',
            { id }
        );
        
        if (data.length === 0) {
            return res.status(404).json({ success: false, message: 'Paciente no encontrado' });
        }
        
        res.json({ success: true, data: data[0] });
    } catch (error) {
        console.error('Error en getById:', error);
        res.status(500).json({ success: false, error: error.message });
    }
};

// CREATE
exports.create = async (req, res) => {
    try {
        const { nombre, edad, direccion, telefono } = req.body;
        
        if (!nombre || !edad) {
            return res.status(400).json({ success: false, message: 'Nombre y edad son obligatorios' });
        }

        const query = `
            INSERT INTO Pacientes (nombre, edad, direccion, telefono)
            VALUES (@nombre, @edad, @direccion, @telefono);
            SELECT ID, nombre, edad, direccion, telefono 
            FROM Pacientes WHERE ID = SCOPE_IDENTITY();
        `;
        
        const result = await executeQuery(query, { 
            nombre, 
            edad: parseInt(edad), 
            direccion: direccion || null, 
            telefono: telefono ? parseInt(telefono) : null 
        });
        
        res.json({ success: true, data: result[0], message: 'Paciente creado' });
    } catch (error) {
        console.error('Error en create:', error);
        res.status(500).json({ success: false, error: error.message });
    }
};

// UPDATE
exports.update = async (req, res) => {
    try {
        const { id } = req.params;
        const { nombre, edad, direccion, telefono } = req.body;
        
        const query = `
            UPDATE Pacientes 
            SET nombre = @nombre, edad = @edad, direccion = @direccion, telefono = @telefono
            WHERE ID = @id;
            SELECT ID, nombre, edad, direccion, telefono FROM Pacientes WHERE ID = @id;
        `;
        
        const result = await executeQuery(query, { 
            id: parseInt(id), 
            nombre, 
            edad: parseInt(edad), 
            direccion, 
            telefono: telefono ? parseInt(telefono) : null 
        });
        
        if (result.length === 0) {
            return res.status(404).json({ success: false, message: 'Paciente no encontrado' });
        }
        
        res.json({ success: true, data: result[0], message: 'Paciente actualizado' });
    } catch (error) {
        console.error('Error en update:', error);
        res.status(500).json({ success: false, error: error.message });
    }
};

// DELETE
exports.delete = async (req, res) => {
    try {
        const { id } = req.params;
        await executeQuery('DELETE FROM Pacientes WHERE ID = @id', { id: parseInt(id) });
        res.json({ success: true, message: 'Paciente eliminado' });
    } catch (error) {
        console.error('Error en delete:', error);
        res.status(500).json({ success: false, error: error.message });
    }
};

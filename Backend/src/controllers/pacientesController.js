// Backend/src/controllers/pacientesController.js
const { executeQuery, executeRun } = require('../config/database');

class PacientesController {
  async create(req, res) {
    try {
      const { nombre, edad, direccion, telefono } = req.body;
      const result = await executeRun(
        'INSERT INTO Pacientes (nombre, edad, direccion, telefono) VALUES (?, ?, ?, ?)',
        [nombre, edad, direccion, telefono]
      );
      res.status(201).json({
        success: true,
        message: 'Paciente creado exitosamente',
        data: { ID: result.lastID, nombre, edad, direccion, telefono }
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: 'Error al crear paciente',
        error: error.message
      });
    }
  }

  async getAll(req, res) {
    try {
      const result = await executeQuery('SELECT * FROM Pacientes WHERE Estado = 1');
      res.status(200).json({
        success: true,
        data: result
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: 'Error al obtener pacientes',
        error: error.message
      });
    }
  }

  async getById(req, res) {
    try {
      const { id } = req.params;
      const result = await executeQuery('SELECT * FROM Pacientes WHERE ID = ? AND Estado = 1', [id]);
      if (result.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Paciente no encontrado'
        });
      }
      res.status(200).json({
        success: true,
        data: result
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: 'Error al obtener paciente',
        error: error.message
      });
    }
  }

  async update(req, res) {
    try {
      const { id } = req.params;
      const { nombre, edad, direccion, telefono } = req.body;
      await executeRun(
        'UPDATE Pacientes SET nombre = ?, edad = ?, direccion = ?, telefono = ? WHERE ID = ?',
        [nombre, edad, direccion, telefono, id]
      );
      res.status(200).json({
        success: true,
        message: 'Paciente actualizado exitosamente',
        data: { ID: id, nombre, edad, direccion, telefono }
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: 'Error al actualizar paciente',
        error: error.message
      });
    }
  }

  async delete(req, res) {
    try {
      const { id } = req.params;
      await executeRun('UPDATE Pacientes SET Estado = 0 WHERE ID = ?', [id]);
      res.status(200).json({
        success: true,
        message: 'Paciente eliminado exitosamente'
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: 'Error al eliminar paciente',
        error: error.message
      });
    }
  }
}

module.exports = new PacientesController();

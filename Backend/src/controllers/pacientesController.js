// src/controllers/pacientesController.js
const { executeProcedure } = require('../config/database');

class PacientesController {
  async create(req, res) {
    try {
      const { nombre, edad, direccion, telefono } = req.body;
      const result = await executeProcedure('sp_Pacientes_Create', {
        nombre,
        edad,
        direccion,
        telefono
      });
      res.status(201).json({
        success: true,
        message: 'Paciente creado exitosamente',
        data: result[0]
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
      const result = await executeProcedure('sp_Pacientes_ReadAll');
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
      const result = await executeProcedure('sp_Pacientes_ReadById', { ID: id });
      if (result.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Paciente no encontrado'
        });
      }
      res.status(200).json({
        success: true,
        data: result[0]
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
      const result = await executeProcedure('sp_Pacientes_Update', {
        ID: id,
        nombre,
        edad,
        direccion,
        telefono
      });
      res.status(200).json({
        success: true,
        message: 'Paciente actualizado exitosamente',
        data: result[0]
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
      await executeProcedure('sp_Pacientes_Delete', { ID: id });
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
const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/crudController');

router.get('/:tabla', ctrl.readAll);
router.get('/:tabla/:id', ctrl.readById);
router.post('/:tabla', ctrl.create);
router.put('/:tabla/:id', ctrl.update);
router.delete('/:tabla/:id', ctrl.remove);

module.exports = router; 

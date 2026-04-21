const express = require('express');
const router = express.Router();
const verifyToken = require('../middlewares/authMiddleware');
const patientController = require('../controllers/patientController');

// Protect all patient routes with the "Lock" (verifyToken)
router.get('/', verifyToken, patientController.getPatients);
router.post('/', verifyToken, patientController.addPatient);
router.get('/:id/screenings', verifyToken, patientController.getPatientScreenings);
router.delete('/:id', verifyToken, patientController.deletePatient);

module.exports = router;

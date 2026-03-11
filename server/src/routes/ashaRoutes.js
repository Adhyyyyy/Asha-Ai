const express = require('express');
const router = express.Router();
const verifyToken = require('../middlewares/authMiddleware');
const ashaController = require('../controllers/ashaController');

// Protect all asha routes with verifyToken
router.get('/stats', verifyToken, ashaController.getAshaStats);

module.exports = router;

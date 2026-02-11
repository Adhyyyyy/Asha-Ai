const express = require('express');
const router = express.Router();
const verifyToken = require('../middlewares/authMiddleware');
const aiController = require('../controllers/aiController');

// The "Crystal Ball" Endpoint
// Protected by Auth Lock 🔒
router.post('/predict', verifyToken, aiController.analyzeHealth);

module.exports = router;

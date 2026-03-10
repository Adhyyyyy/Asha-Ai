const express = require('express');
const router = express.Router();
const verifyToken = require('../middlewares/authMiddleware');
const aiController = require('../controllers/aiController');

const upload = require('../middlewares/uploadMiddleware');

// The "Crystal Ball" Endpoint
// Protected by Auth Lock 🔒
// upload.single('file') expects the client to send a file named 'file'
router.post('/predict', verifyToken, upload.single('file'), aiController.analyzeHealth);

module.exports = router;

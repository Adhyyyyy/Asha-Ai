const express = require('express');
const router = express.Router();
const verifyToken = require('../middlewares/authMiddleware');
const adminController = require('../controllers/adminController');


router.get('/stats', verifyToken, adminController.getDashboardStats);


router.get('/dashboard', verifyToken, (req, res) => {
    res.status(200).json({
        message: `Welcome Admin! You are authenticated.`,
        user_id: req.user.uid,
        role: 'ADMIN_ACCESS_GRANTED'
    });
});

// ASHA Worker Management
router.get('/ashas', verifyToken, adminController.getAshas);
router.post('/ashas', verifyToken, adminController.createAsha);
router.put('/ashas/:id', verifyToken, adminController.updateAsha);
router.delete('/ashas/:id', verifyToken, adminController.deleteAsha);

// Screening History
router.get('/screenings', verifyToken, adminController.getScreenings);

module.exports = router;
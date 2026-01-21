const express = require('express');
const router = express.Router();
const verifyToken = require('../middlewares/authMiddleware');

router.get('/dashboard', verifyToken, (req, res) => {
    res.status(200).json({
        message: `Welcome Admin! You are authenticated.`,
        user_id: req.user.uid,
        role: 'ADMIN_ACCESS_GRANTED'
    });
});

module.exports = router;
const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
    const tokenHeader = req.headers.authorization;

    // 1. Check if token exists
    if (!tokenHeader || !tokenHeader.startsWith('Bearer ')) {
        return res.status(401).json({
            success: false,
            message: 'Unauthorized: No token provided'
        });
    }

    const token = tokenHeader.split(' ')[1];

    try {
        // 2. Verify Custom JWT (The Key we made in authController)
        const JWT_SECRET = process.env.JWT_SECRET || 'asha_ai_dev_secret_key_123';
        const decoded = jwt.verify(token, JWT_SECRET);

        // 3. Attach user info
        req.user = decoded;

        next();
    } catch (error) {
        console.error('Auth Error:', error.message);
        return res.status(403).json({
            success: false,
            message: 'Forbidden: Invalid token'
        });
    }
};

module.exports = verifyToken;
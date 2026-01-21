const { admin } = require('../config/firebase');

const verifyToken = async (req, res, next) => {
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
        // 2. Verify token with Firebase
        const decodedToken = await admin.auth().verifyIdToken(token);

        // 3. Attach user info to request (so Controllers can use it)
        req.user = decodedToken;

        // 4. Allow them to pass
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
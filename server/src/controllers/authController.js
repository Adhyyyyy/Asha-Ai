const jwt = require('jsonwebtoken');

// HARDCODED ADMIN (For testing only!)
const MOCK_ADMIN = {
    username: 'admin',
    password: 'password123',
    role: 'ADMIN',
    uid: 'admin_001'
};

exports.login = async (req, res) => {
    try {
        const { username, password } = req.body;

        // 1. Check Credentials
        if (username !== MOCK_ADMIN.username || password !== MOCK_ADMIN.password) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        // 2. Secret Key (Use env variable or fallback for dev)
        const JWT_SECRET = process.env.JWT_SECRET || 'asha_ai_dev_secret_key_123';

        // 3. Generate Token
        const token = jwt.sign(
            { uid: MOCK_ADMIN.uid, role: MOCK_ADMIN.role },
            JWT_SECRET,
            { expiresIn: '1d' }
        );

        // 4. Send Response (Must match what Flutter expects!)
        res.status(200).json({
            message: 'Login successful',
            token: token,
            role: MOCK_ADMIN.role // Dart code looks for result['role']
        });

    } catch (error) {
        console.error('Error logging in:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

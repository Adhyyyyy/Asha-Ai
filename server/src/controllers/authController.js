const jwt = require('jsonwebtoken');

// HARDCODED ADMIN (For testing only!)
const MOCK_ADMIN = {
    username: 'admin',
    password: 'password123',
    role: 'ADMIN',
    uid: 'admin_001'
};

// HARDCODED ASHA (For testing only!)
const MOCK_ASHA = {
    username: 'sita.asha',
    password: 'password123',
    role: 'ASHA',
    uid: 'asha_001'
};

const { db } = require('../config/firebase'); // Need Firestore access

exports.login = async (req, res) => {
    try {
        const { username, password } = req.body;

        let userToLogin = null;

        // 1. Check SuperAdmin (Hardcoded)
        if (username === MOCK_ADMIN.username && password === MOCK_ADMIN.password) {
            userToLogin = MOCK_ADMIN;
        } else {
            // 2. Check Firestore for ASHA worker
            const snapshot = await db.collection('users')
                .where('username', '==', username)
                .where('password', '==', password)
                .get();

            if (!snapshot.empty) {
                const doc = snapshot.docs[0];
                const data = doc.data();
                userToLogin = {
                    uid: doc.id,
                    username: data.username,
                    role: data.role,
                    area: data.area
                };
            }
        }

        if (!userToLogin) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        // 2. Secret Key (Use env variable or fallback for dev)
        const JWT_SECRET = process.env.JWT_SECRET || 'asha_ai_dev_secret_key_123';

        // 3. Generate Token
        const token = jwt.sign(
            { uid: userToLogin.uid, role: userToLogin.role },
            JWT_SECRET,
            { expiresIn: '1d' }
        );

        // 4. Send Response (Must match what Flutter expects!)
        res.status(200).json({
            message: 'Login successful',
            token: token,
            role: userToLogin.role // Dart code looks for result['role']
        });

    } catch (error) {
        console.error('Error logging in:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

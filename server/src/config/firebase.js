const admin = require('firebase-admin');
const dotenv = require('dotenv');

dotenv.config();

// Initialize Firebase Admin
// In production, we use a service account file.
// For this prototype, we will just initialize properly once we have the file.

try {
    admin.initializeApp({
        credential: admin.credential.applicationDefault(),
        // OR: admin.credential.cert(require('./path-to-key.json'))
    });
    console.error('Firebase Admin initialized successfully');
} catch (error) {
    console.error('Firebase Admin initialization error:', error.message);
    // We don't crash the server, but DB features won't work yet.
}

const db = admin.firestore();
const auth = admin.auth();

module.exports = { db, auth, admin };
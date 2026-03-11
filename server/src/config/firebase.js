const admin = require('firebase-admin');
const dotenv = require('dotenv');

dotenv.config();

// Initialize Firebase Admin
// We are now using the real service account file!
const serviceAccount = require('../../serviceAccountKey.json');

try {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        storageBucket: 'asha-ai-30512.appspot.com'
    });
    console.log('🔥 Firebase Admin connected to Real Database successfully!');
} catch (error) {
    console.error('Firebase Admin initialization error:', error.message);
    // We don't crash the server, but DB features won't work yet.
}

const db = admin.firestore();
const auth = admin.auth();
const bucket = admin.storage().bucket();

module.exports = { db, auth, admin, bucket };
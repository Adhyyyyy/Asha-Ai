const admin = require('firebase-admin');
const dotenv = require('dotenv');

dotenv.config();

// Initialize Firebase Admin
// We are now using the real service account file!
const serviceAccount = require('../../serviceAccountKey.json');

let db, auth, bucket;

try {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        storageBucket: 'asha-ai-30512.appspot.com'
    });
    console.log('🔥 Firebase Admin connected to Real Database successfully!');
    
    // Initialize services inside the try block to catch potential boot errors
    db = admin.firestore();
    auth = admin.auth();
    bucket = admin.storage().bucket();
    
} catch (error) {
    console.error('❌ Firebase Admin initialization error:', error.message);
    // If initialization fails, we shouldn't continue trying to use db/auth/bucket later
}

module.exports = { db, auth, admin, bucket };
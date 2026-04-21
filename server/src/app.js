/* src/app.js */

// 1. IMPORT TOOLS
const express = require('express');
const cors = require('cors');

// 2. CREATE THE APP
const app = express();

require('./config/firebase');

// 3. MIDDLEWARE (The Security Guards)
// Allow standard JSON payloads (so we can read req.body)
app.use(express.json());
// Allow requests from other domains (like our Flutter app)
app.use(cors());

app.use('/api/health', require('./routes/healthRoutes'));
app.use('/api/admin', require('./routes/adminRoutes'));
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/patients', require('./routes/patientRoutes'));
app.use('/api/asha', require('./routes/ashaRoutes'));
app.use('/api/ai', require('./routes/aiRoutes'));

// 5. START SERVER
const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, '0.0.0.0', () => {
    console.log(`\n🚀 ASHA-AI Backend running on http://localhost:${PORT}`);
    console.log(`👉 Environment: Development Mode`);
});

// Catch server errors (like port already in use)
server.on('error', (err) => {
    console.error('❌ SERVER ERROR:', err.message);
    if (err.code === 'EADDRINUSE') {
        console.error(`Port ${PORT} is already in use by another program.`);
    }
});

// Track if anything is killing the process
process.on('uncaughtException', (err) => {
    console.error('❌ UNCAUGHT EXCEPTION:', err.stack);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('❌ UNHANDLED REJECTION:', reason);
});

process.on('exit', (code) => {
    console.log(`\n⚠️  Node process exited with code: ${code}`);
});
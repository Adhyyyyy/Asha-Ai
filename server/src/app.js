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
app.listen(PORT, () => {
    console.log(`\n🚀 ASHA-AI Backend running on http://localhost:${PORT}`);
    console.log(`👉 Environment: Development Mode`);
});
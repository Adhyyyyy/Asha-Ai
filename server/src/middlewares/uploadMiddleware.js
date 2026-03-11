const multer = require('multer');

// Configure Memory Storage (Keep file in memory buffer so we can push directly to Firebase)
const storage = multer.memoryStorage();

// Create Middleware
const upload = multer({ storage: storage });

module.exports = upload;

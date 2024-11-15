const express = require('express');
const multer = require('multer');
const fs = require('fs').promises;
const path = require('path');
const cors = require('cors');
const Image = require('../models/Image');
const router = express.Router();

// Enable CORS for all routes
router.use(cors({
  origin: '*', // Allow all origins for development; restrict in production
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type'],
}));

// Ensure uploads directory exists
const UPLOAD_DIR = path.join(__dirname, '../uploads/');
(async () => {
  try {
    await fs.mkdir(UPLOAD_DIR, { recursive: true });
    console.log('Uploads directory verified.');
  } catch (err) {
    console.error('Error creating uploads directory:', err);
  }
})();

// Multer storage configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, UPLOAD_DIR);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = `${Date.now()}-${file.originalname}`;
    cb(null, uniqueSuffix);
  },
});

// Multer setup without file filtering
const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
});

// POST /api/upload
router.post('/', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      console.error('No file uploaded');
      return res.status(400).json({ message: 'No file uploaded.' });
    }

    const { userId } = req.body;
    if (!userId) {
      console.error('User ID is required but missing');
      return res.status(400).json({ message: 'User ID is required.' });
    }

    const filePath = path.join(UPLOAD_DIR, req.file.filename);

    // Read file and convert to Base64
    const fileBuffer = await fs.readFile(filePath);
    const imageBase64 = fileBuffer.toString('base64');

    // Save file information to MongoDB
    const newImage = new Image({
      userId,
      filename: req.file.filename,
      contentType: req.file.mimetype,
      filePath: filePath,
      imageBase64, // Include Base64 data
    });

    await newImage.save();
    console.log('Image saved to MongoDB:', newImage);

    // Respond to the client
    res.status(201).json({ message: 'Image uploaded successfully!' });
  } catch (error) {
    console.error('Error uploading image:', error);
    res.status(500).json({ message: 'Image upload failed.', error: error.message });
  }
});

// Error handling for multer and other errors
router.use((err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    console.error('Multer error:', err.message);
    return res.status(400).json({ message: err.message });
  }
  if (err) {
    console.error('Unhandled error:', err.message);
    return res.status(500).json({ message: err.message });
  }
  next();
});

module.exports = router;

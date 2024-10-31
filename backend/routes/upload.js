const express = require('express');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const Image = require('../models/Image'); // Ensure the path to the Image model is correct
const router = express.Router();

// Ensure 'uploads/' folder exists or create it
const UPLOAD_DIR = path.join(__dirname, '../uploads/');
if (!fs.existsSync(UPLOAD_DIR)) {
  console.log('Creating uploads directory'); // Log folder creation
  fs.mkdirSync(UPLOAD_DIR);
}

// Configure Multer storage with logging for debugging
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    console.log('Saving file to uploads/ folder'); // Log destination
    cb(null, UPLOAD_DIR); // Save to uploads directory
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = `${Date.now()}-${file.originalname}`;
    console.log('File saved with name:', uniqueSuffix); // Log filename
    cb(null, uniqueSuffix); // Ensure unique filenames
  },
});

// File filter to ensure only images are allowed
const fileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith('image/')) {
    cb(null, true); // Accept the file
  } else {
    console.error('Invalid file type:', file.mimetype); // Log invalid file type
    cb(new Error('Invalid file type. Only images are allowed.'), false);
  }
};

// Multer configuration with storage, file filter, and size limit
const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB size limit
});

// POST /api/upload - Upload and store the image
router.post('/upload', upload.single('file'), async (req, res) => {
  try {
    console.log('Received file:', req.file); // Log the received file details

    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded.' });
    }

    const filePath = path.join(UPLOAD_DIR, req.file.filename);
    console.log('Reading file from:', filePath); // Log the file path

    const fileData = fs.readFileSync(filePath); // Read the uploaded file
    const base64Image = fileData.toString('base64'); // Convert to Base64

    // Create a new image document in MongoDB
    const newImage = new Image({
      userId: req.body.userId, // Assuming userId is sent in the request body
      filename: req.file.filename,
      contentType: req.file.mimetype,
      imageBase64: base64Image,
    });

    await newImage.save(); // Save the image to MongoDB
    console.log('Image saved to MongoDB:', newImage); // Log the saved image

    fs.unlinkSync(filePath); // Remove the file from 'uploads/' to save space

    res.status(201).json({ message: 'Image uploaded successfully!' });
  } catch (error) {
    console.error('Upload error:', error); // Log the error

    // Cleanup the file if it was saved but an error occurred
    if (req.file) {
      const filePath = path.join(UPLOAD_DIR, req.file.filename);
      if (fs.existsSync(filePath)) {
        console.log('Removing file due to error:', filePath); // Log file removal
        fs.unlinkSync(filePath);
      }
    }

    res.status(500).json({ message: 'Image upload failed.' });
  }
});

// Handle Multer-specific errors
router.use((err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    console.error('Multer error:', err); // Log Multer errors
    return res.status(400).json({ message: err.message });
  } else if (err) {
    console.error('Unexpected error:', err); // Log unexpected errors
    return res.status(500).json({ message: 'An unexpected error occurred.' });
  }
  next();
});

module.exports = router;

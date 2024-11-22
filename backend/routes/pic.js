const express = require('express');
const router = express.Router();
const multer = require('multer');
const Pic = require('../models/pics'); // Assuming you have a Pic model

// Configure multer to store the file in memory as a Buffer
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

// Route to upload a profile picture
router.post('/upload', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const newPic = new Pic({
      userId: req.user.id, // Assuming you have user authentication and req.user.id holds the user's ID
      imageData: req.file.buffer, // Store the image data as a Buffer
      contentType: req.file.mimetype,
    });

    await newPic.save();
    res.status(201).json({ message: 'Profile picture uploaded successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to upload profile picture' });
  }
});

// Route to get the profile picture
router.get('/photo', async (req, res) => {
  try {
    const pic = await Pic.findOne({ userId: req.user.id }); // Fetch the picture for the logged-in user

    if (!pic) {
      return res.status(404).json({ error: 'Profile picture not found' });
    }

    res.set('Content-Type', pic.contentType);
    res.send(pic.imageData); // Send the Buffer directly
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to retrieve profile picture' });
  }
});

module.exports = router;
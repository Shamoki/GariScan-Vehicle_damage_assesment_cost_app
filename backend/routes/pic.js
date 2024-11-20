const express = require("express");
const multer = require("multer");
const mongoose = require("mongoose");
const cors = require("cors");
const Image = require("../models/Image");

const router = express.Router();

// Use CORS for all routes
router.use(cors());

// Multer setup: Store files in memory temporarily
const storage = multer.memoryStorage();
const upload = multer({ storage });

// POST /upload - Upload a profile picture
router.post("/upload", upload.single("file"), async (req, res) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({ msg: "User ID is required" });
    }

    if (!req.file) {
      return res.status(400).json({ msg: "No file uploaded" });
    }

    // Save the image metadata and binary data
    const newImage = new Image({
      filename: req.file.originalname,
      contentType: req.file.mimetype,
      data: req.file.buffer,
      userId: mongoose.Types.ObjectId(userId),
    });

    await newImage.save();

    res.status(201).json({ msg: "Profile photo uploaded successfully", imageId: newImage._id });
  } catch (err) {
    console.error("Upload error:", err.message);
    res.status(500).send("Server error");
  }
});

// GET /photo/:id - Retrieve an image by its ID
router.get("/photo/:id", async (req, res) => {
  try {
    const image = await Image.findById(req.params.id);

    if (!image) {
      return res.status(404).json({ msg: "Image not found" });
    }

    // Set headers for the image response
    res.set("Content-Type", image.contentType);
    res.send(image.data);
  } catch (err) {
    console.error("Retrieval error:", err.message);
    res.status(500).send("Server error");
  }
});

// GET /user/:userId - Retrieve the latest profile photo for a user
router.get("/user/:userId", async (req, res) => {
  try {
    const image = await Image.findOne({ userId: req.params.userId })
      .sort({ createdAt: -1 }); // Get the latest image

    if (!image) {
      return res.status(404).json({ msg: "No profile photo found for this user" });
    }

    // Set headers for the image response
    res.set("Content-Type", image.contentType);
    res.send(image.data);
  } catch (err) {
    console.error("User image retrieval error:", err.message);
    res.status(500).send("Server error");
  }
});

module.exports = router;

const express = require("express");
const multer = require("multer");
const mongoose = require("mongoose");
const cors = require("cors");
const Image = require("../models/Image");

const router = express.Router();

// Use CORS for all routes within this router
router.use(cors());

// Multer setup to handle file uploads in memory
const storage = multer.memoryStorage(); // Store files in memory temporarily
const upload = multer({ storage });

// POST /upload - Upload an image
router.post("/", upload.single("file"), async (req, res) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({ msg: "User ID is required" });
    }

    if (!req.file) {
      return res.status(400).json({ msg: "No file uploaded" });
    }

    // Save image metadata and binary data to the Images collection
    const newImage = new Image({
      filename: req.file.originalname,
      contentType: req.file.mimetype,
      data: req.file.buffer, // Binary file data
      userId: userId,
    });

    await newImage.save();

    // Log a message on successful upload
    console.log(`Image uploaded: ${newImage.filename}, Size: ${req.file.size} bytes, Uploaded by User ID: ${userId}`);

    res.status(201).json({ msg: "Image uploaded successfully", imageId: newImage._id });
  } catch (err) {
    console.error("Upload error:", err.message);
    res.status(500).send("Server error");
  }
});

// GET /:id - Retrieve an image by ID
router.get("/:id", async (req, res) => {
  try {
    const image = await Image.findById(req.params.id);

    if (!image) {
      return res.status(404).json({ msg: "Image not found" });
    }

    // Set headers for image response
    res.set("Content-Type", image.contentType);
    res.send(image.data);
  } catch (err) {
    console.error("Retrieval error:", err.message);
    res.status(500).send("Server error");
  }
});

module.exports = router;

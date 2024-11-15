const mongoose = require('mongoose');

const ImageSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, required: true, ref: 'User' },
  filename: { type: String, required: true },
  contentType: { type: String, required: true },
  imageBase64: { type: String, required: true },
  uploadedAt: { type: Date, default: Date.now }, // Automatically set on creation
});

// Export the Image model
module.exports = mongoose.model('Image', ImageSchema);

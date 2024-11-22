const mongoose = require('mongoose');

const picSchema = new mongoose.Schema({
  userId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true 
  },
  imageData: { 
    type: Buffer, 
    required: true 
  },
  contentType: { 
    type: String, 
    required: true 
  },
});

module.exports = mongoose.model('Pic', picSchema);
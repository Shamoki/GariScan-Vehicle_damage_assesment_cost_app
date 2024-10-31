require('dotenv').config();  // Load environment variables
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');  // CORS middleware
const authRoutes = require('./routes/auth');  // Import auth routes
const uploadRoutes = require('./routes/upload');  // Import upload routes

const app = express();

// Enable CORS with configuration (restrict origin in production)
app.use(cors({
  origin: '*',  // Allow all origins (adjust this in production)
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Middleware to parse JSON requests
app.use(express.json());

// MongoDB Atlas Connection
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB connected successfully'))
  .catch((err) => {
    console.error('MongoDB connection error:', err);
    process.exit(1);  // Exit process if connection fails
  });

// Log MongoDB connection status
mongoose.connection.on('connected', () => {
  console.log('Mongoose connected to MongoDB');
});

mongoose.connection.on('error', (err) => {
  console.error('Mongoose connection error:', err);
});

// Routes
app.use('/api/auth', authRoutes);  // Authentication routes
app.use('/api/upload', uploadRoutes);  // Upload routes

// Start the server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

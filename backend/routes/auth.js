const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { generateAndSendOTP, verifyOTP } = require('../services/emailOTPService');
const cors = require('cors');
const router = express.Router();

// Use CORS for all routes
router.use(cors());

// POST /signup - User signup
router.post('/signup', async (req, res) => {
  const { username, email, password } = req.body;

  try {
    if (!username || !email || !password) {
      return res.status(400).json({ msg: 'All fields are required' });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ msg: 'User already exists' });
    }

    // Generate and send OTP
    await generateAndSendOTP(email);

    // Save user details
    const user = new User({ username, email, password });
    await user.save();

    res.status(201).json({ msg: 'OTP sent to your email' });
  } catch (err) {
    console.error('Signup error:', err.message);
    res.status(500).send('Server error');
  }
});

// POST /verify-otp - Verify OTP
router.post('/verify-otp', async (req, res) => {
  const { email, otp } = req.body;

  try {
    await verifyOTP(email, otp);

    // Mark user email as verified
    await User.findOneAndUpdate({ email }, { isEmailVerified: true });

    res.status(200).json({ msg: 'Email verified successfully' });
  } catch (err) {
    console.error('OTP verification error:', err.message);
    res.status(400).json({ msg: 'Invalid or expired OTP' });
  }
});

// POST /login - User login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ msg: 'Invalid credentials' });
    }

    if (!user.isEmailVerified) {
      return res.status(403).json({ msg: 'Email is not verified' });
    }

    const isMatch = await user.verifyPassword(password);
    if (!isMatch) {
      return res.status(400).json({ msg: 'Invalid credentials' });
    }

    const payload = { userId: user.id };
    const token = jwt.sign(payload, process.env.SECRET_KEY || 'defaultsecret', { expiresIn: '1h' });

    res.status(200).json({
      token,
      userId: user.id,
      user: { username: user.username, email: user.email },
    });
  } catch (err) {
    console.error('Login error:', err.message);
    res.status(500).send('Server error');
  }
});

// Export the router
module.exports = router;

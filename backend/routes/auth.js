const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { generateAndSendOTP, verifyOTP } = require('../services/emailOTPService');
const cors = require('cors');
const router = express.Router();

// Use CORS for all routes
router.use(cors());

// Temporary storage for unverified users
let pendingUsers = {};

// POST /signup - Generate OTP and save user details temporarily
router.post('/signup', async (req, res) => {
  const { username, email, password } = req.body;

  try {
    // Validate inputs
    if (!username || !email || !password) {
      return res.status(400).json({ msg: 'All fields are required.' });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ msg: 'User already registered. Please log in.' });
    }

    // Generate and send OTP
    console.log(`Generating OTP for email: ${email}`);
    await generateAndSendOTP(email);

    // Save user details temporarily in memory
    pendingUsers[email] = { username, email, password };
    console.log(`User details temporarily saved: ${JSON.stringify(pendingUsers[email])}`);

    res.status(201).json({ msg: 'OTP sent to your email for verification.' });
  } catch (err) {
    console.error('Signup error:', err.message);
    res.status(500).json({ msg: 'Error sending OTP. Please try again later.' });
  }
});

// POST /verify-otp - Verify OTP and register user
router.post('/verify-otp', async (req, res) => {
  const { email, otp } = req.body;

  try {
    // Validate inputs
    if (!email || !otp) {
      return res.status(400).json({ msg: 'Email and OTP are required.' });
    }

    // Verify the OTP
    console.log(`Verifying OTP for email: ${email}`);
    await verifyOTP(email, otp);

    // Retrieve user details from temporary storage
    const userDetails = pendingUsers[email];
    if (!userDetails) {
      return res.status(400).json({ msg: 'User details not found. Please sign up again.' });
    }

    // Save verified user to the database
    const user = new User(userDetails);
    user.isEmailVerified = true; // Mark email as verified
    await user.save();
    console.log(`User successfully registered: ${email}`);

    // Remove user from temporary storage
    delete pendingUsers[email];

    res.status(201).json({ msg: 'Account created successfully. You can now log in.' });
  } catch (err) {
    console.error('OTP verification error:', err.message);
    res.status(400).json({ msg: 'Invalid or expired OTP. Please try again.' });
  }
});

// POST /login - User login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    // Find user in the database
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ msg: 'Invalid credentials. Please try again.' });
    }

    // Ensure email is verified
    if (!user.isEmailVerified) {
      return res.status(403).json({ msg: 'Email not verified. Please verify before logging in.' });
    }

    // Verify password
    const isMatch = await user.verifyPassword(password);
    if (!isMatch) {
      return res.status(400).json({ msg: 'Invalid credentials. Please try again.' });
    }

    // Generate a JWT token
    const payload = { userId: user.id };
    const token = jwt.sign(payload, process.env.SECRET_KEY || 'defaultsecret', { expiresIn: '1h' });

    console.log(`User logged in: ${email}`);
    res.status(200).json({
      token,
      userId: user.id,
      user: { username: user.username, email: user.email },
    });
  } catch (err) {
    console.error('Login error:', err.message);
    res.status(500).json({ msg: 'Server error. Please try again later.' });
  }
});

module.exports = router;

const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');  
const router = express.Router();
const cors = require('cors');  // CORS middleware

// Use CORS only for this route
router.use(cors());

// POST /signup - User sign-up
router.post('/signup', async (req, res) => {
  const { username, email, password } = req.body;

  try {
    console.log('Signup request received:', req.body);

    // Check if the user already exists
    let user = await User.findOne({ email });
    if (user) {
      return res.status(400).json({ msg: 'User already exists' });
    }

    // Create and save new user
    user = new User({ username, email, password });
    await user.save();
    console.log('New user created:', user);

    // Generate JWT token
    const payload = { userId: user.id };
    const token = jwt.sign(payload, process.env.SECRET_KEY || 'defaultsecret', { expiresIn: '1h' });

    res.status(201).json({ token });
  } catch (err) {
    console.error('Signup error:', err.message);
    res.status(500).send('Server error');
  }
});

// POST /login - User login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ msg: 'Invalid credentials' });

    const isMatch = await user.verifyPassword(password);
    if (!isMatch) return res.status(400).json({ msg: 'Invalid credentials' });

    const payload = { userId: user.id };
    const token = jwt.sign(payload, process.env.SECRET_KEY || 'defaultsecret', { expiresIn: '1h' });

    res.status(200).json({ token, user: { username: user.username, email: user.email } });
  } catch (err) {
    console.error('Login error:', err.message);
    res.status(500).send('Server error');
  }
});

module.exports = router;
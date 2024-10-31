const mongoose = require('mongoose');
const argon2 = require('argon2');

// User schema definition
const UserSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true, trim: true },
  email: { type: String, required: true, unique: true, trim: true },
  password: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
});

// Hash password before saving
UserSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  try {
    this.password = await argon2.hash(this.password);
    next();
  } catch (err) {
    next(err);
  }
});

// Verify password
UserSchema.methods.verifyPassword = async function (inputPassword) {
  try {
    return await argon2.verify(this.password, inputPassword);
  } catch (err) {
    console.error('Password verification error:', err);
    return false;
  }
};

module.exports = mongoose.model('User', UserSchema);

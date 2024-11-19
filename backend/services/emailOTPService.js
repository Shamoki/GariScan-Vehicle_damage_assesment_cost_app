const nodemailer = require('nodemailer');
const EmailOTP = require('../models/emailOTP');

// Configure Nodemailer
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER, // Use your email
    pass: process.env.EMAIL_PASS, // Use app-specific password
  },
});

/**
 * Generate a 6-digit OTP
 * @returns {string}
 */
const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

/**
 * Save or Update OTP in the database
 * @param {string} email - User's email
 * @param {string} otp - OTP code
 */
const saveOrUpdateOTP = async (email, otp) => {
  const existingOTP = await EmailOTP.findOne({ email });
  if (existingOTP) {
    existingOTP.otp = otp;
    existingOTP.createdAt = Date.now();
    await existingOTP.save();
  } else {
    await EmailOTP.create({ email, otp });
  }
};

/**
 * Send OTP via email
 * @param {string} email - Recipient's email address
 * @param {string} otp - OTP to send
 */
const sendOTPEmail = async (email, otp) => {
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: 'Your OTP Code',
    text: `Your OTP code is: ${otp}. This code is valid for 5 minutes.`,
  };

  await transporter.sendMail(mailOptions);
};

/**
 * Generate and send OTP
 * @param {string} email - Recipient's email address
 */
const generateAndSendOTP = async (email) => {
  const otp = generateOTP();
  await saveOrUpdateOTP(email, otp);
  await sendOTPEmail(email, otp);
};

/**
 * Verify the OTP
 * @param {string} email - User's email
 * @param {string} otp - OTP entered by the user
 * @returns {boolean}
 */
const verifyOTP = async (email, otp) => {
  const record = await EmailOTP.findOne({ email, otp });
  if (!record) {
    throw new Error('Invalid or expired OTP');
  }
  await EmailOTP.deleteOne({ email });
  return true;
};

module.exports = {
  generateAndSendOTP,
  verifyOTP,
};

const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  uid: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  username: { type: String, required: true },
  location: { type: String },
  phone: { type: String },
  partnerId: { type: String, ref: 'User' },
  linkCode: { type: String },
  linkCodeExpiry: { type: Date }, // For linking partners
  dateofBirth: { type: String },
  accountType: { type: String, default: "Mother" },
}, { collection: 'users' });  // Ensure it points to 'users' collection


module.exports = mongoose.model('User', UserSchema);

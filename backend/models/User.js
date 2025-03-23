const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  uid: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  username: { type: String, required: true },
  location: { type: String },
  phone: { type: String },
  birthday: { type: String },
  accountType: { type: String, default: "Mother" },
  linkCode: { type: String, sparse: true },
  // linkedAccount object that contains info about the linked partner
  linkedAccount: {
    uid: { type: String, sparse: true },
    username: { type: String },
    phone: { type: String }
  }
}, { collection: 'users' });  // Ensure it points to 'users' collection


module.exports = mongoose.model('User', UserSchema);

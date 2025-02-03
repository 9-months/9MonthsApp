const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  username: {type: String, required: true, unique: true},
  email: {type: String, required: true,unique: true},
  password: {type: String, required: true},
  location: {type: String, required: false},
  phone: {type: String, required: false},
  updated:{type:Boolean, default:false},
  isAdmin: {type: Boolean, default: false},

},{timestamps: true });

module.exports = mongoose.model('User', userSchema);





  
  


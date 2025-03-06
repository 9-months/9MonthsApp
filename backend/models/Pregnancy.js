const mongoose = require('mongoose');

const pregnancySchema = new mongoose.Schema({
    userId: { type: String, required: true },
    dueDate: { type: Date, required: true },
    updatedAt: { type: Date, default: Date.now }
  },{ collection: 'pregnancy' });
  
const Pregnancy = mongoose.model('Pregnancy', pregnancySchema);
module.exports = Pregnancy;
const mongoose = require('mongoose');

const pregnancySchema = new mongoose.Schema({
    userId: { 
      type: String, 
      required: true 
    },
    dueDate: { 
      type: Date, 
      required: true,
      set: v => new Date(v) // Ensure proper date conversion
    }
  }, { 
    collection: 'pregnancy',
    timestamps: true 
  });
  
const Pregnancy = mongoose.model('Pregnancy', pregnancySchema);
module.exports = Pregnancy;
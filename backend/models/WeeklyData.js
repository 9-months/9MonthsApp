const mongoose = require('mongoose');

const weeklyDataSchema = new mongoose.Schema({
  week: { type: Number, required: true, unique: true },
  babySize: { type: String, required: true },
  tips: [{ type: String }],
  babyDevelopment: { type: String },
  motherChanges: { type: String }
}, { collection: 'weeklyData' });

const WeeklyData = mongoose.model('WeeklyData', weeklyDataSchema);
module.exports = WeeklyData;

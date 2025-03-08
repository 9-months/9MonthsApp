const mongoose = require('mongoose');

const weeklyDataSchema = new mongoose.Schema({
  week: { type: Number, required: true, unique: true },
  babySize: { type: String, required: true, alias: 'baby_size' },
  tips: [{ type: String }],
  babyDevelopment: { type: String, alias: 'baby_development' },
  motherChanges: { type: String, alias: 'mother_changes' }
}, { collection: 'weeklyData' });

const WeeklyData = mongoose.model('WeeklyData', weeklyDataSchema);
module.exports = WeeklyData;

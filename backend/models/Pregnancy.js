const mongoose = require("mongoose");

const pregnancySchema = new mongoose.Schema(
  {
    userId: { type: String, required: true },
    dueDate: { type: Date, required: true },
    lastPeriodDate: { type: Date, required: true },
    currentWeek: { type: Number },
    babySize: { type: String },
    weeklyTips: [String],
    updatedAt: { type: Date, default: Date.now },
  },
  { collection: "pregnancy" }
);

const Pregnancy = mongoose.model("Pregnancy", pregnancySchema);
module.exports = Pregnancy;

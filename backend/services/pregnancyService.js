/**
 File: pregnancyService.js
 Purpose: buisness logic for pregnancy tracker.
 Created Date: 2025-02-08 CCS-8 Chamod Kamiss
 Author: Chamod Kamiss

 last modified: 2025-02-08 | Irosh | CCS-8 Created Update and Delete methods
 */

const Pregnancy = require("../models/Pregnancy");

class PregnancyService {
  calculateWeek(lastPeriodDate) {
    const today = new Date();
    const diffTime = Math.abs(today - lastPeriodDate);
    const diffWeeks = Math.ceil(diffTime / (1000 * 60 * 60 * 24 * 7));
    return Math.min(diffWeeks, 40);
  }

  getBabySize(week) {
    const sizes = {
      4: "Poppy seed",
      8: "Raspberry",
      12: "Lime",
      16: "Avocado",
      20: "Banana",
      24: "Corn",
      28: "Eggplant",
      32: "Pineapple",
      36: "Honeydew melon",
      40: "Small pumpkin",
    };

    const nearestWeek = Object.keys(sizes)
      .map(Number)
      .reduce((prev, curr) =>
        Math.abs(curr - week) < Math.abs(prev - week) ? curr : prev
      );

    return sizes[nearestWeek];
  }

  async createPregnancy(userData) {
    const dueDate = new Date(userData.lastPeriodDate);
    dueDate.setDate(dueDate.getDate() + 280);

    const currentWeek = this.calculateWeek(new Date(userData.lastPeriodDate));
    const babySize = this.getBabySize(currentWeek);

    const pregnancy = new Pregnancy({
      userId: userData.userId,
      lastPeriodDate: userData.lastPeriodDate,
      dueDate,
      currentWeek,
      babySize,
      weeklyTips: [
        "Stay hydrated",
        "Take your prenatal vitamins",
        "Get enough rest",
      ],
    });

    return await pregnancy.save();
  }

  async getPregnancyByUserId(userId) {
    const pregnancy = await Pregnancy.findOne({ userId });
    if (!pregnancy) {
      throw new Error("Pregnancy data not found");
    }

    pregnancy.currentWeek = this.calculateWeek(pregnancy.lastPeriodDate);
    pregnancy.babySize = this.getBabySize(pregnancy.currentWeek);
    pregnancy.updatedAt = new Date();

    return await pregnancy.save();
  }

  // Update an existing pregnancy record
  async updatePregnancy(userId, updatedData) {
    const pregnancy = await Pregnancy.findOneAndUpdate(
      { userId },
      { $set: updatedData },
      { new: true } // Return the updated document
    );

    if (!pregnancy) {
      throw new Error("Pregnancy data not found");
    }

    return pregnancy;
  }

  // Delete a pregnancy record
  async deletePregnancy(userId) {
    const result = await Pregnancy.deleteOne({ userId });
    if (result.deletedCount === 0) {
      throw new Error("Pregnancy data not found");
    }
    return { message: "Pregnancy data deleted successfully" };
  }
}

module.exports = new PregnancyService();

/**
 File: pregnancyService.js
 Purpose: buisness logic for pregnancy tracker.
 Created Date: 2025-02-08 CCS-8 Chamod Kamiss
 Author: Chamod Kamiss

 last modified: 2025-02-08 | Irosh | CCS-8 Created Update and Delete methods
 */

const Pregnancy = require("../models/Pregnancy");

class PregnancyService {
  calculateWeek(dueDate) {
    const today = new Date();
    const totalDays = 280; // 40 weeks
    const daysRemaining = Math.ceil((dueDate - today) / (1000 * 60 * 60 * 24));
    const currentWeek = Math.min(Math.max(1, Math.ceil((totalDays - daysRemaining) / 7)), 40);
    return currentWeek;
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
    try {
      console.log('Creating pregnancy with data:', userData);
      
      const pregnancy = new Pregnancy({
        userId: userData.userId,
        dueDate: new Date(userData.dueDate)
      });

      const savedPregnancy = await pregnancy.save();
      const currentWeek = this.calculateWeek(savedPregnancy.dueDate);
      
      return {
        ...savedPregnancy.toObject(),
        currentWeek,
        babySize: this.getBabySize(currentWeek)
      };
    } catch (error) {
      console.error('Error in createPregnancy:', error);
      throw error;
    }
  }

  async getPregnancyByUserId(userId) {
    const pregnancy = await Pregnancy.findOne({ userId });
    if (!pregnancy) {
      throw new Error("Pregnancy data not found");
    }

    const currentWeek = this.calculateWeek(pregnancy.dueDate);
    return {
      ...pregnancy.toObject(),
      currentWeek,
      babySize: this.getBabySize(currentWeek)
    };
  }

  async updatePregnancy(userId, updatedData) {
    const pregnancy = await Pregnancy.findOneAndUpdate(
      { userId },
      { $set: { dueDate: updatedData.dueDate } },
      { new: true }
    );

    if (!pregnancy) {
      throw new Error("Pregnancy data not found");
    }

    const currentWeek = this.calculateWeek(pregnancy.dueDate);
    return {
      ...pregnancy.toObject(),
      currentWeek,
      babySize: this.getBabySize(currentWeek)
    };
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

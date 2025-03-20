/**
 File: pregnancyService.js
 Purpose: buisness logic for pregnancy tracker.
 Created Date: 2025-02-08 CCS-8 Chamod Kamiss
 Author: Chamod Kamiss

 last modified: 2025-03-07 | Chamod | CCS-8 Add weekly tips and baby development data
 */

const Pregnancy = require("../models/Pregnancy");
const WeeklyData = require("../models/WeeklyData");

class PregnancyService {
  calculateWeek(dueDate) {
    const today = new Date();
    const totalDays = 280; // 40 weeks
    const daysRemaining = Math.ceil((dueDate - today) / (1000 * 60 * 60 * 24));
    const currentWeek = Math.min(Math.max(1, Math.ceil((totalDays - daysRemaining) / 7)), 40);
    return currentWeek;
  }

  async getWeeklyData(week) {
    const weekData = await WeeklyData.findOne({ week });
    if (!weekData) {
      throw new Error(`Data for week ${week} not found`);
    }
    return weekData;
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
      const weeklyData = await this.getWeeklyData(currentWeek);
      
      return {
        ...savedPregnancy.toObject(),
        currentWeek,
        ...weeklyData.toObject()
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
    const weeklyData = await this.getWeeklyData(currentWeek);

    return {
      ...pregnancy.toObject(),
      currentWeek,
      ...weeklyData.toObject()
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
    const weeklyData = await this.getWeeklyData(currentWeek);
    
    return {
      ...pregnancy.toObject(),
      currentWeek,
      ...weeklyData.toObject()
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

  async getWeeklyData(week) {
    const weekData = await WeeklyData.findOne({ week });
    if (!weekData) {
      return {
        week,
        babySize: "Information not available",
        tips: ["Stay hydrated", "Get regular checkups"],
        babyDevelopment: "Information not available",
        motherChanges: "Information not available",
        toObject: function() { return this; }
      };
    }
    return weekData;
  }
}

module.exports = new PregnancyService();

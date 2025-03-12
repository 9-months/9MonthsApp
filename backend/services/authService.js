/*
 File: authService.js
 Purpose: Business logic for Authentication.
 Created Date: 2025-02-06 CCS-7 Ryan Fernando
 Author: Ryan Fernando
 Input validation and error handling: Melissa Joanne

 Last Modified: 2025-03-11 | Chamod Kamiss | CCS-67-Added linkPartners and getPartnerData functions
*/
const User = require("../models/User");
const admin = require("firebase-admin");
const CryptoJS = require("crypto-js");
const emailValidator = require("email-validator");

class AuthService {
  // Create User
  async createUser(userData) {
    try {
      userData.email = userData.email.toLowerCase().trim();
      const requiredFields = [
        "email",
        "password",
        "username",
        "location",
        "phone",
      ];
      for (const field of requiredFields) {
        if (!userData[field] || userData[field].trim().length === 0) {
          return { status: false, message: `${field} is required` };
        }
      }

      if (!emailValidator.validate(userData.email)) {
        return { status: false, message: "Invalid email format." };
      }
      if (!/^\+94\d{9}$/.test(userData.phone)) {
        return { status: false, message: "Invalid phone number." };
      }
      if (
        userData.password.length < 6 ||
        !/[!@#$%^&*(),.?":{}|<>]/.test(userData.password)
      ) {
        return { status: false, message: "Weak password." };
      }
      userData.username = userData.username.toLowerCase().trim();
      if (!/^[a-z0-9]+$/.test(userData.username)) {
        return { status: false, message: "Invalid username." };
      }
      if (await User.findOne({ email: userData.email })) {
        return { status: false, message: "Email already registered." };
      }
      if (await User.findOne({ phone: userData.phone })) {
        return { status: false, message: "Phone number already in use." };
      }
      if (await User.findOne({ username: userData.username })) {
        return { status: false, message: "Username taken." };
      }
      try {
        await admin.auth().getUserByEmail(userData.email);
        return { status: false, message: "Firebase account exists." };
        
      } catch (error) {
        if (error.code === "auth/user-not-found") {
          if (!userData.role || !['mother', 'partner'].includes(userData.role)) {
            userData.role = 'mother'; // Default to mother if not specified
          }
          const userResponse = await admin.auth().createUser({
            email: userData.email,
            password: userData.password,
          });
          const encryptedPassword = CryptoJS.AES.encrypt(
            userData.password,
            process.env.SECRET
          ).toString();
          const newUser = new User({
            uid: userResponse.uid,
            email: userData.email,
            password: encryptedPassword,
            username: userData.username,
            location: userData.location,
            phone: userData.phone,
            role: userData.role,
            partnerId: userData.partnerId || null,
          });
          await newUser.save();
          return {
            status: true,
            message: "User registered successfully.",
            user: newUser,
          };
        }
        throw error;
      }
    } catch (err) {
      console.error("Error creating user:", err);
      return { status: false, message: "Registration error." };
    }
  }

  // Log In
  async logIn(identifier, password,partnerLinkCode = null) {
    try {
      console.log("logIn function called with:", identifier, password);

      if (!identifier || !password) {
        return { status: false, message: "Invalid credentials." };
      }
      identifier = identifier.toLowerCase().trim();
      let user;
      if (emailValidator.validate(identifier)) {
        user = await User.findOne({ email: identifier });
      } else {
        user = await User.findOne({ username: identifier });
      }
      if (!user) {
        return { status: false, message: "Invalid credentials." };
      }
      const decryptedPassword = CryptoJS.AES.decrypt(
        user.password,
        process.env.SECRET
      ).toString(CryptoJS.enc.Utf8);
      if (decryptedPassword !== password) {
        return { status: false, message: "Invalid credentials." };
      }
      const token = await admin.auth().createCustomToken(user.uid);
      console.log("Login successful:", user.email || user.username);

      // Check for partner linking if code provided
      let partnerInfo = null;
      if (partnerLinkCode) {
        const linkResult = await this.checkAndLinkPartner(user.uid, partnerLinkCode);
        if (linkResult.status) {
          partnerInfo = linkResult.partner;
        }
      }

      return { status: true, message: "Login successful.", token, user,partnerInfo };
    } catch (err) {
      console.error("Error during login:", err);
      return { status: false, message: "Invalid credentials." };
    }
  }

  // Read User by UID or email
  async getUser(identifier) {
    try {
      let user;
      if (emailValidator.validate(identifier)) {
        user = await User.findOne({ email: identifier });
      } else {
        user = await User.findOne({ uid: identifier });
      }
      if (!user) {
        return { status: false, message: "User not found." };
      }
      return { status: true, user };
    } catch (err) {
      console.error("Error fetching user:", err);
      return { status: false, message: "Error fetching user." };
    }
  }

  // Update User
  async updateUser(userId, updateData) {
    try {
      const allowedUpdates = ["email", "phone", "location"];
      const updates = Object.keys(updateData);
      const isValidUpdate = updates.every((update) =>
        allowedUpdates.includes(update)
      );
      if (!isValidUpdate) {
        return { status: false, message: "Invalid update fields." };
      }
      const user = await User.findOne({ uid: userId });
      if (!user) {
        return { status: false, message: "User not found." };
      }
      updates.forEach((update) => {
        user[update] = updateData[update];
      });
      await user.save();
      return { status: true, message: "User updated successfully.", user };
    } catch (err) {
      console.error("Error updating user:", err);
      return { status: false, message: "Error updating user." };
    }
  }

  // Delete User
  async deleteUser(userId) {
    try {
      const user = await User.findOne({ uid: userId });
      if (!user) {
        return { status: false, message: "User not found." };
      }
      await user.remove();
      await admin.auth().deleteUser(userId);
      return { status: true, message: "User deleted successfully." };
    } catch (err) {
      console.error("Error deleting user:", err);
      return { status: false, message: "Error deleting user." };
    }
  }

  // Check and link partner if code provided during login
  async checkAndLinkPartner(userId, partnerLinkCode) {
    try {
      // Skip if no linking code provided
      if (!partnerLinkCode || partnerLinkCode.trim() === '') {
        return { status: true, message: "No partner linking requested" };
      }
      
      // Find partner by the linking code
      // Assuming you store a temporary linkCode in the user document
      const partner = await User.findOne({ linkCode: partnerLinkCode });
      
      if (!partner) {
        return { status: false, message: "Invalid partner linking code" };
      }
      
      // Verify the roles are complementary (mother-partner)
      const user = await User.findOne({ uid: userId });
      
      if (!user) {
        return { status: false, message: "User not found" };
      }
      
      // Don't link if already linked
      if (user.partnerId || partner.partnerId) {
        return { status: false, message: "One or both users already have partners" };
      }
      
      // Link the partners
      user.partnerId = partner.uid;
      partner.partnerId = user.uid;
      
      // Clear the linking code after successful linking
      partner.linkCode = undefined;
      
      // Save both users
      await Promise.all([user.save(), partner.save()]);
      
      return { 
        status: true, 
        message: "Partner linked successfully", 
        partner: partner 
      };
    } catch (err) {
      console.error("Error checking/linking partner:", err);
      return { status: false, message: "Error linking partner" };
    }
  }

  async generatePartnerLinkCode(userId) {
    try {
      const user = await User.findOne({ uid: userId });
      
      if (!user) {
        return { status: false, message: "User not found" };
      }
      
      // Generate a random 6-character alphanumeric code
      const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      let linkCode = '';
      for (let i = 0; i < 6; i++) {
        linkCode += characters.charAt(Math.floor(Math.random() * characters.length));
      }
      
      // Save the code to the user
      user.linkCode = linkCode;
      user.linkCodeExpiry = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours expiry
      await user.save();
      
      return { 
        status: true, 
        message: "Partner link code generated", 
        linkCode 
      };
    } catch (err) {
      console.error("Error generating partner link code:", err);
      return { status: false, message: "Error generating link code" };
    }
  }

  // link two users as partners
  async linkPartners(userId1, userId2) {
    try {
      const user1 = await User.findOne({ uid: userId1 });
      const user2 = await User.findOne({ uid: userId2 });
      
      if (!user1 || !user2) {
        return { status: false, message: "One or both users not found." };
      }
      
      // Set partner relationship
      user1.partnerId = user2.uid;
      user2.partnerId = user1.uid;
      
      await user1.save();
      await user2.save();
      
      return { 
        status: true, 
        message: "Partners linked successfully.",
        user1: user1,
        user2: user2
      };
    } catch (err) {
      console.error("Error linking partners:", err);
      return { status: false, message: "Error linking partners." };
    }
  }
  
  // Get partner data
  async getPartnerData(userId) {
    try {
      const user = await User.findOne({ uid: userId });
      
      if (!user || !user.partnerId) {
        return { status: false, message: "No linked partner found." };
      }
      
      const partner = await User.findOne({ uid: user.partnerId });
      
      if (!partner) {
        return { status: false, message: "Partner not found." };
      }
      
      return { status: true, partner };
    } catch (err) {
      console.error("Error fetching partner:", err);
      return { status: false, message: "Error fetching partner." };
    }
  }
}

module.exports = new AuthService();

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
      ];
      for (const field of requiredFields) {
        if (!userData[field] || userData[field].trim().length === 0) {
          return { status: false, message: `${field} is required` };
        }
      }

      if (!emailValidator.validate(userData.email)) {
        return { status: false, message: "Invalid email format." };
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

  // Complete Profile
  async completeProfile(userId, profileData) {
    try {
      const allowedFields = ["accountType", "phone", "location", "birthday"];
      const updates = Object.keys(profileData);
  
      // Validate input fields
      const isValidUpdate = updates.every((field) => allowedFields.includes(field));
      if (!isValidUpdate) {
        return { status: false, message: "Invalid update fields." };
      }
  
      if (profileData.accountType.toLowerCase !== undefined && !["mother","partner","admin"].includes(profileData.accountType)) {
        return { status: false, message: "Invalid account type." };
      }
  
      const user = await User.findOne({ uid: userId });
      if (!user) {
        return { status: false, message: "User not found." };
      }
  
      // Update fields
      updates.forEach((update) => {
        user[update] = profileData[update];
      });

      let partnerLinkCode = null;
      if (profileData.accountType && profileData.accountType.toLowerCase() === "mother") {
        // Generate a random 8-character alphanumeric code
        const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        let code = '';
        for (let i = 0; i < 8; i++) {
          code += characters.charAt(Math.floor(Math.random() * characters.length));
        }
        
        user.partnerLinkCode = code;
        partnerLinkCode = code;
      }
  
      await user.save();
      const response = { 
        status: true, 
        message: "Profile updated successfully.", 
        user 
      };
      
      if (partnerLinkCode) {
        response.partnerLinkCode = partnerLinkCode;
      }
      return response;
    } catch (error) {
      console.error("Error updating profile:", error);
      return { status: false, message: "Error updating profile." };
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
      const allowedUpdates = ["email", "phone", "location", "dateOfBirth"];
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

  // Google Sign In - New method for handling Google sign in
  async googleSignIn(data) {
    try {
      // Expect: data = { idToken, location, username, phone }
      const { idToken, location, username, phone } = data;
      if (!idToken) {
        return { status: false, message: "Google ID token is required." };
      }
      // Verify the Google token to extract user details
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      const email = decodedToken.email;
      if (!email) {
        return { status: false, message: "Google token did not provide email." };
      }
      // Check if the user already exists in our local DB
      let existingUser = await User.findOne({ email: email });
      if (existingUser) {
        // User exists – generate a custom token and return user details
        const token = await admin.auth().createCustomToken(existingUser.uid);
        return { status: true, message: "Google sign in successful.", token, user: existingUser };
      }
      // If the user does not exist, require additional data for registration.
      if (!location || !username || !phone) {
        return {
          status: false,
          message: "Additional registration data required: location, username, and phone."
        };
      }
      
      // Validate the additional registration data
      if (!/^\+94\d{9}$/.test(phone)) {
        return { status: false, message: "Invalid phone number." };
      }
      
      const normalizedUsername = username.toLowerCase().trim();
      if (!/^[a-z0-9]+$/.test(normalizedUsername)) {
        return { status: false, message: "Invalid username." };
      }
      
      if (await User.findOne({ phone })) {
        return { status: false, message: "Phone number already in use." };
      }
      
      if (await User.findOne({ username: normalizedUsername })) {
        return { status: false, message: "Username taken." };
      }
      
      // Create a new Firebase user with a default password.
      const userResponse = await admin.auth().createUser({
        email: email,
        password: "GoogleSignInDefault#1" // default password for Google sign in
      });
      const encryptedPassword = CryptoJS.AES.encrypt(
        "GoogleSignInDefault#1",
        process.env.SECRET
      ).toString();
      // Save additional user details in our local database.
      const newUser = new User({
        uid: userResponse.uid,
        email: email,
        password: encryptedPassword,
        username: normalizedUsername,
        location: location,
        phone: phone,
      });
      await newUser.save();
      const token = await admin.auth().createCustomToken(newUser.uid);
      return {
        status: true,
        message: "Google sign in successful - new user registered.",
        token,
        user: newUser
      };
    } catch (error) {
      console.error("Error during Google sign in:", error);
      return { status: false, message: "Google sign in failed." };
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

  // Generate a unique partner link code
async generatePartnerLinkCode(userId) {
  try {
    const user = await User.findOne({ uid: userId });
    if (!user) {
      return { status: false, message: "User not found." };
    }
    
    if (user.accountType.toLowerCase() !== "mother") {
      return { status: false, message: "Only mothers can generate partner codes." };
    }
    
    // Generate a random 8-character alphanumeric code
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';
    for (let i = 0; i < 8; i++) {
      code += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    
    // Save the code to the user
    user.partnerLinkCode = code;
    await user.save();
    
    return { 
      status: true, 
      message: "Partner link code generated successfully.", 
      code 
    };
  } catch (error) {
    console.error("Error generating partner code:", error);
    return { status: false, message: "Error generating partner code." };
  }
}

// Check and link a partner using the code
async checkAndLinkPartner(userId, linkCode) {
  try {
    // Find the mother with this code
    const mother = await User.findOne({ partnerLinkCode: linkCode });
    if (!mother) {
      return { status: false, message: "Invalid partner link code." };
    }
    
    // Find the partner user
    const partner = await User.findOne({ uid: userId });
    if (!partner) {
      return { status: false, message: "Partner user not found." };
    }
    
    // Check if already linked
    if (mother.partnerId === partner.uid) {
      return { status: true, message: "Already linked with this partner.", partner: mother };
    }
    
    // Update mother's record with partner ID
    mother.partnerId = partner.uid;
    
    // Update partner's record with mother ID and basic info
    partner.partnerId = mother.uid;
    partner.accountType = "Partner";
    partner.motherInfo = {
      uid: mother.uid,
      username: mother.username,
      email: mother.email
    };
    
    // Save both records
    await mother.save();
    await partner.save();
    
    return { 
      status: true, 
      message: "Successfully linked with mother.", 
      partner: {
        uid: mother.uid,
        username: mother.username,
        email: mother.email
      }
    };
  } catch (error) {
    console.error("Error linking partner:", error);
    return { status: false, message: "Error linking partner." };
  }
}

// Get partner data
async getPartnerData(userId) {
  try {
    const user = await User.findOne({ uid: userId });
    if (!user) {
      return { status: false, message: "User not found." };
    }
    
    if (!user.partnerId) {
      return { status: false, message: "No linked partner found." };
    }
    
    const partner = await User.findOne({ uid: user.partnerId });
    if (!partner) {
      return { status: false, message: "Linked partner not found." };
    }
    
    return { 
      status: true, 
      message: "Partner data retrieved successfully.", 
      partner: {
        uid: partner.uid,
        username: partner.username,
        email: partner.email,
        accountType: partner.accountType
      }
    };
  } catch (error) {
    console.error("Error getting partner data:", error);
    return { status: false, message: "Error retrieving partner data." };
  }
}

  
}

module.exports = new AuthService();

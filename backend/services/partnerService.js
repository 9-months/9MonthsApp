/*
 File: partnerService.js
 Purpose: Business logic for partner account linking.
 Created Date: 2025-03-17
 Author: Irosh Perera
*/

const User = require('../models/User');

class PartnerService {
  // Generate a unique 6-character link code
  generateLinkCode(length = 6) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';
    
    // Generate a random code
    for (let i = 0; i < length; i++) {
      const randomIndex = Math.floor(Math.random() * characters.length);
      code += characters.charAt(randomIndex);
    }
    
    return code;
  }

  // Generate a unique link code not already used
  async createUniqueLinkCode() {
    let isUnique = false;
    let linkCode;
    
    while (!isUnique) {
      linkCode = this.generateLinkCode();
      // Check if code exists in database
      const existingCode = await User.findOne({ linkCode });
      if (!existingCode) {
        isUnique = true;
      }
    }
    
    return linkCode;
  }

  // Link a partner account with a mother account using the code
  async linkPartnerWithMother(uid, linkCode) {
    try {
      // Find the mother with the provided link code
      const motherAccount = await User.findOne({ linkCode, accountType: "mother" });
      
      if (!motherAccount) {
        return { status: false, message: "Invalid link code or link code expired." };
      }
      
      // Get partner account details
      const partnerAccount = await User.findOne({ uid: uid });
      
      if (!partnerAccount) {
        return { status: false, message: "Partner account not found." };
      }
      
      if (partnerAccount.accountType !== "partner") {
        return { status: false, message: "Account is not a partner type account." };
      }
      
      if (partnerAccount.linkedAccount && partnerAccount.linkedAccount.uid) {
        return { status: false, message: "This account is already linked to a mother account." };
      }
      
      // Link the accounts bidirectionally with enhanced information
      partnerAccount.linkedAccount = {
        uid: motherAccount.uid,
        username: motherAccount.username,
        phone: motherAccount.phone || ''
      };
      await partnerAccount.save();
      
      motherAccount.linkedAccount = {
        uid: partnerAccount.uid,
        username: partnerAccount.username,
        phone: partnerAccount.phone || ''
      };
      await motherAccount.save();
      
      return { 
        status: true, 
        message: "Accounts successfully linked.", 
        motherDetails: {
          username: motherAccount.username,
          email: motherAccount.email,
          phone: motherAccount.phone
        }
      };
    } catch (error) {
      console.error("Error linking accounts:", error);
      return { status: false, message: "An error occurred while linking accounts." };
    }
  }
 
}

module.exports = new PartnerService();

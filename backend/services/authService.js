/*
 File: authService.js
 Purpose: Business logic for Authentication.
 Created Date: 2025-02-06 CCS-7 Ryan Fernando
 Author: Ryan Fernando
 Input validation and error handling: Melissa Joanne

 Last Modified: 2025-02-08 | Melissa | CCS-7 Improved validation for email, phone, and password
*/

const User = require("../models/User");
const admin = require("firebase-admin");
const CryptoJS = require("crypto-js");
const emailValidator = require("email-validator");

class AuthService {
    async createUser(userData) {
        try {
            // Normalize email: convert to lowercase and trim spaces
            userData.email = userData.email.toLowerCase().trim();

            // Check for missing fields
            const requiredFields = ["email", "password", "username", "location", "phone"];
            for (const field of requiredFields) {
                if (!userData[field] || userData[field].trim().length === 0) {
                    return { status: false, message: `${field} is required` };
                }
            }

            // Validate email format
            if (!emailValidator.validate(userData.email)) {
                return { 
                    status: false, 
                    message: "Invalid email format. Please enter a valid email address (e.g., username@example.com)."
                };
            }

            // Validate phone number format (must start with +94 and be followed by 9 digits)
            if (!/^\+94\d{9}$/.test(userData.phone)) {
                return { 
                    status: false, 
                    message: "Invalid phone number. Use the format +94712345678." 
                };
            }

            // Validate password (at least 6 characters, must contain at least one special character)
            if (userData.password.length < 6 || !/[!@#$%^&*(),.?":{}|<>]/.test(userData.password)) {
                return { 
                    status: false, 
                    message: "Password must be at least 6 characters long and include one special character." 
                };
            }

            // Normalize username: convert to lowercase and trim spaces
            userData.username = userData.username.toLowerCase().trim();

            // Validate username: must only contain lowercase letters and numbers, no spaces
            if (!/^[a-z0-9]+$/.test(userData.username)) {
                return { status: false, message: "Username can only contain lowercase letters and numbers, no spaces." };
            }

            // Check for existing email
            const existingEmailUser = await User.findOne({ email: userData.email });
            if (existingEmailUser) {
                return { status: false, message: `This email is already registered.` };
            }

            // Check for existing phone number
            const existingPhoneUser = await User.findOne({ phone: userData.phone });
            if (existingPhoneUser) {
                return { status: false, message: "This phone number is already in use." };
            }

            // Check for existing username
            const existingUsername = await User.findOne({ username: userData.username });
            if (existingUsername) {
                return { status: false, message: "This username is already taken." };
            }

            // Check if user exists in Firebase
            try {
                await admin.auth().getUserByEmail(userData.email);
                return { status: false, message: "An account with this email already exists." };
            } catch (error) {
                if (error.code === "auth/user-not-found") {
                    const userResponse = await admin.auth().createUser({
                        email: userData.email,
                        password: userData.password,
                        emailVerified: false,
                        disabled: false,
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
                    });

                    await newUser.save();
                    return { status: true, message: "User registered successfully." };
                }
                throw error;
            }
        } catch (err) {
            console.error("Error creating user:", err);
            return { status: false, message: "An error occurred during registration." };
        }
    }
}

module.exports = new AuthService();

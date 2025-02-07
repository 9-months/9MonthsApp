/*
 File: authService.js
 Purpose: Business logic for Authentication.
 Created Date: 2025-02-06 CCS-7 Ryan Fernando
 Author: Ryan Fernando
 Input validation and error handling: Melissa Joanne

 last modified: 2025-02-07 | Melissa | CCS-7 Input validation
*/

const User = require("../models/User");
const admin = require("firebase-admin");
const CryptoJS = require("crypto-js");
const emailValidator = require("email-validator");

class AuthService {
    async createUser(userData) {
        try {
            // Check for missing fields
            const requiredFields = ["email", "password", "username", "location", "phone"];
            for (const field of requiredFields) {
                if (!userData[field] || userData[field].trim().length === 0) {
                    return { status: false, message: `${field} is required` };
                }
            }

            if (!emailValidator.validate(userData.email)) {
                return { status: false, message: `Invalid email format: ${userData.email}` };
            }

            // Check for existing email
            const existingEmailUser = await User.findOne({ email: userData.email });
            if (existingEmailUser) {
                return { status: false, message: `Email is already registered: ${userData.email}` };
            }

            // Check for existing phone number
            const existingPhoneUser = await User.findOne({ phone: userData.phone });
            if (existingPhoneUser) {
                return { status: false, message: `Phone number is already registered: ${userData.phone}` };
            }

            if (userData.password.length < 6) {
                return { status: false, message: "Password must be at least 6 characters long" };
            }

            const existingUsername = await User.findOne({ username: userData.username });
            if (existingUsername) {
                return { status: false, message: `Username is already taken: ${userData.username}` };
            }

            try {
                await admin.auth().getUserByEmail(userData.email);
                return { status: false, message: `User already exists in Firebase: ${userData.email}` };
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
                    return { status: true, message: "User created successfully" };
                }
                throw error;
            }
        } catch (err) {
            console.error("Error creating user:", err);
            return { status: false, message: `Error creating user: ${err.message}` };
        }
    }

    async logIn(email, password) {
        try {
            console.log("Login attempt with:", { email, password });

            if (!email || !password || email.trim().length === 0 || password.trim().length === 0) {
                return { status: false, message: "Email/username and password are required" };
            }

            // Check for user by email, username, or phone number
            const user = await User.findOne({
                $or: [
                    { email: email.toLowerCase() },
                    { username: email.toLowerCase() },
                    { phone: email }  // If you're allowing phone number login
                ]
            });

            if (!user) {
                return { status: false, message: "Invalid credentials: User not found" };
            }

            const bytes = CryptoJS.AES.decrypt(user.password, process.env.SECRET);
            const decryptedPassword = bytes.toString(CryptoJS.enc.Utf8);

            if (decryptedPassword !== password) {
                return { status: false, message: "Invalid credentials: Incorrect password" };
            }

            const customToken = await admin.auth().createCustomToken(user.uid);

            return {
                status: true,
                message: "Logged in successfully",
                token: customToken,
                user: {
                    uid: user.uid,
                    email: user.email,
                    username: user.username,
                },
            };
        } catch (err) {
            console.error("Login error:", err);
            return { status: false, message: `Login failed: ${err.message}` };
        }
    }
}

module.exports = new AuthService();

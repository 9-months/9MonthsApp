/*
 File: authService.js
 Purpose: Business logic for Authentication.
 Created Date: 2025-02-06 CCS-7 Ryan Fernando
 Author: Ryan Fernando
 Input validation and error handling: Melissa Joanne

 Last Modified: 2025-02-11 | Melissa | CCS-7 Login issue fix
*/
const User = require("../models/User");
const admin = require("firebase-admin");
const CryptoJS = require("crypto-js");
const emailValidator = require("email-validator");

class AuthService {
    async createUser(userData) {
        try {
            userData.email = userData.email.toLowerCase().trim();
            const requiredFields = ["email", "password", "username", "location", "phone"];
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
            if (userData.password.length < 6 || !/[!@#$%^&*(),.?":{}|<>]/.test(userData.password)) {
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
                    const userResponse = await admin.auth().createUser({
                        email: userData.email,
                        password: userData.password,
                    });
                    const encryptedPassword = CryptoJS.AES.encrypt(userData.password, process.env.SECRET).toString();
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
            return { status: false, message: "Registration error." };
        }
    }

    async logIn(identifier, password) {
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
            const decryptedPassword = CryptoJS.AES.decrypt(user.password, process.env.SECRET).toString(CryptoJS.enc.Utf8);
            if (decryptedPassword !== password) {
                return { status: false, message: "Invalid credentials." };
            }
            const token = await admin.auth().createCustomToken(user.uid);
            console.log("Login successful:", user.email || user.username);

            return { status: true, message: "Login successful.", token, user };
        } catch (err) {
            console.error("Error during login:", err);
            return { status: false, message: "Invalid credentials." };
        }
    }
}

module.exports = new AuthService();

const User = require("../models/User");
const admin = require("firebase-admin");
const CryptoJS = require("crypto-js");
const emailValidator = require("email-validator");
const validator = require("validator");

class AuthService {
  async createUser(userData) {
    try {
      // Validate email
      if (!emailValidator.validate(userData.email)) {
        throw new Error(`Invalid email format: ${userData.email}`);
      }

      // Check if email already exists in MongoDB
      const existingEmailUser = await User.findOne({ email: userData.email });
      if (existingEmailUser) {
        throw new Error(`Email is already registered: ${userData.email}`);
      }

      // Validate password
      if (userData.password.length < 6) {
        throw new Error("Password must be at least 6 characters long");
      }

      // Validate username
      if (!userData.username || userData.username.trim().length === 0) {
        throw new Error("Username is required");
      }

      // Check if username already exists in MongoDB
      const existingUsername = await User.findOne({ username: userData.username });
      if (existingUsername) {
        throw new Error(`Username is already taken: ${userData.username}`);
      }

      // Validate phone (Sri Lanka format: +94xxxxxxxxx)
      if (userData.phone && !/^\+94\d{9}$/.test(userData.phone)) {
        throw new Error("Phone number must be in the format +94xxxxxxxxx (e.g., +94716332188)");
      }

      // Check if phone number already exists in MongoDB
      if (userData.phone) {
        const existingPhoneUser = await User.findOne({ phone: userData.phone });
        if (existingPhoneUser) {
          throw new Error(`Phone number is already registered: ${userData.phone}`);
        }
      }

      try {
        // Check if user exists in Firebase
        await admin.auth().getUserByEmail(userData.email);
        throw new Error(`User already exists in Firebase: ${userData.email}`);
      } catch (error) {
        if (error.code === "auth/user-not-found") {
          // Create user in Firebase
          const userResponse = await admin.auth().createUser({
            email: userData.email,
            password: userData.password,
            emailVerified: false,
            disabled: false,
          });

          // Encrypt password
          const encryptedPassword = CryptoJS.AES.encrypt(
            userData.password,
            process.env.SECRET
          ).toString();

          // Create user in MongoDB
          const newUser = new User({
            uid: userResponse.uid,
            email: userData.email,
            password: encryptedPassword,
            username: userData.username,
            location: userData.location,
            phone: userData.phone,
          });

          await newUser.save();
          return { status: true };
        }
        throw error;
      }
    } catch (err) {
      console.error("Error creating user:", err);
      throw new Error(`Error creating user: ${err.message}`);
    }
  }

  async logIn(usernameOrEmail, password) {
    try {
      // Validate password
      if (password.length < 6) {
        throw new Error("Password must be at least 6 characters long");
      }

      // Get user from MongoDB by username or email
      const user = await User.findOne({
        $or: [
          { username: usernameOrEmail },
          { email: usernameOrEmail }
        ]
      });

      if (!user) {
        throw new Error(`User not found with username/email: ${usernameOrEmail}`);
      }

      // Decrypt and verify password
      let decryptedPassword;
      try {
        const bytes = CryptoJS.AES.decrypt(user.password, process.env.SECRET);
        decryptedPassword = bytes.toString(CryptoJS.enc.Utf8);

        if (!decryptedPassword) {
          throw new Error("Decryption failed");
        }
      } catch (decryptError) {
        throw new Error(`Error decrypting password: ${decryptError.message}`);
      }

      // Compare passwords
      if (decryptedPassword !== password) {
        throw new Error("Invalid credentials: Incorrect password");
      }

      // Create custom token
      const customToken = await admin.auth().createCustomToken(user.uid);

      return {
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
      throw new Error(`Login failed: ${err.message}`);
    }
  }

  async googleSignIn(idToken) {
    try {
      // Verify the Google ID token
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      const { email, uid, name } = decodedToken;

      // Check if user exists in MongoDB
      let user = await User.findOne({ uid });

      if (!user) {
        // Create new user in MongoDB if doesn't exist
        user = new User({
          uid,
          email,
          username: name,
          password: CryptoJS.AES.encrypt(
            Math.random().toString(36),
            process.env.SECRET
          ).toString(),
        });
        await user.save();
      }

      // Create custom token
      const customToken = await admin.auth().createCustomToken(uid);

      return {
        token: customToken,
        user: {
          uid: user.uid,
          email: user.email,
          username: user.username,
        },
      };
    } catch (err) {
      console.error("Google Sign-In error:", err);
      throw new Error(`Google Sign-In failed: ${err.message}`);
    }
  }
}

module.exports = new AuthService();

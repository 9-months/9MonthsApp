const User = require("../models/User");
const admin = require("firebase-admin");
const CryptoJS = require("crypto-js");

class AuthService {
  async createUser(userData) {
    try {
      // Check if user exists in Firebase
      try {
        await admin.auth().getUserByEmail(userData.email);
        throw new Error("User already exists");
      } catch (error) {
        if (error.code !== "auth/user-not-found") {
          throw error;
        }
      }

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
      return { status: true, message: "User created successfully" };
    } catch (error) {
      console.error("Create User Service Error:", error);
      throw error;
    }
  }

  async logIn(usernameOrEmail, password) {
    try {
      // Get user from MongoDB by username or email
      const user = await User.findOne({
        $or: [{ username: usernameOrEmail }, { email: usernameOrEmail }],
      });

      if (!user) {
        throw new Error("User not found");
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
        throw new Error("Error verifying credentials");
      }

      // Compare passwords
      if (decryptedPassword !== password) {
        throw new Error("Invalid credentials");
      }

      // Create custom token
      const customToken = await admin.auth().createCustomToken(user.uid);

      return {
        message: "Logged in successfully",
        token: customToken,
        user: {
          uid: user.uid,
          username: user.username,
          email: user.email,
        },
      };
    } catch (error) {
      console.error("Log In Service Error:", error);
      throw error;
    }
  }

  async googleSignIn(idToken) {
    try {
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      const user = await User.findOne({ uid: decodedToken.uid });

      if (!user) {
        throw new Error("User not found");
      }

      return {
        message: "Google sign-in successful",
        token: await admin.auth().createCustomToken(decodedToken.uid),
        user: {
          uid: user.uid,
          username: user.username,
          email: user.email,
        },
      };
    } catch (error) {
      console.error("Google Sign-In Service Error:", error);
      throw error;
    }
  }

  async getUser(uid) {
    try {
      return await User.findOne({ uid });
    } catch (error) {
      console.error("Get User Service Error:", error);
      throw error;
    }
  }

  async getAllUsers() {
    try {
      return await User.find();
    } catch (error) {
      console.error("Get All Users Service Error:", error);
      throw error;
    }
  }

  async updateUser(uid, updatedData) {
    try {
      return await User.findOneAndUpdate({ uid }, updatedData, { new: true });
    } catch (error) {
      console.error("Update User Service Error:", error);
      throw error;
    }
  }

  async deleteUser(uid) {
    try {
      const result = await User.findOneAndDelete({ uid });
      if (!result) {
        throw new Error("User not found");
      }
      return { message: "User deleted successfully" };
    } catch (error) {
      console.error("Delete User Service Error:", error);
      throw error;
    }
  }
}

module.exports = new AuthService();

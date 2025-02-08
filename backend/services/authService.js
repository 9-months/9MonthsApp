const User = require("../models/User");
const admin = require("firebase-admin");
const CryptoJS = require("crypto-js");

class AuthService {
  async createUser(userData) {
    try {
      // Check if user exists in Firebase
      await admin.auth().getUserByEmail(userData.email);
      throw new Error("User already exists");
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
  }

  async logIn(usernameOrEmail, password) {
    // Get user from MongoDB by username or email
    const user = await User.findOne({
      $or: [
        { username: usernameOrEmail },
        { email: usernameOrEmail }
      ]
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
        email: user.email,
        username: user.username,
      },
    };
  }

  async googleSignIn(idToken) {
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
  }
}

module.exports = new AuthService();

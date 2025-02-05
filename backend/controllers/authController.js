const User = require("../models/User");
const admin = require("firebase-admin");
const CryptoJS = require("crypto-js");

module.exports = {
  createUser: async (req, res) => {
    const user = req.body;
    try {
      await admin.auth().getUserByEmail(user.email);
      return res.status(400).json({ message: "User already exists" });
    } catch (error) {
      if (error.code === "auth/user-not-found") {
        try {
          const userResponse = await admin.auth().createUser({
            email: user.email,
            password: user.password,
            emailVerified: false,
            disabled: false,
          });

          console.log(userResponse.uid);

          const encryptedPassword = CryptoJS.AES.encrypt(
            user.password,
            process.env.SECRET
          ).toString();

          console.log("Original Password:", user.password);
          console.log("Encrypted Password:", encryptedPassword);

          const newUser = new User({
            uid: userResponse.uid,
            email: user.email,
            password: encryptedPassword,
            username: user.username,
            location: user.location,
            phone: user.phone,
          });

          await newUser.save(); // Save user to MongoDB
          res.status(201).json({ status: true }); // Send success response
        } catch (error) {
          console.error("MongoDB Save Error:", error);
          return res
            .status(500)
            .json({ error: "An error occurred while creating user" });
        }
      } else {
        return res.status(500).json({ error: "Firebase error occurred" });
      }
    }
  },

  // Sign in with username and password
  signIn: async (req, res) => {
    const { username, password } = req.body;
    try {
      // Get user from MongoDB
      const user = await User.findOne({ username });
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }

      // Decrypt password with proper error handling
      let decryptedPassword;
      try {
        const bytes = CryptoJS.AES.decrypt(user.password, process.env.SECRET);
        decryptedPassword = bytes.toString(CryptoJS.enc.Utf8);

        console.log("Input Password:", password);
        console.log("Decrypted Password:", decryptedPassword);

        if (!decryptedPassword) {
          throw new Error("Decryption failed");
        }
      } catch (decryptError) {
        console.error("Decryption Error:", decryptError);
        return res.status(500).json({ message: "Error verifying credentials" });
      }

      // Compare passwords
      if (decryptedPassword !== password) {
        return res.status(401).json({ message: "Invalid credentials" });
      }

      // Create custom token
      const customToken = await admin.auth().createCustomToken(user.uid);

      res.status(200).json({
        message: "Sign in successful",
        token: customToken,
        user: {
          uid: user.uid,
          email: user.email,
          username: user.username,
        },
      });
    } catch (error) {
      console.error("Sign In Error:", error);
      res.status(500).json({ error: "An error occurred during sign in" });
    }
  },

  // Google Sign In
  googleSignIn: async (req, res) => {
    const { idToken } = req.body;
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

      res.status(200).json({
        token: customToken,
        user: {
          uid: user.uid,
          email: user.email,
          username: user.username,
        },
      });
    } catch (error) {
      console.error("Google Sign In Error:", error);
      res
        .status(500)
        .json({ error: "An error occurred during Google sign in" });
    }
  },
};

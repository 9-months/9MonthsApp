const User = require("../models/User");
const admin = require("firebase-admin");
const CryptoJS = require("crypto-js");  



// exports.login = async (req, res) => {
//   const { email, password } = req.body;
//   try {
//     const user = await User.findOne({ email, password });
//     if (user) {
//       res.status(200).json(user);
//     } else {
//       res.status(401).json({ message: "Invalid credentials" });
//     }
//   } catch (err) {
//     res.status(500).json({ message: "Server error" });
//   }
// };


// module.exports.login = async (req, res) => {
//   const { email, password } = req.body;
//   try {
//     const user = await User.findOne({ email, password });
//     if (user) {
//       const token = jwt.sign({ email: user.email }, process.env.JWT_SECRET);
//       res.status(200).json({ token });
//     } else {
//       res.status(401).json({ message: "Invalid credentials" });
//     }
//   } catch (err) {
//     res.status(500).json({ message: "Server error" });
//   }
// }

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

          const newUser = new User({
            uid: userResponse.uid,
            email: user.email,
            password: CryptoJS.AES.encrypt(user.password, process.env.SECRET).toString(),// Encrypt password
            username: user.username,
            location: user.location,
            phone: user.phone,
          });

          await newUser.save();  // Save user to MongoDB
        res.status(201).json({ status: true });// Send success response
        } catch (error) {
          console.error('MongoDB Save Error:', error);
          return res.status(500).json({ error: "An error occurred while creating user" });
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
    // Get user from MongoDB to verify password
    const user = await User.findOne({ username });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Decrypt and verify password
    const decryptedPassword = CryptoJS.AES.decrypt(
      user.password,
      process.env.SECRET
    ).toString(CryptoJS.enc.Utf8);

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
        username: user.username
      }
    });
  } catch (error) {
    console.error('Sign In Error:', error);
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
          password: CryptoJS.AES.encrypt(Math.random().toString(36), process.env.SECRET).toString(),
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
          username: user.username
        }
      });
    } catch (error) {
      console.error('Google Sign In Error:', error);
      res.status(500).json({ error: "An error occurred during Google sign in" });
    }
  }

};





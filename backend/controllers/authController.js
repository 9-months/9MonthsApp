const authService = require("../services/authService");

module.exports = {
  createUser: async (req, res) => {
    try {
      const result = await authService.createUser(req.body);
      res.status(201).json(result);
    } catch (error) {
      console.error("Create User Error:", error);
      if (error.message === "User already exists") {
        return res.status(400).json({ message: error.message });
      }
      return res.status(500).json({ 
        error: "An error occurred while creating user" 
      });
    }
  },

  logIn: async (req, res) => {
    try {
      const { username, password } = req.body;
      const result = await authService.logIn(username, password);
      res.status(200).json(result);
    } catch (error) {
      console.error("Log In Error:", error);
      if (error.message === "User not found") {
        return res.status(404).json({ message: error.message });
      }
      if (error.message === "Invalid credentials") {
        return res.status(401).json({ message: error.message });
      }
      res.status(500).json({ 
        error: "An error occurred during Log In" 
      });
    }
  },

  googleSignIn: async (req, res) => {
    try {
      const { idToken } = req.body;
      const result = await authService.googleSignIn(idToken);
      res.status(200).json(result);
    } catch (error) {
      console.error("Google Sign In Error:", error);
      res.status(500).json({ 
        error: "An error occurred during Google sign in" 
      });
    }
  },
};

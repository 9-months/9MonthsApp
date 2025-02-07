const authService = require("../services/authService");

module.exports = {
  createUser: async (req, res) => {
    try {
      const result = await authService.createUser(req.body);

      // If user creation fails (status is false)
      if (!result.status) {
        return res.status(400).json({ message: result.message });
      }

      // If user is created successfully (status is true)
      return res.status(200).json({ message: result.message });
    } catch (error) {
      console.error("Create User Error:", error);

      // Handle specific error for user already existing
      if (error.message === "User already exists") {
        return res.status(400).json({ message: error.message });
      }

      // Handle other server errors
      return res.status(500).json({
        error: "An error occurred while creating the user"
      });
    }
  },

  logIn: async (req, res) => {
    try {
      const { email, username, password } = req.body;

      // Get the credential (either email or username)
      const credential = email || username;

      // Ensure both credential and password are provided
      if (!credential || !password) {
        return res.status(400).json({
          status: false,
          message: "Email/username and password are required"
        });
      }

      const result = await authService.logIn(credential, password);

      // If login is successful
      if (result.status) {
        return res.status(200).json(result);
      } else {
        // If login failed due to invalid credentials
        return res.status(401).json(result);
      }
    } catch (error) {
      console.error("Log In Error:", error);

      // Handle specific error for user not found
      if (error.message === "User not found") {
        return res.status(404).json({
          status: false,
          message: error.message
        });
      }

      // Handle specific error for invalid credentials
      if (error.message === "Invalid credentials") {
        return res.status(401).json({
          status: false,
          message: error.message
        });
      }

      // Handle general server errors
      return res.status(500).json({
        status: false,
        message: "An error occurred during Log In"
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

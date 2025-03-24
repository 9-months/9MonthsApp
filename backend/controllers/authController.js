/*
 File: authController.js
 Purpose: Handles HTTP requests for authentication with CRUD functionality.
 Created Date: 2025-02-03 CCS-7 Ryan Fernando
 Author: Ryan Fernando

 Last Modified: 2022-02-14 | Irosh Perera | CCS-42-returned user data after registration
*/

const authService = require("../services/authService");

module.exports = {
  // Create User
  createUser: async (req, res) => {
    try {
      const result = await authService.createUser(req.body);

      if (!result.status) {
        console.error("User creation failed:", result.message);
        return res.status(400).json({ message: result.message });
      }

      return res
        .status(201)
        .json({ 
          message: result.message, 
          user: result.user,
          token: result.token 
        });
    } catch (error) {
      console.error("Create User Error:", error.message || error);

      return res.status(500).json({
        message: "An error occurred while creating the user",
      });
    }
  },
  
  // Log In
  logIn: async (req, res) => {
    try {
      const { email, username, password } = req.body;
      const credential = email || username;

      if (!credential || !password) {
        console.error("Login failed: Missing credentials");
        return res.status(400).json({
          message: "Email/username and password are required",
        });
      }

      const result = await authService.logIn(credential, password);

      if (!result.status) {
        console.error("Login failed:", result.message);
        return res.status(401).json({ message: result.message });
      }

      return res.status(200).json({
        message: result.message,
        token: result.token,
        user: result.user,
      });
    } catch (error) {
      console.error("Log In Error:", error.message || error);

      return res.status(500).json({
        message: "An error occurred during Log In",
      });
    }
  },

  // Google Sign In
  googleSignIn: async (req, res) => {
    try {
      const { idToken } = req.body;

      if (!idToken) {
        console.error("Google Sign In failed: Missing ID token");
        return res.status(400).json({
          message: "Google ID token is required",
        });
      }

      const result = await authService.googleSignIn(idToken);
      return res.status(200).json(result);
    } catch (error) {
      console.error("Google Sign In Error:", error.message || error);

      return res.status(500).json({
        message: "An error occurred during Google sign-in",
      });
    }
  },

  // Get User by UID
  getUser: async (req, res) => {
    try {
      const { uid } = req.params;
      const result = await authService.getUser(uid);
      if (!result.status) {
        return res.status(404).json({ message: result.message });
      }
      res.status(200).json(result.user);
    } catch (error) {
      console.error("Get User Error:", error);
      res
        .status(500)
        .json({ message: "An error occurred while retrieving user" });
    }
  },

  // Get All Users
  getAllUsers: async (req, res) => {
    try {
      const users = await authService.getAllUsers();
      res.status(200).json(users);
    } catch (error) {
      console.error("Get All Users Error:", error);
      res
        .status(500)
        .json({ message: "An error occurred while retrieving users" });
    }
  },

  // Update User
  updateUser: async (req, res) => {
    try {
      const { uid } = req.params;
      const updatedData = req.body; // Ensure you're passing the correct data in the request body
      const result = await authService.updateUser(uid, updatedData);

      if (!result.status) {
        return res.status(404).json({ message: result.message });
      }

      res.status(200).json(result.user); // Respond with updated user details
    } catch (error) {
      console.error("Update User Error:", error);
      res
        .status(500)
        .json({ message: "An error occurred while updating user" });
    }
  },

  // Delete User
  deleteUser: async (req, res) => {
    try {
      const { uid } = req.params;
      const result = await authService.deleteUser(uid);
      if (!result.status) {
        return res.status(404).json({ message: result.message });
      }
      res.status(200).json(result);
    } catch (error) {
      console.error("Delete User Error:", error);
      res
        .status(500)
        .json({ message: "An error occurred while deleting user" });
    }
  },

  // Complete Profile
  completeProfile: async (req, res) => {
    try {
      const uid = req.body.uid;
      const profileData = req.body.profileData;

      const result = await authService.completeProfile(uid, profileData);


      if (!result.status) {
        return res.status(400).json({ message: result.message });
      }

      return res.status(200).json({
        status: result.status,
        message: result.message,
        user: result.user,
      });
    } catch (error) {
      console.error("Complete Profile Error:", error.message || error);

      return res.status(500).json({
        message: "An error occurred while completing the profile",
      });
    }
  },

  // Get Current User (from token)
  getCurrentUser: async (req, res) => {
    try {
      // The user ID is already extracted from the token in the verifyToken middleware
      const userId = req.user.id;
      
      if (!userId) {
        return res.status(401).json({ message: "Not authenticated" });
      }
      
      const result = await authService.getUser(userId);
      
      if (!result.status) {
        return res.status(404).json({ message: result.message });
      }
      
      // Return user data in the same format as other user endpoints
      return res.status(200).json({
        user: result.user
      });
    } catch (error) {
      console.error("Get Current User Error:", error.message || error);
      return res.status(500).json({
        message: "An error occurred while retrieving current user"
      });
    }
  },
};

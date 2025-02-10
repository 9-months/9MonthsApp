/*
 File: authControllers.js
 Purpose: Handles HTTP requests for authentication
 Created Date: 2025-02-03 CCS-7 Ryan Fernando
 Author: Ryan Fernando
 
 last modified: 2025-02-11 | Melissa | CCS-7 Controllers for crud added
*/

const authService = require("../services/authService");

module.exports = {
  createUser: async (req, res) => {
    try {
      const result = await authService.createUser(req.body);
      res.status(201).json(result);
    } catch (error) {
      console.error("Create User Error:", error);
      res.status(500).json({ error: "An error occurred while creating user" });
    }
  },

  logIn: async (req, res) => {
    try {
      const { username, password } = req.body;
      const result = await authService.logIn(username, password);
      res.status(200).json(result);
    } catch (error) {
      console.error("Log In Error:", error);
      res.status(500).json({ error: "An error occurred during login" });
    }
  },

  googleSignIn: async (req, res) => {
    try {
      const { idToken } = req.body;
      const result = await authService.googleSignIn(idToken);
      res.status(200).json(result);
    } catch (error) {
      console.error("Google Sign In Error:", error);
      res.status(500).json({ error: "An error occurred during Google sign in" });
    }
  },

  getUser: async (req, res) => {
    try {
      const { uid } = req.params;
      const user = await authService.getUser(uid);
      if (!user) return res.status(404).json({ message: "User not found" });
      res.status(200).json(user);
    } catch (error) {
      console.error("Get User Error:", error);
      res.status(500).json({ error: "An error occurred while retrieving user" });
    }
  },

  getAllUsers: async (req, res) => {
    try {
      const users = await authService.getAllUsers();
      res.status(200).json(users);
    } catch (error) {
      console.error("Get All Users Error:", error);
      res.status(500).json({ error: "An error occurred while retrieving users" });
    }
  },

  updateUser: async (req, res) => {
    try {
      const { uid } = req.params;
      const updatedData = req.body; // Ensure you're passing the correct data in the request body
      const updatedUser = await authService.updateUser(uid, updatedData);

      if (!updatedUser) {
        return res.status(404).json({ message: "User not found" });
      }

      res.status(200).json(updatedUser); // Respond with updated user details
    } catch (error) {
      console.error("Update User Error:", error);
      res.status(500).json({ error: "An error occurred while updating user" });
    }
  },

  deleteUser: async (req, res) => {
    try {
      const { uid } = req.params;
      const result = await authService.deleteUser(uid);
      res.status(200).json(result);
    } catch (error) {
      console.error("Delete User Error:", error);
      res.status(500).json({ error: "An error occurred while deleting user" });
    }
  }
};

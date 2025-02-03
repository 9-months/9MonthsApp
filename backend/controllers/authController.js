/*
 File: authController.js
 Purpose: Handles Handles HTTP requests for auth
 Created Date: 2025-01-29 CCS-30 Irosh Perera
 Author: Dinith Perera

 last modified: 2025-02-03 | Dinith | CCS-41 Create Controllers 
*/


const AuthService = require('../services/authService');

class AuthController {

  // create user
  async register(req, res) {
    try {
      const user = await AuthService.register(req.body);
      res.status(201).json(user);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  // login
  async login(req, res) {
    try {
      const user = await AuthService.login(req.body);
      res.status(200).json(user);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  // get user by id
  async getUser(req, res) {
    try {
      const user = await AuthService.getUserById(req.params.id);
      if (!user) return res.status(404).json({ message: 'User not found' });
      res.status(200).json(user);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  // update user
  async updateUser(req, res) {
    try {
      const user = await AuthService.updateUser(req.params.id, req.body);
      if (!user) return res.status(404).json({ message: 'User not found' });
      res.status(200).json(user);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  // Delete user
  async deleteUser(req, res) {
    try {
      const deleted = await AuthService.deleteUser(req.params.id);
      if (!deleted) return res.status(404).json({ message: 'User not found' });
      res.status(200).json({ message: 'User deleted' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
}

module.exports = new AuthController();
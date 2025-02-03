/*
 File: authRoutes.js
 Purpose: Defines routes for authentication-related operations and swagger documentation.
 Created Date: 2025-01-29 CCS-30 Irosh Perera
 Author: Dinith Perera

 last modified: 2025-02-03 | Dinith | CCS-41 Create Controllers 
*/

const express = require('express');
const router = express.Router();
const AuthController = require('../controllers/authController');

router.post('/register', AuthController.register);
router.post('/login', AuthController.login);
router.get('/:id', AuthController.getUser);
router.put('/:id', AuthController.updateUser);
router.delete('/:id', AuthController.deleteUser);

module.exports = router;
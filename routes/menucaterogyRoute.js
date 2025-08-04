import express from 'express';
//import parser from '../utils/multer.js';
//import { protect } from '../middleware/authMiddleware.js';
import { createMenuCategory } from '../controllers/menuCatController.js';

const router = express.Router();

// POST /restaurants
router.post('/create', createMenuCategory);

export default router;

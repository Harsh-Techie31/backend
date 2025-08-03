import express from 'express';
import parser from '../utils/multer.js';
import { protect } from '../middleware/authMiddleware.js';
import { createRestaurant } from '../controllers/restaurantController.js';

const router = express.Router();

// POST /restaurants
router.post('/create',protect, parser.array('images'), createRestaurant);

export default router;

import express from 'express';
import parser from '../utils/multer.js';
import { protect } from '../middleware/authMiddleware.js';
import { 
  createRestaurantReview,
  getRestaurantReviews,
  getReviewById,
  updateRestaurantReview,
  deleteRestaurantReview,
  getUserRestaurantReviews
} from '../controllers/restaurantReviewController.js';

const router = express.Router();

// Public routes
router.get('/restaurant/:restaurantId', getRestaurantReviews);
router.get('/:id', getReviewById);

// Protected routes
router.post('/create', protect, parser.array('images'), createRestaurantReview);
router.put('/:id', protect, parser.array('images'), updateRestaurantReview);
router.delete('/:id', protect, deleteRestaurantReview);
router.get('/user/my-reviews', protect, getUserRestaurantReviews);

export default router; 
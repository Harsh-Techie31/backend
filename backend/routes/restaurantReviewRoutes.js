import express from 'express';
import parser from '../utils/multer.js';
import { requireAuth } from '../middleware/authMiddleware.js';
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

// requireAuthed routes
router.post('/create', requireAuth, parser.array('images'), createRestaurantReview);
router.put('/:id', requireAuth, parser.array('images'), updateRestaurantReview);
router.delete('/:id', requireAuth, deleteRestaurantReview);
router.get('/user/my-reviews', requireAuth, getUserRestaurantReviews);

export default router; 
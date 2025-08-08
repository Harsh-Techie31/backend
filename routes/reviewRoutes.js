import express from 'express';
import { protect } from '../middleware/authMiddleware.js';
import { 
  createItemReview,
  getItemReviews,
  getReviewById,
  updateReview,
  deleteReview,
  getUserReviews
} from '../controllers/itemReviewController.js';

const router = express.Router();

// Public routes
router.get('/item/:itemId', getItemReviews);
router.get('/:id', getReviewById);

// Protected routes
router.post('/create', protect, createItemReview);
router.put('/:id', protect, updateReview);
router.delete('/:id', protect, deleteReview);
router.get('/user/my-reviews', protect, getUserReviews);

export default router; 
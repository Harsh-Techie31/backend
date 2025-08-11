import express from 'express';
import { requireAuth } from '../middleware/authMiddleware.js';
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

// requireAuthed routes
router.post('/create', requireAuth, createItemReview);
router.put('/:id', requireAuth, updateReview);
router.delete('/:id', requireAuth, deleteReview);
router.get('/user/my-reviews', requireAuth, getUserReviews);

export default router; 
import express from 'express';
import parser from '../utils/multer.js';
import { protect, authorize } from '../middleware/authMiddleware.js';
import { 
  createRestaurant,
  getRestaurants,
  getRestaurantById,
  updateRestaurant,
  deleteRestaurant,
  updateRestaurantApproval,
  getRestaurantsByOwner
} from '../controllers/restaurantController.js';

const router = express.Router();

// Public routes
router.get('/', getRestaurants);
router.get('/:id', getRestaurantById);

// Protected routes
router.post('/create', protect, authorize('OWNER', 'ADMIN'), parser.array('images'), createRestaurant);
router.put('/:id', protect, parser.array('images'), updateRestaurant);
router.delete('/:id', protect, deleteRestaurant);
router.get('/owner/my-restaurants', protect, authorize('OWNER'), getRestaurantsByOwner);

// Admin only routes
router.put('/:id/approval', protect, authorize('ADMIN'), updateRestaurantApproval);

export default router;

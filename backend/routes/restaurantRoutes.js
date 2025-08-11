import express from 'express';
import parser from '../utils/multer.js';
import { requireAuth, authorize } from '../middleware/authMiddleware.js';
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

// requireAuthed routes
router.post('/create', requireAuth, authorize('OWNER', 'ADMIN'), parser.array('images'), createRestaurant);
router.put('/:id', requireAuth, parser.array('images'), updateRestaurant);
router.delete('/:id', requireAuth, deleteRestaurant);
router.get('/owner/my-restaurants', requireAuth, authorize('OWNER'), getRestaurantsByOwner);

// Admin only routes
router.put('/:id/approval', requireAuth, authorize('ADMIN'), updateRestaurantApproval);

export default router;

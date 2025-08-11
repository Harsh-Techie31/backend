import express from 'express';
import parser from '../utils/multer.js';
import { requireAuth, authorize } from '../middleware/authMiddleware.js';
import { 
  createMenuItem,
  getMenuItems,
  getMenuItemById,
  updateMenuItem,
  deleteMenuItem,
  getMenuItemsByCategory
} from '../controllers/menuItemController.js';

const router = express.Router();

// Public routes
router.get('/restaurant/:restaurantId', getMenuItems);
router.get('/category/:categoryId', getMenuItemsByCategory);
router.get('/:id', getMenuItemById);

// requireAuthed routes
router.post('/create', requireAuth, authorize('OWNER', 'ADMIN'), parser.single('image'), createMenuItem);
router.put('/:id', requireAuth, authorize('OWNER', 'ADMIN'), parser.single('image'), updateMenuItem);
router.delete('/:id', requireAuth, authorize('OWNER', 'ADMIN'), deleteMenuItem);

export default router; 
import express from 'express';
import { protect, authorize } from '../middleware/authMiddleware.js';
import { 
  createMenuCategory,
  getMenuCategories,
  getMenuCategoryById,
  updateMenuCategory,
  deleteMenuCategory
} from '../controllers/menuCatController.js';

const router = express.Router();

// Public routes
router.get('/restaurant/:restaurantId', getMenuCategories);
router.get('/:id', getMenuCategoryById);

// Protected routes
router.post('/create', protect, createMenuCategory);
router.put('/:id', protect, updateMenuCategory);
router.delete('/:id', protect, deleteMenuCategory);

export default router;

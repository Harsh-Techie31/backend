import express from 'express';
import { requireAuth, authorize } from '../middleware/authMiddleware.js';
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

// requireAuthed routes
router.post('/create', requireAuth, createMenuCategory);
router.put('/:id', requireAuth, updateMenuCategory);
router.delete('/:id', requireAuth, deleteMenuCategory);

export default router;

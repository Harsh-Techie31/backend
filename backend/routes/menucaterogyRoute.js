// routes/menuCatRoutes.js
import express from 'express';
import { requireAuth } from '../middleware/authMiddleware.js';
import { 
  createMenuCategory,
  getMenuCategories,
  getMenuCategoryById,
  updateMenuCategory,
  deleteMenuCategory,
  reorderMenuCategories // 1. Import the new controller
} from '../controllers/menuCatController.js';

const router = express.Router();




// 2. Add the new reorder route
router.put('/reorder', requireAuth, reorderMenuCategories);
// Public routes
router.get('/restaurant/:restaurantId', getMenuCategories);
router.get('/:id', getMenuCategoryById);

// Authenticated routes
router.post('/create', requireAuth, createMenuCategory);
router.put('/:id', requireAuth, updateMenuCategory);
router.delete('/:id', requireAuth, deleteMenuCategory);



export default router;
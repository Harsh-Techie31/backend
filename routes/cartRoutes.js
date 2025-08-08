import express from 'express';
import { protect } from '../middleware/authMiddleware.js';
import { 
  getOrCreateCart,
  addToCart,
  updateCartItem,
  removeFromCart,
  clearCart,
  getUserCarts
} from '../controllers/cartController.js';

const router = express.Router();

// All cart routes require authentication
router.use(protect);

router.get('/restaurant/:restaurantId', getOrCreateCart);
router.post('/add', addToCart);
router.put('/item/:cartItemId', updateCartItem);
router.delete('/item/:cartItemId', removeFromCart);
router.delete('/:cartId/clear', clearCart);
router.get('/user/my-carts', getUserCarts);

export default router; 
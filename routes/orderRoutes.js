import express from 'express';
import { requireAuth, authorize } from '../middleware/authMiddleware.js';
import { 
  createOrder,
  getUserOrders,
  getOrderById,
  updateOrderStatus,
  getRestaurantOrders,
  cancelOrder
} from '../controllers/orderController.js';

const router = express.Router();

// All order routes require authentication
router.use(requireAuth);

// Customer routes
router.post('/create', createOrder);
router.get('/user/my-orders', getUserOrders);
router.get('/:id', getOrderById);
router.put('/:id/cancel', cancelOrder);

// Restaurant owner and admin routes
router.put('/:id/status', authorize('OWNER', 'ADMIN'), updateOrderStatus);
router.get('/restaurant/:restaurantId', authorize('OWNER', 'ADMIN'), getRestaurantOrders);

export default router; 
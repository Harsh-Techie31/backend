import express from 'express';
import { protect, authorize } from '../middleware/authMiddleware.js';
import { 
  getAdminLogs,
  getDashboardStats,
  getAllUsers,
  updateUserRole,
  deleteUser,
  getPendingRestaurants
} from '../controllers/adminController.js';

const router = express.Router();

// All admin routes require admin role
router.use(protect);
router.use(authorize('ADMIN'));

router.get('/logs', getAdminLogs);
router.get('/dashboard', getDashboardStats);
router.get('/users', getAllUsers);
router.put('/users/:userId/role', updateUserRole);
router.delete('/users/:userId', deleteUser);
router.get('/restaurants/pending', getPendingRestaurants);

export default router; 
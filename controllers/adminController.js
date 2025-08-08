import AdminLog from '../models/adminLog.js';
import User from '../models/user.js';
import Restaurant from '../models/restaurant.js';
import Order from '../models/order.js';

// Get admin logs
export const getAdminLogs = async (req, res) => {
  try {
    if (req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Only admins can view admin logs' });
    }

    const { page = 1, limit = 20, action, targetType } = req.query;

    const filter = {};
    if (action) filter.action = action;
    if (targetType) filter.targetType = targetType;

    const logs = await AdminLog.find(filter)
      .populate('adminId', 'name email')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .exec();

    const total = await AdminLog.countDocuments(filter);

    res.status(200).json({
      logs,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error('Get admin logs error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get dashboard statistics
export const getDashboardStats = async (req, res) => {
  try {
    if (req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Only admins can view dashboard stats' });
    }

    const [
      totalUsers,
      totalRestaurants,
      totalOrders,
      pendingRestaurants,
      recentOrders
    ] = await Promise.all([
      User.countDocuments(),
      Restaurant.countDocuments(),
      Order.countDocuments(),
      Restaurant.countDocuments({ isApproved: false }),
      Order.find().sort({ createdAt: -1 }).limit(5).populate('userId', 'name')
    ]);

    res.status(200).json({
      stats: {
        totalUsers,
        totalRestaurants,
        totalOrders,
        pendingRestaurants
      },
      recentOrders
    });
  } catch (error) {
    console.error('Get dashboard stats error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get all users (Admin only)
export const getAllUsers = async (req, res) => {
  try {
    if (req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Only admins can view all users' });
    }

    const { page = 1, limit = 20, role, search } = req.query;

    const filter = {};
    if (role) filter.role = role;
    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }

    const users = await User.find(filter)
      .select('-password')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .exec();

    const total = await User.countDocuments(filter);

    res.status(200).json({
      users,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error('Get all users error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Update user role (Admin only)
export const updateUserRole = async (req, res) => {
  try {
    const { userId } = req.params;
    const { role } = req.body;

    if (req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Only admins can update user roles' });
    }

    if (!['CUSTOMER', 'OWNER', 'ADMIN'].includes(role)) {
      return res.status(400).json({ message: 'Invalid role' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.role = role;
    await user.save();

    // Log admin action
    await AdminLog.create({
      adminId: req.user.id,
      action: 'UPDATE_USER_ROLE',
      targetType: 'USER',
      targetId: userId
    });

    res.status(200).json({
      message: 'User role updated successfully',
      user: { id: user._id, name: user.name, email: user.email, role: user.role }
    });
  } catch (error) {
    console.error('Update user role error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Delete user (Admin only)
export const deleteUser = async (req, res) => {
  try {
    const { userId } = req.params;

    if (req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Only admins can delete users' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    await User.findByIdAndDelete(userId);

    // Log admin action
    await AdminLog.create({
      adminId: req.user.id,
      action: 'DELETE_USER',
      targetType: 'USER',
      targetId: userId
    });

    res.status(200).json({ message: 'User deleted successfully' });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get pending restaurants (Admin only)
export const getPendingRestaurants = async (req, res) => {
  try {
    if (req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Only admins can view pending restaurants' });
    }

    const { page = 1, limit = 20 } = req.query;

    const restaurants = await Restaurant.find({ isApproved: false })
      .populate('ownerId', 'name email')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .exec();

    const total = await Restaurant.countDocuments({ isApproved: false });

    res.status(200).json({
      restaurants,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error('Get pending restaurants error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
}; 
import Order from '../models/order.js';
import OrderItem from '../models/orderItem.js';
import Cart from '../models/cart.js';
import CartItem from '../models/cartItem.js';
import MenuItem from '../models/menuItem.js';
import Restaurant from '../models/restaurant.js';

// Create order from cart
export const createOrder = async (req, res) => {
  try {
    const { cartId } = req.body;
    const userId = req.user.id;

    if (!cartId) {
      return res.status(400).json({ message: 'Cart ID is required' });
    }

    // Get cart and verify ownership
    const cart = await Cart.findOne({ _id: cartId, userId })
      .populate('restaurantId', 'name address');
    
    if (!cart) {
      return res.status(404).json({ message: 'Cart not found' });
    }

    // Get cart items
    const cartItems = await CartItem.find({ cartId })
      .populate('menuItemId', 'name price isAvailable');

    if (cartItems.length === 0) {
      return res.status(400).json({ message: 'Cart is empty' });
    }

    // Check if all items are available
    const unavailableItems = cartItems.filter(item => !item.menuItemId.isAvailable);
    if (unavailableItems.length > 0) {
      return res.status(400).json({ 
        message: 'Some items are not available',
        unavailableItems: unavailableItems.map(item => item.menuItemId.name)
      });
    }

    // Calculate total amount
    const totalAmount = cartItems.reduce((total, item) => {
      return total + (item.menuItemId.price * item.quantity);
    }, 0);

    // Create order
    const order = await Order.create({
      userId,
      restaurantId: cart.restaurantId._id,
      totalAmount,
      status: 'PLACED'
    });

    // Create order items
    const orderItems = await Promise.all(
      cartItems.map(async (cartItem) => {
        return await OrderItem.create({
          orderId: order._id,
          menuItemId: cartItem.menuItemId._id,
          quantity: cartItem.quantity,
          priceAtPurchase: cartItem.menuItemId.price
        });
      })
    );

    // Clear cart
    await CartItem.deleteMany({ cartId });

    // Populate order with details
    const populatedOrder = await Order.findById(order._id)
      .populate('restaurantId', 'name address')
      .populate('userId', 'name email');

    res.status(201).json({
      message: 'Order created successfully',
      order: populatedOrder,
      orderItems
    });
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get user's orders
export const getUserOrders = async (req, res) => {
  try {
    const userId = req.user.id;
    const { page = 1, limit = 10, status } = req.query;

    const filter = { userId };
    if (status) {
      filter.status = status;
    }

    const orders = await Order.find(filter)
      .populate('restaurantId', 'name address')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .exec();

    const total = await Order.countDocuments(filter);

    // Get order items for each order
    const ordersWithItems = await Promise.all(
      orders.map(async (order) => {
        const orderItems = await OrderItem.find({ orderId: order._id })
          .populate('menuItemId', 'name imageUrl');
        return { ...order.toObject(), orderItems };
      })
    );

    res.status(200).json({
      orders: ordersWithItems,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error('Get user orders error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get order by ID
export const getOrderById = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const order = await Order.findById(id)
      .populate('restaurantId', 'name address')
      .populate('userId', 'name email');

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    // Check if user is authorized to view this order
    if (order.userId.toString() !== userId && req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Not authorized to view this order' });
    }

    const orderItems = await OrderItem.find({ orderId: id })
      .populate('menuItemId', 'name imageUrl');

    res.status(200).json({
      order,
      orderItems
    });
  } catch (error) {
    console.error('Get order error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Update order status (Admin/Restaurant Owner only)
export const updateOrderStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const userId = req.user.id;

    if (!status || !['PLACED', 'PREPARING', 'DELIVERED', 'CANCELLED'].includes(status)) {
      return res.status(400).json({ message: 'Valid status is required' });
    }

    const order = await Order.findById(id);
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    // Check if user is authorized
    const restaurant = await Restaurant.findById(order.restaurantId);
    if (restaurant.ownerId.toString() !== userId && req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Not authorized to update this order' });
    }

    order.status = status;
    await order.save();

    const updatedOrder = await Order.findById(id)
      .populate('restaurantId', 'name address')
      .populate('userId', 'name email');

    res.status(200).json({
      message: 'Order status updated successfully',
      order: updatedOrder
    });
  } catch (error) {
    console.error('Update order status error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get restaurant orders (Restaurant Owner only)
export const getRestaurantOrders = async (req, res) => {
  try {
    const { restaurantId } = req.params;
    const userId = req.user.id;
    const { page = 1, limit = 10, status } = req.query;

    // Check if user is the restaurant owner
    const restaurant = await Restaurant.findById(restaurantId);
    if (!restaurant) {
      return res.status(404).json({ message: 'Restaurant not found' });
    }

    if (restaurant.ownerId.toString() !== userId && req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Not authorized to view restaurant orders' });
    }

    const filter = { restaurantId };
    if (status) {
      filter.status = status;
    }

    const orders = await Order.find(filter)
      .populate('userId', 'name email')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .exec();

    const total = await Order.countDocuments(filter);

    // Get order items for each order
    const ordersWithItems = await Promise.all(
      orders.map(async (order) => {
        const orderItems = await OrderItem.find({ orderId: order._id })
          .populate('menuItemId', 'name imageUrl');
        return { ...order.toObject(), orderItems };
      })
    );

    res.status(200).json({
      orders: ordersWithItems,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error('Get restaurant orders error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Cancel order (Customer only)
export const cancelOrder = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const order = await Order.findById(id);
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    // Check if user is the order owner
    if (order.userId.toString() !== userId) {
      return res.status(403).json({ message: 'Not authorized to cancel this order' });
    }

    // Check if order can be cancelled
    if (order.status === 'DELIVERED') {
      return res.status(400).json({ message: 'Cannot cancel delivered order' });
    }

    order.status = 'CANCELLED';
    await order.save();

    res.status(200).json({
      message: 'Order cancelled successfully',
      order
    });
  } catch (error) {
    console.error('Cancel order error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
}; 
import Cart from '../models/cart.js';
import CartItem from '../models/cartItem.js';
import MenuItem from '../models/menuItem.js';
import Restaurant from '../models/restaurant.js';

// Create or get user's cart for a restaurant
export const getOrCreateCart = async (req, res) => {
  try {
    const { restaurantId } = req.params;
    const userId = req.user.id;

    // Check if restaurant exists
    const restaurant = await Restaurant.findById(restaurantId);
    if (!restaurant) {
      return res.status(404).json({ message: 'Restaurant not found' });
    }

    // Find existing cart or create new one
    let cart = await Cart.findOne({ userId, restaurantId });
    
    if (!cart) {
      cart = await Cart.create({ userId, restaurantId });
    }

    // Get cart items
    const cartItems = await CartItem.find({ cartId: cart._id })
      .populate('menuItemId', 'name price imageUrl isAvailable');

    res.status(200).json({ cart, cartItems });
  } catch (error) {
    console.error('Get cart error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Add item to cart
export const addToCart = async (req, res) => {
  try {
    const { restaurantId, menuItemId, quantity = 1 } = req.body;
    const userId = req.user.id;

    // Validate required fields
    if (!restaurantId || !menuItemId) {
      return res.status(400).json({ message: 'Restaurant ID and menu item ID are required' });
    }

    // Check if menu item exists and is available
    const menuItem = await MenuItem.findById(menuItemId);
    if (!menuItem) {
      return res.status(404).json({ message: 'Menu item not found' });
    }

    if (!menuItem.isAvailable) {
      return res.status(400).json({ message: 'Menu item is not available' });
    }

    // Check if menu item belongs to the restaurant
    if (menuItem.restaurantId.toString() !== restaurantId) {
      return res.status(400).json({ message: 'Menu item does not belong to this restaurant' });
    }

    // Get or create cart
    let cart = await Cart.findOne({ userId, restaurantId });
    if (!cart) {
      cart = await Cart.create({ userId, restaurantId });
    }

    // Check if item already exists in cart
    let cartItem = await CartItem.findOne({ cartId: cart._id, menuItemId });
    
    if (cartItem) {
      // Update quantity
      cartItem.quantity += parseInt(quantity);
      await cartItem.save();
    } else {
      // Create new cart item
      cartItem = await CartItem.create({
        cartId: cart._id,
        menuItemId,
        quantity: parseInt(quantity)
      });
    }

    // Get updated cart items
    const cartItems = await CartItem.find({ cartId: cart._id })
      .populate('menuItemId', 'name price imageUrl');

    res.status(200).json({
      message: 'Item added to cart successfully',
      cart,
      cartItems
    });
  } catch (error) {
    console.error('Add to cart error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Update cart item quantity
export const updateCartItem = async (req, res) => {
  try {
    const { cartItemId } = req.params;
    const { quantity } = req.body;
    const userId = req.user.id;

    if (!quantity || quantity < 1) {
      return res.status(400).json({ message: 'Valid quantity is required' });
    }

    const cartItem = await CartItem.findById(cartItemId)
      .populate({
        path: 'cartId',
        match: { userId }
      });

    if (!cartItem || !cartItem.cartId) {
      return res.status(404).json({ message: 'Cart item not found' });
    }

    cartItem.quantity = parseInt(quantity);
    await cartItem.save();

    res.status(200).json({
      message: 'Cart item updated successfully',
      cartItem
    });
  } catch (error) {
    console.error('Update cart item error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Remove item from cart
export const removeFromCart = async (req, res) => {
  try {
    const { cartItemId } = req.params;
    const userId = req.user.id;

    const cartItem = await CartItem.findById(cartItemId)
      .populate({
        path: 'cartId',
        match: { userId }
      });

    if (!cartItem || !cartItem.cartId) {
      return res.status(404).json({ message: 'Cart item not found' });
    }

    await CartItem.findByIdAndDelete(cartItemId);

    res.status(200).json({ message: 'Item removed from cart successfully' });
  } catch (error) {
    console.error('Remove from cart error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Clear cart
export const clearCart = async (req, res) => {
  try {
    const { cartId } = req.params;
    const userId = req.user.id;

    const cart = await Cart.findOne({ _id: cartId, userId });
    if (!cart) {
      return res.status(404).json({ message: 'Cart not found' });
    }

    await CartItem.deleteMany({ cartId });

    res.status(200).json({ message: 'Cart cleared successfully' });
  } catch (error) {
    console.error('Clear cart error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get user's carts
export const getUserCarts = async (req, res) => {
  try {
    const userId = req.user.id;

    const carts = await Cart.find({ userId })
      .populate('restaurantId', 'name address')
      .sort({ createdAt: -1 });

    // Get cart items for each cart
    const cartsWithItems = await Promise.all(
      carts.map(async (cart) => {
        const cartItems = await CartItem.find({ cartId: cart._id })
          .populate('menuItemId', 'name price imageUrl');
        return { ...cart.toObject(), cartItems };
      })
    );

    res.status(200).json({ carts: cartsWithItems });
  } catch (error) {
    console.error('Get user carts error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
}; 
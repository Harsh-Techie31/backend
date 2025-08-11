import MenuItem from '../models/menuItem.js';
import MenuCategory from '../models/menuCat.js';
import Restaurant from '../models/restaurant.js';

// Create menu item
export const createMenuItem = async (req, res) => {
  try {
    const { name, description, price, categoryId, restaurantId } = req.body;
    const userId = req.user.id;
    
    // Validate required fields
    if (!name || !description || !price || !categoryId || !restaurantId) {
      return res.status(400).json({ message: 'All fields are required' });
    }

    // Check if restaurant exists and user is authorized
    const restaurant = await Restaurant.findById(restaurantId);
    if (!restaurant) {
      return res.status(404).json({ message: 'Restaurant not found' });
    }

    // Check if user is the restaurant owner or admin
    if (restaurant.ownerId.toString() !== userId && req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Not authorized to create items for this restaurant' });
    }

    // Check if category exists and belongs to the restaurant
    const category = await MenuCategory.findById(categoryId);
    if (!category || category.restaurantId.toString() !== restaurantId) {
      return res.status(404).json({ message: 'Category not found or does not belong to this restaurant' });
    }

    const menuItem = await MenuItem.create({
      name,
      description,
      price: parseFloat(price),
      categoryId,
      restaurantId,
      imageUrl: req.file ? req.file.path : null
    });

    res.status(201).json({ 
      message: 'Menu item created successfully', 
      menuItem 
    });
  } catch (error) {
    console.error('Create menu item error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get menu items by restaurant
export const getMenuItems = async (req, res) => {
  try {
    const { restaurantId } = req.params;
    const { categoryId, isAvailable } = req.query;
    
    const filter = { restaurantId };
    
    if (categoryId) {
      filter.categoryId = categoryId;
    }
    
    if (isAvailable !== undefined) {
      filter.isAvailable = isAvailable === 'true';
    }

    const menuItems = await MenuItem.find(filter)
      .populate('categoryId', 'name')
      .sort({ createdAt: -1 });

    res.status(200).json({ menuItems });
  } catch (error) {
    console.error('Get menu items error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get menu item by ID
export const getMenuItemById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const menuItem = await MenuItem.findById(id)
      .populate('categoryId', 'name')
      .populate('restaurantId', 'name');

    if (!menuItem) {
      return res.status(404).json({ message: 'Menu item not found' });
    }

    res.status(200).json({ menuItem });
  } catch (error) {
    console.error('Get menu item error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Update menu item
export const updateMenuItem = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, price, categoryId, isAvailable } = req.body;
    const userId = req.user.id;

    const menuItem = await MenuItem.findById(id);
    if (!menuItem) {
      return res.status(404).json({ message: 'Menu item not found' });
    }

    // Check if user is authorized
    const restaurant = await Restaurant.findById(menuItem.restaurantId);
    if (restaurant.ownerId.toString() !== userId && req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Not authorized to update this item' });
    }

    const updateData = {};
    if (name) updateData.name = name;
    if (description) updateData.description = description;
    if (price !== undefined) updateData.price = parseFloat(price);
    if (categoryId) updateData.categoryId = categoryId;
    if (isAvailable !== undefined) updateData.isAvailable = isAvailable;

    // Handle new image if uploaded
    if (req.file) {
      updateData.imageUrl = req.file.path;
    }

    const updatedItem = await MenuItem.findByIdAndUpdate(
      id,
      updateData,
      { new: true, runValidators: true }
    );

    res.status(200).json({
      message: 'Menu item updated successfully',
      menuItem: updatedItem
    });
  } catch (error) {
    console.error('Update menu item error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Delete menu item
export const deleteMenuItem = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const menuItem = await MenuItem.findById(id);
    if (!menuItem) {
      return res.status(404).json({ message: 'Menu item not found' });
    }

    // Check if user is authorized
    const restaurant = await Restaurant.findById(menuItem.restaurantId);
    if (restaurant.ownerId.toString() !== userId && req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Not authorized to delete this item' });
    }

    await MenuItem.findByIdAndDelete(id);

    res.status(200).json({ message: 'Menu item deleted successfully' });
  } catch (error) {
    console.error('Delete menu item error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get menu items by category
export const getMenuItemsByCategory = async (req, res) => {
  try {
    const { categoryId } = req.params;
    const { isAvailable } = req.query;
    
    const filter = { categoryId };
    if (isAvailable !== undefined) {
      filter.isAvailable = isAvailable === 'true';
    }

    const menuItems = await MenuItem.find(filter)
      .populate('categoryId', 'name')
      .sort({ createdAt: -1 });

    res.status(200).json({ menuItems });
  } catch (error) {
    console.error('Get menu items by category error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
}; 
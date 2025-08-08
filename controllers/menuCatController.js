// controllers/restaurantController.js
import MenuCategory from '../models/menuCat.js';
import Restaurant from '../models/restaurant.js';

// Create menu category
export const createMenuCategory = async (req, res) => {
  try {
    const { name, position, restaurantId } = req.body;
    const userId = req.user.id;
    
    // Validate required fields
    if (!name || !position || !restaurantId) {
      return res.status(400).json({ message: 'Name, position, and restaurantId are required' });
    }

    // Check if restaurant exists and user is authorized
    const restaurant = await Restaurant.findById(restaurantId);
    if (!restaurant) {
      return res.status(404).json({ message: 'Restaurant not found' });
    }

    // Check if user is the restaurant owner or admin
    if (restaurant.ownerId.toString() !== userId && req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Not authorized to create categories for this restaurant' });
    }

    const menuCategory = await MenuCategory.create({
      name,
      position: parseInt(position),
      restaurantId
    });

    res.status(201).json({ 
      message: 'Menu category created successfully', 
      menuCategory 
    });
  } catch (error) {
    console.error('Create menu category error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get menu categories by restaurant
export const getMenuCategories = async (req, res) => {
  try {
    const { restaurantId } = req.params;
    
    const menuCategories = await MenuCategory.find({ restaurantId })
      .sort({ position: 1, createdAt: 1 });

    res.status(200).json({ menuCategories });
  } catch (error) {
    console.error('Get menu categories error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get menu category by ID
export const getMenuCategoryById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const menuCategory = await MenuCategory.findById(id);
    if (!menuCategory) {
      return res.status(404).json({ message: 'Menu category not found' });
    }

    res.status(200).json({ menuCategory });
  } catch (error) {
    console.error('Get menu category error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Update menu category
export const updateMenuCategory = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, position } = req.body;
    const userId = req.user.id;

    const menuCategory = await MenuCategory.findById(id);
    if (!menuCategory) {
      return res.status(404).json({ message: 'Menu category not found' });
    }

    // Check if user is authorized
    const restaurant = await Restaurant.findById(menuCategory.restaurantId);
    if (restaurant.ownerId.toString() !== userId && req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Not authorized to update this category' });
    }

    const updateData = {};
    if (name) updateData.name = name;
    if (position !== undefined) updateData.position = parseInt(position);

    const updatedCategory = await MenuCategory.findByIdAndUpdate(
      id,
      updateData,
      { new: true, runValidators: true }
    );

    res.status(200).json({
      message: 'Menu category updated successfully',
      menuCategory: updatedCategory
    });
  } catch (error) {
    console.error('Update menu category error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Delete menu category
export const deleteMenuCategory = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const menuCategory = await MenuCategory.findById(id);
    if (!menuCategory) {
      return res.status(404).json({ message: 'Menu category not found' });
    }

    // Check if user is authorized
    const restaurant = await Restaurant.findById(menuCategory.restaurantId);
    if (restaurant.ownerId.toString() !== userId && req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Not authorized to delete this category' });
    }

    await MenuCategory.findByIdAndDelete(id);

    res.status(200).json({ message: 'Menu category deleted successfully' });
  } catch (error) {
    console.error('Delete menu category error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

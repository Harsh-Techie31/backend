// controllers/restaurantController.js
import Restaurant from '../models/restaurant.js';
import User from '../models/user.js';
import AdminLog from '../models/adminLog.js';

// Create restaurant
export const createRestaurant = async (req, res) => {
  try {
    const { name, description, address, lat, lng } = req.body;
    const ownerId = req.user.id;

    // Validate required fields
    if (!name || !description || !address || lat === undefined || lng === undefined) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    // Validate images
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ message: 'At least one image is required' });
    }

    // Check if user is an owner
    const owner = await User.findById(ownerId);
    if (!owner) {
      return res.status(404).json({ message: 'User not found' });
    }
    if (owner.role !== 'OWNER') {
      return res.status(403).json({ message: 'Only restaurant owners can create restaurants' });
    }

    const imageUrls = req.files.map(file => file.path);

    const restaurant = await Restaurant.create({
      name,
      description,
      address,
      lat: parseFloat(lat),
      lng: parseFloat(lng),
      ownerId,
      images: imageUrls
    });

    res.status(201).json({ 
      message: 'Restaurant created successfully', 
      restaurant 
    });
  } catch (error) {
    console.error('Create restaurant error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get all restaurants (with optional filtering)
export const getRestaurants = async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      search, 
      isApproved,
      minRating 
    } = req.query;

    const filter = {};
    
    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { address: { $regex: search, $options: 'i' } }
      ];
    }
    
    if (isApproved !== undefined) {
      filter.isApproved = isApproved === 'true';
    }
    
    if (minRating) {
      filter.averageRating = { $gte: parseFloat(minRating) };
    }

    const restaurants = await Restaurant.find(filter)
      .populate('ownerId', 'name email')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .exec();

    const total = await Restaurant.countDocuments(filter);

    res.status(200).json({
      restaurants,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error('Get restaurants error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get restaurant by ID
export const getRestaurantById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const restaurant = await Restaurant.findById(id)
      .populate('ownerId', 'name email phone');

    if (!restaurant) {
      return res.status(404).json({ message: 'Restaurant not found' });
    }

    res.status(200).json({ restaurant });
  } catch (error) {
    console.error('Get restaurant error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Update restaurant
export const updateRestaurant = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, address, lat, lng } = req.body;
    const userId = req.user.id;

    const restaurant = await Restaurant.findById(id);
    if (!restaurant) {
      return res.status(404).json({ message: 'Restaurant not found' });
    }

    // Check if user is the owner or admin
    if (restaurant.ownerId.toString() !== userId && req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Not authorized to update this restaurant' });
    }

    const updateData = {};
    if (name) updateData.name = name;
    if (description) updateData.description = description;
    if (address) updateData.address = address;
    if (lat !== undefined) updateData.lat = parseFloat(lat);
    if (lng !== undefined) updateData.lng = parseFloat(lng);

    // Handle new images if uploaded
    if (req.files && req.files.length > 0) {
      const newImageUrls = req.files.map(file => file.path);
      updateData.images = [...restaurant.images, ...newImageUrls];
    }

    const updatedRestaurant = await Restaurant.findByIdAndUpdate(
      id,
      updateData,
      { new: true, runValidators: true }
    );

    res.status(200).json({
      message: 'Restaurant updated successfully',
      restaurant: updatedRestaurant
    });
  } catch (error) {
    console.error('Update restaurant error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Delete restaurant
export const deleteRestaurant = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const restaurant = await Restaurant.findById(id);
    if (!restaurant) {
      return res.status(404).json({ message: 'Restaurant not found' });
    }

    // Check if user is the owner or admin
    if (restaurant.ownerId.toString() !== userId && req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Not authorized to delete this restaurant' });
    }

    await Restaurant.findByIdAndDelete(id);

    res.status(200).json({ message: 'Restaurant deleted successfully' });
  } catch (error) {
    console.error('Delete restaurant error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Approve/Reject restaurant (Admin only)
export const updateRestaurantApproval = async (req, res) => {
  try {
    const { id } = req.params;
    const { isApproved } = req.body;

    if (req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Only admins can approve restaurants' });
    }

    const restaurant = await Restaurant.findById(id);
    if (!restaurant) {
      return res.status(404).json({ message: 'Restaurant not found' });
    }

    restaurant.isApproved = isApproved;
    await restaurant.save();

    // Log admin action
    await AdminLog.create({
      adminId: req.user.id,
      action: isApproved ? 'APPROVE_RESTAURANT' : 'REJECT_RESTAURANT',
      targetType: 'RESTAURANT',
      targetId: id
    });

    res.status(200).json({
      message: `Restaurant ${isApproved ? 'approved' : 'rejected'} successfully`,
      restaurant
    });
  } catch (error) {
    console.error('Update restaurant approval error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get restaurants by owner
export const getRestaurantsByOwner = async (req, res) => {
  try {
    const ownerId = req.user.id;
    
    const restaurants = await Restaurant.find({ ownerId })
      .sort({ createdAt: -1 });

    res.status(200).json({ restaurants });
  } catch (error) {
    console.error('Get owner restaurants error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// controllers/restaurantReviewController.js
import RestaurantReview from '../models/restaurantReview.js';
import Restaurant from '../models/restaurant.js';
import User from '../models/user.js';

// Create restaurant review
export const createRestaurantReview = async (req, res) => {
  try {
    const { restaurantId, rating, comment } = req.body;
    const userId = req.user.id;
    
    // Validate required fields
    if (!restaurantId || !rating) {
      return res.status(400).json({ message: 'Restaurant ID and rating are required' });
    }

    // Validate rating
    if (rating < 1 || rating > 5) {
      return res.status(400).json({ message: 'Rating must be between 1 and 5' });
    }

    // Check if restaurant exists and is approved
    const restaurant = await Restaurant.findById(restaurantId);
    if (!restaurant) {
      return res.status(404).json({ message: 'Restaurant not found' });
    }

    if (!restaurant.isApproved) {
      return res.status(400).json({ message: 'Cannot review unapproved restaurant' });
    }

    // Check if user has already reviewed this restaurant
    const existingReview = await RestaurantReview.findOne({ restaurantId, userId });
    if (existingReview) {
      return res.status(400).json({ message: 'You have already reviewed this restaurant' });
    }

    const review = await RestaurantReview.create({
      restaurantId,
      userId,
      rating: parseInt(rating),
      comment,
      images: req.files ? req.files.map(file => file.path) : []
    });

    // Update restaurant average rating
    await updateRestaurantAverageRating(restaurantId);

    const populatedReview = await RestaurantReview.findById(review._id)
      .populate('userId', 'name')
      .populate('restaurantId', 'name');

    res.status(201).json({ 
      message: 'Review created successfully', 
      review: populatedReview 
    });
  } catch (error) {
    console.error('Create restaurant review error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get restaurant reviews
export const getRestaurantReviews = async (req, res) => {
  try {
    const { restaurantId } = req.params;
    const { page = 1, limit = 10, rating } = req.query;
    
    const filter = { restaurantId };
    if (rating) {
      filter.rating = parseInt(rating);
    }

    const reviews = await RestaurantReview.find(filter)
      .populate('userId', 'name')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .exec();

    const total = await RestaurantReview.countDocuments(filter);

    res.status(200).json({
      reviews,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error('Get restaurant reviews error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get review by ID
export const getReviewById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const review = await RestaurantReview.findById(id)
      .populate('userId', 'name')
      .populate('restaurantId', 'name');

    if (!review) {
      return res.status(404).json({ message: 'Review not found' });
    }

    res.status(200).json({ review });
  } catch (error) {
    console.error('Get review error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Update restaurant review
export const updateRestaurantReview = async (req, res) => {
  try {
    const { id } = req.params;
    const { rating, comment } = req.body;
    const userId = req.user.id;

    const review = await RestaurantReview.findById(id);
    if (!review) {
      return res.status(404).json({ message: 'Review not found' });
    }

    // Check if user is the review author
    if (review.userId.toString() !== userId) {
      return res.status(403).json({ message: 'Not authorized to update this review' });
    }

    const updateData = {};
    if (rating !== undefined) {
      if (rating < 1 || rating > 5) {
        return res.status(400).json({ message: 'Rating must be between 1 and 5' });
      }
      updateData.rating = parseInt(rating);
    }
    if (comment !== undefined) updateData.comment = comment;

    // Handle new images if uploaded
    if (req.files && req.files.length > 0) {
      updateData.images = [...review.images, ...req.files.map(file => file.path)];
    }

    const updatedReview = await RestaurantReview.findByIdAndUpdate(
      id,
      updateData,
      { new: true, runValidators: true }
    ).populate('userId', 'name').populate('restaurantId', 'name');

    // Update restaurant average rating
    await updateRestaurantAverageRating(review.restaurantId);

    res.status(200).json({
      message: 'Review updated successfully',
      review: updatedReview
    });
  } catch (error) {
    console.error('Update restaurant review error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Delete restaurant review
export const deleteRestaurantReview = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const review = await RestaurantReview.findById(id);
    if (!review) {
      return res.status(404).json({ message: 'Review not found' });
    }

    // Check if user is the review author or admin
    if (review.userId.toString() !== userId && req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Not authorized to delete this review' });
    }

    const restaurantId = review.restaurantId;
    await RestaurantReview.findByIdAndDelete(id);

    // Update restaurant average rating
    await updateRestaurantAverageRating(restaurantId);

    res.status(200).json({ message: 'Review deleted successfully' });
  } catch (error) {
    console.error('Delete restaurant review error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get user's restaurant reviews
export const getUserRestaurantReviews = async (req, res) => {
  try {
    const userId = req.user.id;
    const { page = 1, limit = 10 } = req.query;
    
    const reviews = await RestaurantReview.find({ userId })
      .populate('restaurantId', 'name address')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .exec();

    const total = await RestaurantReview.countDocuments({ userId });

    res.status(200).json({
      reviews,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error('Get user restaurant reviews error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Helper function to update restaurant average rating
const updateRestaurantAverageRating = async (restaurantId) => {
  try {
    const reviews = await RestaurantReview.find({ restaurantId });
    if (reviews.length === 0) {
      await Restaurant.findByIdAndUpdate(restaurantId, { averageRating: 0 });
      return;
    }

    const totalRating = reviews.reduce((sum, review) => sum + review.rating, 0);
    const averageRating = totalRating / reviews.length;

    await Restaurant.findByIdAndUpdate(restaurantId, { averageRating });
  } catch (error) {
    console.error('Update restaurant average rating error:', error);
  }
}; 
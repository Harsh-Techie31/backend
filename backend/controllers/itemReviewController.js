import ItemReview from '../models/itemReview.js';
import MenuItem from '../models/menuItem.js';
import Restaurant from '../models/restaurant.js';

// Create item review
export const createItemReview = async (req, res) => {
  try {
    const { itemId, rating, comment } = req.body;
    const userId = req.user.id;
    
    // Validate required fields
    if (!itemId || !rating) {
      return res.status(400).json({ message: 'Item ID and rating are required' });
    }

    // Validate rating
    if (rating < 1 || rating > 5) {
      return res.status(400).json({ message: 'Rating must be between 1 and 5' });
    }

    // Check if menu item exists
    const menuItem = await MenuItem.findById(itemId);
    if (!menuItem) {
      return res.status(404).json({ message: 'Menu item not found' });
    }

    // Check if user has already reviewed this item
    const existingReview = await ItemReview.findOne({ itemId, userId });
    if (existingReview) {
      return res.status(400).json({ message: 'You have already reviewed this item' });
    }

    const review = await ItemReview.create({
      itemId,
      userId,
      rating: parseInt(rating),
      comment
    });

    // Update average rating for the menu item
    await updateMenuItemAverageRating(itemId);

    res.status(201).json({ 
      message: 'Review created successfully', 
      review 
    });
  } catch (error) {
    console.error('Create review error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get reviews by item
export const getItemReviews = async (req, res) => {
  try {
    const { itemId } = req.params;
    const { page = 1, limit = 10 } = req.query;
    
    const reviews = await ItemReview.find({ itemId })
      .populate('userId', 'name')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .exec();

    const total = await ItemReview.countDocuments({ itemId });

    res.status(200).json({
      reviews,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error('Get reviews error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get review by ID
export const getReviewById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const review = await ItemReview.findById(id)
      .populate('userId', 'name')
      .populate('itemId', 'name');

    if (!review) {
      return res.status(404).json({ message: 'Review not found' });
    }

    res.status(200).json({ review });
  } catch (error) {
    console.error('Get review error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Update review
export const updateReview = async (req, res) => {
  try {
    const { id } = req.params;
    const { rating, comment } = req.body;
    const userId = req.user.id;

    const review = await ItemReview.findById(id);
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

    const updatedReview = await ItemReview.findByIdAndUpdate(
      id,
      updateData,
      { new: true, runValidators: true }
    );

    // Update average rating for the menu item
    await updateMenuItemAverageRating(review.itemId);

    res.status(200).json({
      message: 'Review updated successfully',
      review: updatedReview
    });
  } catch (error) {
    console.error('Update review error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Delete review
export const deleteReview = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const review = await ItemReview.findById(id);
    if (!review) {
      return res.status(404).json({ message: 'Review not found' });
    }

    // Check if user is the review author or admin
    if (review.userId.toString() !== userId && req.user.role !== 'ADMIN') {
      return res.status(403).json({ message: 'Not authorized to delete this review' });
    }

    const itemId = review.itemId;
    await ItemReview.findByIdAndDelete(id);

    // Update average rating for the menu item
    await updateMenuItemAverageRating(itemId);

    res.status(200).json({ message: 'Review deleted successfully' });
  } catch (error) {
    console.error('Delete review error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Get user's reviews
export const getUserReviews = async (req, res) => {
  try {
    const userId = req.user.id;
    const { page = 1, limit = 10 } = req.query;
    
    const reviews = await ItemReview.find({ userId })
      .populate('itemId', 'name')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .exec();

    const total = await ItemReview.countDocuments({ userId });

    res.status(200).json({
      reviews,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error('Get user reviews error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Helper function to update menu item average rating
const updateMenuItemAverageRating = async (itemId) => {
  try {
    const reviews = await ItemReview.find({ itemId });
    if (reviews.length === 0) {
      await MenuItem.findByIdAndUpdate(itemId, { averageRating: 0 });
      return;
    }

    const totalRating = reviews.reduce((sum, review) => sum + review.rating, 0);
    const averageRating = totalRating / reviews.length;

    await MenuItem.findByIdAndUpdate(itemId, { averageRating });
  } catch (error) {
    console.error('Update average rating error:', error);
  }
}; 
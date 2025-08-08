// models/restaurantReview.js
import mongoose from 'mongoose';

const restaurantReviewSchema = new mongoose.Schema({
  restaurantId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'Restaurant'
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'User'
  },
  rating: {
    type: Number,
    required: true,
    min: 1,
    max: 5
  },
  comment: {
    type: String,
    trim: true,
    maxlength: 500
  },
  images: {
    type: [String],
    default: []
  },
  isVerified: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

// Ensure one review per user per restaurant
restaurantReviewSchema.index({ restaurantId: 1, userId: 1 }, { unique: true });

// Index for better query performance
restaurantReviewSchema.index({ restaurantId: 1, createdAt: -1 });
restaurantReviewSchema.index({ userId: 1, createdAt: -1 });
restaurantReviewSchema.index({ rating: 1 });

const RestaurantReview = mongoose.model('RestaurantReview', restaurantReviewSchema);
export default RestaurantReview; 
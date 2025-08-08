// models/itemReview.js
import mongoose from 'mongoose';

const itemReviewSchema = new mongoose.Schema({
  itemId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'MenuItem'
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
    trim: true
  }
}, {
  timestamps: true
});

const ItemReview = mongoose.model('ItemReview', itemReviewSchema);
export default ItemReview; 
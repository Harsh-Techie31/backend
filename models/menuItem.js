// models/menuItem.js
import mongoose from 'mongoose';

const menuItemSchema = new mongoose.Schema({
  restaurantId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'Restaurant'
  },
  categoryId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'MenuCategory'
  },
  name: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    required: true
  },
  price: {
    type: Number,
    required: true,
    min: 0
  },
  imageUrl: {
    type: String
  },
  isAvailable: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

const MenuItem = mongoose.model('MenuItem', menuItemSchema);
export default MenuItem; 
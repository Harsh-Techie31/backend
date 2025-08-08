// models/menuCat.js
import mongoose from 'mongoose';

const menuCategorySchema = new mongoose.Schema({
  restaurantId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'Restaurant'
  },
  name: {
    type: String,
    required: true,
    trim: true
  },
  position: {
    type: Number,
    required: true,
    min: 1
  }
}, {
  timestamps: true
});

const MenuCategory = mongoose.model('MenuCategory', menuCategorySchema);
export default MenuCategory;

// models/restaurant.js
import mongoose from 'mongoose';

const menuCategorySchema = new mongoose.Schema({
  restaurantID: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'Restaurant'
  },
  name: {
    type: String,
    required: true
  },
  position: {
    type: Number,
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const MenuCat = mongoose.model('Menu Category', menuCategorySchema);
export default MenuCat;

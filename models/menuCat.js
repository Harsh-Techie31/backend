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
  postion: {
    type: Number,
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const Restaurant = mongoose.model('Restaurant', menuCategorySchema);
export default Restaurant;

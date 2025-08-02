// models/restaurant.js
import mongoose from 'mongoose';

const restaurantSchema = new mongoose.Schema({
  ownerId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'User'
  },
  name: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  address: {
    type: String,
    required: true
  },
  lat: {
    type: String,
    required: true
  },
  lng: {
    type: String,
    required: true
  },
  averageRating: {
    type: Number,
    default: 0
  },
  noOfRatings: {
    type: Number,
    default: 0
  },
  isApproved: {
    type: Boolean,
    required: true,
    default: false
  },
  images: {
    type: [String],
    required: true,
    default: []
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const Restaurant = mongoose.model('Restaurant', restaurantSchema);
export default Restaurant;

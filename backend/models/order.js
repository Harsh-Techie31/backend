// models/order.js
import mongoose from 'mongoose';

const orderSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'User'
  },
  restaurantId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'Restaurant'
  },
  status: {
    type: String,
    enum: ['PLACED', 'PREPARING', 'DELIVERED', 'CANCELLED'],
    default: 'PLACED'
  },
  totalAmount: {
    type: Number,
    required: true,
    min: 0
  }
}, {
  timestamps: true
});

const Order = mongoose.model('Order', orderSchema);
export default Order; 
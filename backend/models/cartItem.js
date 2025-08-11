// models/cartItem.js
import mongoose from 'mongoose';

const cartItemSchema = new mongoose.Schema({
  cartId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'Cart'
  },
  menuItemId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'MenuItem'
  },
  quantity: {
    type: Number,
    required: true,
    min: 1
  }
}, {
  timestamps: true
});

const CartItem = mongoose.model('CartItem', cartItemSchema);
export default CartItem; 
// models/user.js
import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({ 
    
  name: String,
  email: { type: String, unique: true },
  password: String,
  role: {
    type: String,
    enum: ['customer', 'restaurant_owner', 'admin'],
    default: 'customer'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const User = mongoose.model('User', userSchema);
export default User;

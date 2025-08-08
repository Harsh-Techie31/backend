// models/user.js
import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({ 
  name: {
    type: String,
    required: true,
    trim: true
  },
  email: { 
    type: String, 
    unique: true,
    required: true,
    lowercase: true,
    trim: true
  },
  password: {
    type: String,
    required: true
  },
  role: {
    type: String,
    enum: ['CUSTOMER', 'OWNER', 'ADMIN'],
    default: 'CUSTOMER'
  },
  phone: {
    type: String,
    trim: true
  }
}, {
  timestamps: true
});

const User = mongoose.model('User', userSchema);
export default User;

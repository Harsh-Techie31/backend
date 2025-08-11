// models/adminLog.js
import mongoose from 'mongoose';

const adminLogSchema = new mongoose.Schema({
  adminId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'User'
  },
  action: {
    type: String,
    required: true,
    enum: [
      'APPROVE_RESTAURANT',
      'REJECT_RESTAURANT',
      'UPDATE_USER_ROLE',
      'DELETE_USER',
      'DELETE_RESTAURANT',
      'UPDATE_ORDER_STATUS',
      'MANAGE_MENU_ITEM',
      'MANAGE_CATEGORY'
    ]
  },
  targetType: {
    type: String,
    required: true,
    enum: ['USER', 'RESTAURANT', 'ORDER', 'MENU_ITEM', 'CATEGORY']
  },
  targetId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true
  },
  details: {
    type: String,
    trim: true
  },
  ipAddress: {
    type: String
  },
  userAgent: {
    type: String
  }
}, {
  timestamps: true
});

// Index for better query performance
adminLogSchema.index({ adminId: 1, createdAt: -1 });
adminLogSchema.index({ action: 1, createdAt: -1 });
adminLogSchema.index({ targetType: 1, targetId: 1 });

const AdminLog = mongoose.model('AdminLog', adminLogSchema);
export default AdminLog; 
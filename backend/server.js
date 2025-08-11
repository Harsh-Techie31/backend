import express, { json } from 'express';
import { connect } from 'mongoose';
import { config } from 'dotenv';
import cors from 'cors';

// Import routes
import authRoutes from './routes/authRoutes.js';
import restaurantRoutes from './routes/restaurantRoutes.js';
import menuCatRoutes from './routes/menucaterogyRoute.js';
import menuItemRoutes from './routes/menuItemRoutes.js';
import reviewRoutes from './routes/reviewRoutes.js';
import restaurantReviewRoutes from './routes/restaurantReviewRoutes.js';
import cartRoutes from './routes/cartRoutes.js';
import orderRoutes from './routes/orderRoutes.js';
import adminRoutes from './routes/adminRoutes.js';

config();

const app = express();

// Middleware
app.use(json());
app.use(cors({
  origin:'http://localhost:3000',
  credentials: true
}));

// Connect to MongoDB
connect(process.env.MONGO_URI)
  .then(() => console.log("MongoDB connected"))
  .catch(err => console.error("MongoDB error:", err));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/restaurant', restaurantRoutes);
app.use('/api/menucat', menuCatRoutes);
app.use('/api/menuitem', menuItemRoutes);
app.use('/api/review', reviewRoutes);
app.use('/api/restaurant-reviews', restaurantReviewRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/order', orderRoutes);
app.use('/api/admin', adminRoutes);

// Health check
app.get('/', (req, res) => {
  res.json({ 
    message: 'Restaurant Management API is running...',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// 404 handler
//



const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

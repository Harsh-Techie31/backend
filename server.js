import express, { json } from 'express';
import { connect } from 'mongoose';
import { config } from 'dotenv';
import cors from 'cors';
import authRoutes from './routes/authRoutes.js';
import restaurantRoutes from './routes/restaurantRoutes.js';
import menuCatRoutes from './routes/menucaterogyRoute.js';

import cookieParser from 'cookie-parser';



config();

const app = express();
app.use(json());
app.use(cookieParser());
app.use(cors());


connect(process.env.MONGO_URI)
  .then(() => console.log("MongoDB connected"))
  .catch(err => console.error("MongoDB error:", err));

app.use('/api/auth', authRoutes);

app.use('/api/restaurant', restaurantRoutes);
app.use('/api/menucat', menuCatRoutes);

app.get('/', (req,res) => {
  res.send('API is running...');
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

// controllers/restaurantController.js
import Restaurant from '../models/restaurant.js';
import mongoose from 'mongoose';

export const createRestaurant = async (req, res) => {
  try {
    const { name, description, address, lat, lng, ownerId } = req.body;

    // Validate required text fields
    if (!name || !description || !address || !lat || !lng || !ownerId) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    // Validate images
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ message: 'At least one image is required' });
    }

    const imageUrls = req.files.map(file => file.path);

    const restaurant = await Restaurant.create({
      name,
      description,
      address,
      lat,
      lng,
      ownerId: new mongoose.Types.ObjectId(ownerId),
      images: imageUrls
    });

    res.status(201).json({ message: 'Restaurant created successfully', restaurant });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Error creating restaurant' });
  }
};

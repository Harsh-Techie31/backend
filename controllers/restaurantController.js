// controllers/restaurantController.js
import Restaurant from '../models/restaurant.js';
import mongoose from 'mongoose';
import User from '../models/user.js'

export const createRestaurant = async (req, res) => {
    try {
        const { name, description, address, lat, lng } = req.body;
        const ownerId = req.user.id;
        // Validate required text fields
        if (!name || !description || !address || !lat || !lng || !ownerId) {
            return res.status(400).json({ message: 'Missing required fields' });
        }

        // Validate images
        if (!req.files || req.files.length === 0) {
            return res.status(400).json({ message: 'At least one image is required' });
        }

        const owner = await User.findById(ownerId);
        if (!owner) {
            return res.status(404).json({ message: 'Owner not found' });
        }
        if (owner.role == "customer") return res.status(404).json({ message: 'Customer cannot create restaurant' });

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
        //console.error(err);
        //console.error(err); // log full error internally
        res.status(500).json({
            message: 'Error creating restaurant',
            error: err.message || 'Internal Server Error',
        });

    }
};

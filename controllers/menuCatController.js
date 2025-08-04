// controllers/restaurantController.js
import MenuCat from '../models/menuCat.js';
import mongoose from 'mongoose';


export const createMenuCategory = async (req, res) => {
    try {
        const { name, position,resId } = req.body;
        
        // Validate required text fields
        if (!name || !position || !resId ) {
            return res.status(400).json({ message: 'Missing required fields' });
        }
        
       // if (owner.role == "customer") return res.status(404).json({ message: 'Customer cannot create Menu category' });    

        const MenuCategory = await MenuCat.create({
            name,
            position,
            restaurantID: new mongoose.Types.ObjectId(resId),

        });

        res.status(201).json({ message: 'Menu Category created successfully', MenuCategory });
    } catch (err) {
        //console.error(err);
        //console.error(err); // log full error internally
        res.status(500).json({
            message: 'Error creating menu Category',
            error: err.message || 'Internal Server Error',
        });

    }
};

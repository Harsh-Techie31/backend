# Restaurant Management API

A comprehensive REST API for restaurant management system with user authentication, restaurant management, menu management, ordering system, and admin functionality.

## Features

- **User Management**: Registration, login, profile management with role-based access
- **Restaurant Management**: CRUD operations for restaurants with image uploads
- **Menu Management**: Categories and items with pricing and availability
- **Review System**: User reviews and ratings for menu items
- **Shopping Cart**: Add, update, remove items from cart
- **Order Management**: Complete order lifecycle with status tracking
- **Admin Dashboard**: User management, restaurant approval, analytics
- **Role-based Authorization**: Customer, Restaurant Owner, Admin roles

## Tech Stack

- **Backend**: Node.js, Express.js
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT with bcryptjs
- **File Upload**: Multer with Cloudinary
- **Development**: Nodemon for hot reloading

## Installation

1. Clone the repository
```bash
git clone <repository-url>
cd backend
```

2. Install dependencies
```bash
npm install
```

3. Create `.env` file
```env
PORT=5000
MONGO_URI=mongodb://localhost:27017/restaurant-management
JWT_SECRET=your-secret-key
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
NODE_ENV=development
FRONTEND_URL=http://localhost:3000
```

4. Start the server
```bash
npm run dev
```

## API Endpoints

### Authentication

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/auth/register` | Register new user | No |
| POST | `/api/auth/login` | Login user | No |
| POST | `/api/auth/logout` | Logout user | No |
| GET | `/api/auth/profile` | Get user profile | Yes |
| PUT | `/api/auth/profile` | Update user profile | Yes |

### Restaurants

| Method | Endpoint | Description | Auth Required | Role |
|--------|----------|-------------|---------------|------|
| GET | `/api/restaurant` | Get all restaurants | No | - |
| GET | `/api/restaurant/:id` | Get restaurant by ID | No | - |
| POST | `/api/restaurant/create` | Create restaurant | Yes | OWNER, ADMIN |
| PUT | `/api/restaurant/:id` | Update restaurant | Yes | OWNER, ADMIN |
| DELETE | `/api/restaurant/:id` | Delete restaurant | Yes | OWNER, ADMIN |
| PUT | `/api/restaurant/:id/approval` | Approve/reject restaurant | Yes | ADMIN |
| GET | `/api/restaurant/owner/my-restaurants` | Get owner's restaurants | Yes | OWNER |

### Menu Categories

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/menucat/restaurant/:restaurantId` | Get categories by restaurant | No |
| GET | `/api/menucat/:id` | Get category by ID | No |
| POST | `/api/menucat/create` | Create category | Yes |
| PUT | `/api/menucat/:id` | Update category | Yes |
| DELETE | `/api/menucat/:id` | Delete category | Yes |

### Menu Items

| Method | Endpoint | Description | Auth Required | Role |
|--------|----------|-------------|---------------|------|
| GET | `/api/menuitem/restaurant/:restaurantId` | Get items by restaurant | No | - |
| GET | `/api/menuitem/category/:categoryId` | Get items by category | No | - |
| GET | `/api/menuitem/:id` | Get item by ID | No | - |
| POST | `/api/menuitem/create` | Create menu item | Yes | OWNER, ADMIN |
| PUT | `/api/menuitem/:id` | Update menu item | Yes | OWNER, ADMIN |
| DELETE | `/api/menuitem/:id` | Delete menu item | Yes | OWNER, ADMIN |

### Reviews

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/review/item/:itemId` | Get reviews by item | No |
| GET | `/api/review/:id` | Get review by ID | No |
| POST | `/api/review/create` | Create review | Yes |
| PUT | `/api/review/:id` | Update review | Yes |
| DELETE | `/api/review/:id` | Delete review | Yes |
| GET | `/api/review/user/my-reviews` | Get user's reviews | Yes |

### Cart

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/cart/restaurant/:restaurantId` | Get or create cart | Yes |
| POST | `/api/cart/add` | Add item to cart | Yes |
| PUT | `/api/cart/item/:cartItemId` | Update cart item | Yes |
| DELETE | `/api/cart/item/:cartItemId` | Remove item from cart | Yes |
| DELETE | `/api/cart/:cartId/clear` | Clear cart | Yes |
| GET | `/api/cart/user/my-carts` | Get user's carts | Yes |

### Orders

| Method | Endpoint | Description | Auth Required | Role |
|--------|----------|-------------|---------------|------|
| POST | `/api/order/create` | Create order from cart | Yes | CUSTOMER |
| GET | `/api/order/user/my-orders` | Get user's orders | Yes | CUSTOMER |
| GET | `/api/order/:id` | Get order by ID | Yes | - |
| PUT | `/api/order/:id/cancel` | Cancel order | Yes | CUSTOMER |
| PUT | `/api/order/:id/status` | Update order status | Yes | OWNER, ADMIN |
| GET | `/api/order/restaurant/:restaurantId` | Get restaurant orders | Yes | OWNER, ADMIN |

### Admin

| Method | Endpoint | Description | Auth Required | Role |
|--------|----------|-------------|---------------|------|
| GET | `/api/admin/logs` | Get admin logs | Yes | ADMIN |
| GET | `/api/admin/dashboard` | Get dashboard stats | Yes | ADMIN |
| GET | `/api/admin/users` | Get all users | Yes | ADMIN |
| PUT | `/api/admin/users/:userId/role` | Update user role | Yes | ADMIN |
| DELETE | `/api/admin/users/:userId` | Delete user | Yes | ADMIN |
| GET | `/api/admin/restaurants/pending` | Get pending restaurants | Yes | ADMIN |

## Request/Response Examples

### Register User
```json
POST /api/auth/register
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "role": "CUSTOMER",
  "phone": "+1234567890"
}
```

### Create Restaurant
```json
POST /api/restaurant/create
Content-Type: multipart/form-data

{
  "name": "Pizza Palace",
  "description": "Best pizza in town",
  "address": "123 Main St",
  "lat": 40.7128,
  "lng": -74.0060,
  "images": [file1, file2]
}
```

### Create Menu Item
```json
POST /api/menuitem/create
Content-Type: multipart/form-data

{
  "name": "Margherita Pizza",
  "description": "Classic tomato and mozzarella",
  "price": 12.99,
  "categoryId": "category_id",
  "restaurantId": "restaurant_id",
  "image": file
}
```

## Environment Variables

- `PORT`: Server port (default: 5000)
- `MONGO_URI`: MongoDB connection string
- `JWT_SECRET`: Secret key for JWT tokens
- `CLOUDINARY_CLOUD_NAME`: Cloudinary cloud name
- `CLOUDINARY_API_KEY`: Cloudinary API key
- `CLOUDINARY_API_SECRET`: Cloudinary API secret
- `NODE_ENV`: Environment (development/production)
- `FRONTEND_URL`: Frontend URL for CORS

## Database Schema

The API uses MongoDB with the following collections:
- `users`: User accounts with roles
- `restaurants`: Restaurant information
- `menucategories`: Menu categories
- `menuitems`: Menu items with pricing
- `itemreviews`: User reviews and ratings
- `carts`: Shopping carts
- `cartitems`: Items in carts
- `orders`: Customer orders
- `orderitems`: Items in orders
- `adminlogs`: Admin action logs

## Error Handling

The API returns consistent error responses:
```json
{
  "message": "Error description",
  "error": "Detailed error (development only)"
}
```

## Security Features

- JWT-based authentication
- Password hashing with bcryptjs
- Role-based authorization
- Input validation
- CORS configuration
- Secure cookie settings

## Development

```bash
# Start development server
npm run dev

# Start production server
npm start
```

## License

This project is licensed under the ISC License. 
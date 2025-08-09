# Restaurant Management API

A comprehensive REST API for restaurant management system with user authentication, restaurant management, menu management, ordering system, and admin functionality.




# Restaurant Management API Documentation

## Base URL
```
http://localhost:5000/api
```

## Authentication
All requireAuthed routes require a Bearer token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

## API Endpoints

### Authentication Routes (`/auth`)

#### Register User
- **POST** `/auth/register`
- **Body:**
  ```json
  {
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "role": "CUSTOMER" // CUSTOMER, OWNER, ADMIN
  }
  ```
- **Response:**
  ```json
  {
    "message": "User registered",
    "user": {
      "id": "user_id",
      "name": "John Doe",
      "email": "john@example.com",
      "role": "CUSTOMER"
    },
    "token": "jwt_token_here"
  }
  ```

#### Login User
- **POST** `/auth/login`
- **Body:**
  ```json
  {
    "email": "john@example.com",
    "password": "password123"
  }
  ```
- **Response:**
  ```json
  {
    "message": "Login successful",
    "user": {
      "id": "user_id",
      "name": "John Doe",
      "email": "john@example.com",
      "role": "CUSTOMER"
    },
    "token": "jwt_token_here"
  }
  ```

#### Logout User
- **POST** `/auth/logout`
- **Headers:** `Authorization: Bearer <token>`
- **Response:**
  ```json
  {
    "message": "Logged out successfully"
  }
  ```

#### Get User Profile
- **GET** `/auth/profile`
- **Headers:** `Authorization: Bearer <token>`
- **Response:**
  ```json
  {
    "user": {
      "id": "user_id",
      "name": "John Doe",
      "email": "john@example.com",
      "role": "CUSTOMER",
      "phone": "1234567890"
    }
  }
  ```

#### Update User Profile
- **PUT** `/auth/profile`
- **Headers:** `Authorization: Bearer <token>`
- **Body:**
  ```json
  {
    "name": "John Updated",
    "email": "john.updated@example.com",
    "phone": "0987654321"
  }
  ```
- **Response:**
  ```json
  {
    "message": "Profile updated successfully",
    "user": {
      "id": "user_id",
      "name": "John Updated",
      "email": "john.updated@example.com",
      "role": "CUSTOMER",
      "phone": "0987654321"
    }
  }
  ```

### Restaurant Routes (`/restaurant`)

#### Get All Restaurants
- **GET** `/restaurant`
- **Query Parameters:**
  - `page` (default: 1)
  - `limit` (default: 10)
  - `search` (optional)
  - `isApproved` (optional: true/false)
  - `minRating` (optional)
- **Response:**
  ```json
  {
    "restaurants": [...],
    "totalPages": 5,
    "currentPage": 1,
    "total": 50
  }
  ```

#### Get Restaurant by ID
- **GET** `/restaurant/:id`
- **Response:**
  ```json
  {
    "restaurant": {
      "id": "restaurant_id",
      "name": "Restaurant Name",
      "description": "Description",
      "address": "Address",
      "lat": 40.7128,
      "lng": -74.0060,
      "averageRating": 4.5,
      "isApproved": true,
      "images": ["image_url1", "image_url2"],
      "ownerId": {
        "id": "owner_id",
        "name": "Owner Name",
        "email": "owner@example.com",
        "phone": "1234567890"
      }
    }
  }
  ```

#### Create Restaurant
- **POST** `/restaurant/create`
- **Headers:** `Authorization: Bearer <token>` (OWNER/ADMIN only)
- **Body:** `multipart/form-data`
  - `name`: Restaurant name
  - `description`: Restaurant description
  - `address`: Restaurant address
  - `lat`: Latitude
  - `lng`: Longitude
  - `images`: Array of image files
- **Response:**
  ```json
  {
    "message": "Restaurant created successfully",
    "restaurant": {...}
  }
  ```

#### Update Restaurant
- **PUT** `/restaurant/:id`
- **Headers:** `Authorization: Bearer <token>` (Owner/Admin only)
- **Body:** `multipart/form-data`
  - `name`: Restaurant name (optional)
  - `description`: Restaurant description (optional)
  - `address`: Restaurant address (optional)
  - `lat`: Latitude (optional)
  - `lng`: Longitude (optional)
  - `images`: Array of image files (optional)
- **Response:**
  ```json
  {
    "message": "Restaurant updated successfully",
    "restaurant": {...}
  }
  ```

#### Delete Restaurant
- **DELETE** `/restaurant/:id`
- **Headers:** `Authorization: Bearer <token>` (Owner/Admin only)
- **Response:**
  ```json
  {
    "message": "Restaurant deleted successfully"
  }
  ```

#### Approve/Reject Restaurant
- **PUT** `/restaurant/:id/approval`
- **Headers:** `Authorization: Bearer <token>` (ADMIN only)
- **Body:**
  ```json
  {
    "isApproved": true
  }
  ```
- **Response:**
  ```json
  {
    "message": "Restaurant approved successfully",
    "restaurant": {...}
  }
  ```

#### Get Owner's Restaurants
- **GET** `/restaurant/owner/my-restaurants`
- **Headers:** `Authorization: Bearer <token>` (OWNER only)
- **Response:**
  ```json
  {
    "restaurants": [...]
  }
  ```

### Menu Category Routes (`/menucat`)

#### Get Restaurant Categories
- **GET** `/menucat/restaurant/:restaurantId`
- **Response:**
  ```json
  {
    "menuCategories": [...]
  }
  ```

#### Get Category by ID
- **GET** `/menucat/:id`
- **Response:**
  ```json
  {
    "menuCategory": {...}
  }
  ```

#### Create Menu Category
- **POST** `/menucat/create`
- **Headers:** `Authorization: Bearer <token>` (Owner/Admin only)
- **Body:**
  ```json
  {
    "name": "Appetizers",
    "position": 1,
    "restaurantId": "restaurant_id"
  }
  ```
- **Response:**
  ```json
  {
    "message": "Menu category created successfully",
    "menuCategory": {...}
  }
  ```

#### Update Menu Category
- **PUT** `/menucat/:id`
- **Headers:** `Authorization: Bearer <token>` (Owner/Admin only)
- **Body:**
  ```json
  {
    "name": "Updated Name",
    "position": 2
  }
  ```
- **Response:**
  ```json
  {
    "message": "Menu category updated successfully",
    "menuCategory": {...}
  }
  ```

#### Delete Menu Category
- **DELETE** `/menucat/:id`
- **Headers:** `Authorization: Bearer <token>` (Owner/Admin only)
- **Response:**
  ```json
  {
    "message": "Menu category deleted successfully"
  }
  ```

### Menu Item Routes (`/menuitem`)

#### Get Restaurant Menu Items
- **GET** `/menuitem/restaurant/:restaurantId`
- **Query Parameters:**
  - `categoryId` (optional)
  - `isAvailable` (optional: true/false)
- **Response:**
  ```json
  {
    "menuItems": [...]
  }
  ```

#### Get Menu Items by Category
- **GET** `/menuitem/category/:categoryId`
- **Query Parameters:**
  - `isAvailable` (optional: true/false)
- **Response:**
  ```json
  {
    "menuItems": [...]
  }
  ```

#### Get Menu Item by ID
- **GET** `/menuitem/:id`
- **Response:**
  ```json
  {
    "menuItem": {...}
  }
  ```

#### Create Menu Item
- **POST** `/menuitem/create`
- **Headers:** `Authorization: Bearer <token>` (Owner/Admin only)
- **Body:** `multipart/form-data`
  - `name`: Item name
  - `description`: Item description
  - `price`: Item price
  - `categoryId`: Category ID
  - `restaurantId`: Restaurant ID
  - `image`: Image file (optional)
- **Response:**
  ```json
  {
    "message": "Menu item created successfully",
    "menuItem": {...}
  }
  ```

#### Update Menu Item
- **PUT** `/menuitem/:id`
- **Headers:** `Authorization: Bearer <token>` (Owner/Admin only)
- **Body:** `multipart/form-data`
  - `name`: Item name (optional)
  - `description`: Item description (optional)
  - `price`: Item price (optional)
  - `categoryId`: Category ID (optional)
  - `isAvailable`: Boolean (optional)
  - `image`: Image file (optional)
- **Response:**
  ```json
  {
    "message": "Menu item updated successfully",
    "menuItem": {...}
  }
  ```

#### Delete Menu Item
- **DELETE** `/menuitem/:id`
- **Headers:** `Authorization: Bearer <token>` (Owner/Admin only)
- **Response:**
  ```json
  {
    "message": "Menu item deleted successfully"
  }
  ```

### Item Review Routes (`/review`)

#### Get Item Reviews
- **GET** `/review/item/:itemId`
- **Query Parameters:**
  - `page` (default: 1)
  - `limit` (default: 10)
- **Response:**
  ```json
  {
    "reviews": [...],
    "totalPages": 5,
    "currentPage": 1,
    "total": 50
  }
  ```

#### Get Review by ID
- **GET** `/review/:id`
- **Response:**
  ```json
  {
    "review": {...}
  }
  ```

#### Create Item Review
- **POST** `/review/create`
- **Headers:** `Authorization: Bearer <token>`
- **Body:**
  ```json
  {
    "itemId": "menu_item_id",
    "rating": 5,
    "comment": "Great food!"
  }
  ```
- **Response:**
  ```json
  {
    "message": "Review created successfully",
    "review": {...}
  }
  ```

#### Update Review
- **PUT** `/review/:id`
- **Headers:** `Authorization: Bearer <token>`
- **Body:**
  ```json
  {
    "rating": 4,
    "comment": "Updated comment"
  }
  ```
- **Response:**
  ```json
  {
    "message": "Review updated successfully",
    "review": {...}
  }
  ```

#### Delete Review
- **DELETE** `/review/:id`
- **Headers:** `Authorization: Bearer <token>`
- **Response:**
  ```json
  {
    "message": "Review deleted successfully"
  }
  ```

#### Get User Reviews
- **GET** `/review/user/my-reviews`
- **Headers:** `Authorization: Bearer <token>`
- **Query Parameters:**
  - `page` (default: 1)
  - `limit` (default: 10)
- **Response:**
  ```json
  {
    "reviews": [...],
    "totalPages": 5,
    "currentPage": 1,
    "total": 50
  }
  ```

### Restaurant Review Routes (`/restaurant-reviews`)

#### Get Restaurant Reviews
- **GET** `/restaurant-reviews/restaurant/:restaurantId`
- **Query Parameters:**
  - `page` (default: 1)
  - `limit` (default: 10)
  - `rating` (optional: filter by rating)
- **Response:**
  ```json
  {
    "reviews": [...],
    "totalPages": 5,
    "currentPage": 1,
    "total": 50
  }
  ```

#### Get Restaurant Review by ID
- **GET** `/restaurant-reviews/:id`
- **Response:**
  ```json
  {
    "review": {...}
  }
  ```

#### Create Restaurant Review
- **POST** `/restaurant-reviews/create`
- **Headers:** `Authorization: Bearer <token>`
- **Body:** `multipart/form-data`
  - `restaurantId`: Restaurant ID
  - `rating`: Rating (1-5)
  - `comment`: Review comment (optional)
  - `images`: Array of image files (optional)
- **Response:**
  ```json
  {
    "message": "Review created successfully",
    "review": {...}
  }
  ```

#### Update Restaurant Review
- **PUT** `/restaurant-reviews/:id`
- **Headers:** `Authorization: Bearer <token>`
- **Body:** `multipart/form-data`
  - `rating`: Rating (1-5) (optional)
  - `comment`: Review comment (optional)
  - `images`: Array of image files (optional)
- **Response:**
  ```json
  {
    "message": "Review updated successfully",
    "review": {...}
  }
  ```

#### Delete Restaurant Review
- **DELETE** `/restaurant-reviews/:id`
- **Headers:** `Authorization: Bearer <token>`
- **Response:**
  ```json
  {
    "message": "Review deleted successfully"
  }
  ```

#### Get User's Restaurant Reviews
- **GET** `/restaurant-reviews/user/my-reviews`
- **Headers:** `Authorization: Bearer <token>`
- **Query Parameters:**
  - `page` (default: 1)
  - `limit` (default: 10)
- **Response:**
  ```json
  {
    "reviews": [...],
    "totalPages": 5,
    "currentPage": 1,
    "total": 50
  }
  ```

### Cart Routes (`/cart`)

#### Get or Create Cart
- **GET** `/cart/restaurant/:restaurantId`
- **Headers:** `Authorization: Bearer <token>`
- **Response:**
  ```json
  {
    "cart": {...},
    "cartItems": [...]
  }
  ```

#### Add Item to Cart
- **POST** `/cart/add`
- **Headers:** `Authorization: Bearer <token>`
- **Body:**
  ```json
  {
    "restaurantId": "restaurant_id",
    "menuItemId": "menu_item_id",
    "quantity": 2
  }
  ```
- **Response:**
  ```json
  {
    "message": "Item added to cart successfully",
    "cart": {...},
    "cartItems": [...]
  }
  ```

#### Update Cart Item
- **PUT** `/cart/item/:cartItemId`
- **Headers:** `Authorization: Bearer <token>`
- **Body:**
  ```json
  {
    "quantity": 3
  }
  ```
- **Response:**
  ```json
  {
    "message": "Cart item updated successfully",
    "cartItem": {...}
  }
  ```

#### Remove Item from Cart
- **DELETE** `/cart/item/:cartItemId`
- **Headers:** `Authorization: Bearer <token>`
- **Response:**
  ```json
  {
    "message": "Item removed from cart successfully"
  }
  ```

#### Clear Cart
- **DELETE** `/cart/:cartId/clear`
- **Headers:** `Authorization: Bearer <token>`
- **Response:**
  ```json
  {
    "message": "Cart cleared successfully"
  }
  ```

#### Get User's Carts
- **GET** `/cart/user/my-carts`
- **Headers:** `Authorization: Bearer <token>`
- **Response:**
  ```json
  {
    "carts": [...]
  }
  ```

### Order Routes (`/order`)

#### Create Order
- **POST** `/order/create`
- **Headers:** `Authorization: Bearer <token>`
- **Body:**
  ```json
  {
    "cartId": "cart_id"
  }
  ```
- **Response:**
  ```json
  {
    "message": "Order created successfully",
    "order": {...},
    "orderItems": [...]
  }
  ```

#### Get User Orders
- **GET** `/order/user/my-orders`
- **Headers:** `Authorization: Bearer <token>`
- **Query Parameters:**
  - `page` (default: 1)
  - `limit` (default: 10)
  - `status` (optional: PLACED, PREPARING, DELIVERED, CANCELLED)
- **Response:**
  ```json
  {
    "orders": [...],
    "totalPages": 5,
    "currentPage": 1,
    "total": 50
  }
  ```

#### Get Order by ID
- **GET** `/order/:id`
- **Headers:** `Authorization: Bearer <token>`
- **Response:**
  ```json
  {
    "order": {...},
    "orderItems": [...]
  }
  ```

#### Update Order Status
- **PUT** `/order/:id/status`
- **Headers:** `Authorization: Bearer <token>` (Owner/Admin only)
- **Body:**
  ```json
  {
    "status": "PREPARING"
  }
  ```
- **Response:**
  ```json
  {
    "message": "Order status updated successfully",
    "order": {...}
  }
  ```

#### Get Restaurant Orders
- **GET** `/order/restaurant/:restaurantId`
- **Headers:** `Authorization: Bearer <token>` (Owner/Admin only)
- **Query Parameters:**
  - `page` (default: 1)
  - `limit` (default: 10)
  - `status` (optional)
- **Response:**
  ```json
  {
    "orders": [...],
    "totalPages": 5,
    "currentPage": 1,
    "total": 50
  }
  ```

#### Cancel Order
- **PUT** `/order/:id/cancel`
- **Headers:** `Authorization: Bearer <token>`
- **Response:**
  ```json
  {
    "message": "Order cancelled successfully",
    "order": {...}
  }
  ```

### Admin Routes (`/admin`)

#### Get Admin Logs
- **GET** `/admin/logs`
- **Headers:** `Authorization: Bearer <token>` (ADMIN only)
- **Query Parameters:**
  - `page` (default: 1)
  - `limit` (default: 20)
  - `action` (optional)
  - `targetType` (optional)
- **Response:**
  ```json
  {
    "logs": [...],
    "totalPages": 5,
    "currentPage": 1,
    "total": 100
  }
  ```

#### Get Dashboard Stats
- **GET** `/admin/dashboard`
- **Headers:** `Authorization: Bearer <token>` (ADMIN only)
- **Response:**
  ```json
  {
    "stats": {
      "totalUsers": 150,
      "totalRestaurants": 25,
      "totalOrders": 500,
      "pendingRestaurants": 5
    },
    "recentOrders": [...]
  }
  ```

#### Get All Users
- **GET** `/admin/users`
- **Headers:** `Authorization: Bearer <token>` (ADMIN only)
- **Query Parameters:**
  - `page` (default: 1)
  - `limit` (default: 20)
  - `role` (optional)
  - `search` (optional)
- **Response:**
  ```json
  {
    "users": [...],
    "totalPages": 5,
    "currentPage": 1,
    "total": 100
  }
  ```

#### Update User Role
- **PUT** `/admin/users/:userId/role`
- **Headers:** `Authorization: Bearer <token>` (ADMIN only)
- **Body:**
  ```json
  {
    "role": "OWNER"
  }
  ```
- **Response:**
  ```json
  {
    "message": "User role updated successfully",
    "user": {...}
  }
  ```

#### Delete User
- **DELETE** `/admin/users/:userId`
- **Headers:** `Authorization: Bearer <token>` (ADMIN only)
- **Response:**
  ```json
  {
    "message": "User deleted successfully"
  }
  ```

#### Get Pending Restaurants
- **GET** `/admin/restaurants/pending`
- **Headers:** `Authorization: Bearer <token>` (ADMIN only)
- **Query Parameters:**
  - `page` (default: 1)
  - `limit` (default: 20)
- **Response:**
  ```json
  {
    "restaurants": [...],
    "totalPages": 5,
    "currentPage": 1,
    "total": 25
  }
  ```

## Error Responses

All endpoints may return the following error responses:

### 400 Bad Request
```json
{
  "message": "Error description"
}
```

### 401 Unauthorized
```json
{
  "message": "Not authorized, token missing"
}
```
or
```json
{
  "message": "Not authorized, token invalid"
}
```

### 403 Forbidden
```json
{
  "message": "User role CUSTOMER is not authorized to access this route"
}
```

### 404 Not Found
```json
{
  "message": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "message": "Internal server error"
}
```

## User Roles

- **CUSTOMER**: Can browse restaurants, place orders, write reviews
- **OWNER**: Can manage their restaurants, menu items, and orders
- **ADMIN**: Can manage all users, restaurants, and view system statistics

## File Upload

For endpoints that accept file uploads, use `multipart/form-data` format and include the files in the request body.

## Pagination

Most list endpoints support pagination with `page` and `limit` query parameters. The response includes:
- `totalPages`: Total number of pages
- `currentPage`: Current page number
- `total`: Total number of items 

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
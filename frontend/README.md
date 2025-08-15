# Restaurant Manager - Flutter Frontend

A modern Flutter application built with MVVM (Model-View-ViewModel) architecture for restaurant management.

## 🏗️ Architecture Overview

This project follows the **MVVM (Model-View-ViewModel)** pattern with clean separation of concerns:

### 📁 Project Structure

```
lib/
├── core/
│   └── constants/
│       ├── app_colors.dart      # Color scheme constants
│       ├── app_constants.dart   # App-wide constants
│       └── app_text_styles.dart # Typography styles
├── models/
│   ├── user_model.dart          # User data model
│   └── auth_response_model.dart # Authentication response model
├── services/
│   ├── api_service.dart         # HTTP API communication
│   └── storage_service.dart     # Local data persistence
├── viewmodels/
│   └── auth_viewmodel.dart      # Authentication business logic
├── views/
│   ├── auth/
│   │   ├── login_screen.dart    # Login UI
│   │   └── register_screen.dart # Registration UI
│   ├── owner/
│   │   └── owner_dashboard_screen.dart # Restaurant owner dashboard
│   ├── customer/
│   │   └── customer_dashboard_screen.dart # Customer dashboard
│   └── admin/
│       └── admin_dashboard_screen.dart # Admin dashboard
├── widgets/
│   ├── custom_button.dart       # Reusable button component
│   ├── custom_text_field.dart   # Reusable text field component
│   └── custom_snackbar.dart     # Toast notification component
└── main.dart                    # App entry point
```

## 🎯 Features Implemented

### ✅ Authentication System
- **User Registration**: Complete registration flow with role selection
- **User Login**: Secure login with email/password
- **Role-based Access**: Three user roles (Customer, Owner, Admin)
- **Session Management**: Automatic login state persistence
- **Form Validation**: Comprehensive input validation

### ✅ UI/UX Features
- **Modern Design**: Clean, professional interface
- **Responsive Layout**: Works on various screen sizes
- **Custom Components**: Reusable UI components
- **Loading States**: Proper loading indicators
- **Error Handling**: User-friendly error messages
- **Success Feedback**: Toast notifications for actions

### ✅ Technical Features
- **MVVM Architecture**: Clean separation of concerns
- **State Management**: Provider pattern for state management
- **API Integration**: HTTP service for backend communication
- **Local Storage**: SharedPreferences for data persistence
- **Navigation**: Proper routing and navigation flow

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Backend server running (see backend README)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure backend URL**
   - Update `lib/core/constants/app_constants.dart`
   - Change `baseUrl` to your backend server URL

4. **Run the application**
   ```bash
   flutter run
   ```

## 🎨 Design System

### Color Palette
- **Primary**: Blue (#1E3A8A)
- **Secondary**: Orange (#F59E0B)
- **Success**: Green (#10B981)
- **Error**: Red (#EF4444)
- **Background**: Light Gray (#F8FAFC)

### Typography
- **Headings**: Poppins font family
- **Body Text**: Inter font family
- **Consistent sizing**: 12px to 32px scale

## 🔧 Architecture Components

### Models (M in MVVM)
- **UserModel**: Represents user data structure
- **AuthResponseModel**: Handles authentication responses
- Clean data models with JSON serialization

### Views (V in MVVM)
- **LoginScreen**: User authentication interface
- **RegisterScreen**: User registration with role selection
- **Dashboard Screens**: Role-specific dashboards
- **Custom Widgets**: Reusable UI components

### ViewModels (VM in MVVM)
- **AuthViewModel**: Manages authentication state and business logic
- Handles API calls, data persistence, and UI state
- Provides clean interface for Views

### Services
- **ApiService**: HTTP communication with backend
- **StorageService**: Local data persistence
- Singleton pattern for service management

## 🔐 User Roles

### 1. Restaurant Owner (OWNER)
- **Features**: Manage restaurants, menus, orders
- **Dashboard**: Restaurant management interface
- **Permissions**: Full restaurant management access

### 2. Customer (CUSTOMER)
- **Features**: Browse restaurants, place orders
- **Dashboard**: Customer interface (coming soon)
- **Permissions**: Order and review access

### 3. Admin (ADMIN)
- **Features**: System administration
- **Dashboard**: Admin panel (coming soon)
- **Permissions**: Full system access

## 📱 Screens

### Authentication Screens
1. **Login Screen**
   - Email/password authentication
   - Form validation
   - Role information display

2. **Register Screen**
   - Complete registration form
   - Role selection interface
   - Password confirmation

### Dashboard Screens
1. **Owner Dashboard**
   - Welcome section with user info
   - Quick action cards
   - Account information display

2. **Customer Dashboard** (Placeholder)
   - Basic welcome screen
   - Coming soon message

3. **Admin Dashboard** (Placeholder)
   - Basic welcome screen
   - Coming soon message

## 🛠️ Custom Widgets

### CustomTextField
- Consistent styling across the app
- Built-in validation support
- Configurable input types
- Error state handling

### CustomButton
- Loading state support
- Multiple style variants
- Consistent theming
- Disabled state handling

### CustomSnackBar
- Success, error, info, warning variants
- Consistent styling
- Auto-dismiss functionality
- Action button support

## 🔄 State Management

### Provider Pattern
- **AuthViewModel**: Central authentication state
- **ChangeNotifier**: Reactive state updates
- **Consumer Widgets**: UI state binding

### State Flow
1. **User Action** → View
2. **View** → ViewModel method call
3. **ViewModel** → Service layer
4. **Service** → API/Storage
5. **Response** → ViewModel state update
6. **State Change** → UI update

## 🚦 Navigation Flow

```
Splash Screen
    ↓
Auth Check
    ↓
┌─────────────────┐
│   Login Screen  │
└─────────────────┘
    ↓
┌─────────────────┐
│ Register Screen │
└─────────────────┘
    ↓
Role-based Navigation
    ↓
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ Owner Dashboard │  │Customer Dashboard│  │ Admin Dashboard │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

## 📦 Dependencies

### Core Dependencies
- **provider**: State management
- **http**: API communication
- **shared_preferences**: Local storage
- **google_fonts**: Typography

### Development Dependencies
- **flutter_lints**: Code quality
- **flutter_test**: Testing framework

## 🔧 Configuration

### Environment Variables
Update `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'http://your-backend-url:5000/api';
```

### Backend Integration
- Ensure backend server is running
- Verify API endpoints match backend documentation
- Test authentication flow

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 📈 Future Enhancements

### Planned Features
- [ ] Restaurant management screens
- [ ] Menu management interface
- [ ] Order management system
- [ ] Customer ordering flow
- [ ] Admin panel features
- [ ] Push notifications
- [ ] Offline support
- [ ] Image upload functionality

### Technical Improvements
- [ ] Unit test coverage
- [ ] Integration tests
- [ ] Performance optimization
- [ ] Accessibility improvements
- [ ] Internationalization

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Follow MVVM architecture patterns
4. Add tests for new features
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions:
- Check the backend documentation
- Review the API documentation
- Open an issue on GitHub

---

**Built with ❤️ using Flutter and MVVM Architecture**

# MintMate Project Structure

## Frontend (`lib/frontend/`)
Contains all UI-related code and components.

### Screens (`frontend/screens/`)
- `splash_screen.dart` - Initial loading screen
- `login_screen.dart` - User authentication screen
- `expense_tracking_screen.dart` - Main expense tracking interface
- `wallet_screen.dart` - Wallet management screen
- `transaction_history_screen.dart` - Transaction history view
- `donation_screen.dart` - Donation features screen

### Widgets (`frontend/widgets/`)
Reusable UI components:
- `expense_card.dart` - Card widget for displaying expenses
- `category_selector.dart` - Widget for selecting expense categories
- `analytics_chart.dart` - Chart widget for expense analytics

### Theme (`frontend/theme/`)
UI styling and theming:
- `app_theme.dart` - App-wide theme configuration
- `colors.dart` - Color constants
- `text_styles.dart` - Typography styles

## Backend (`lib/backend/`)
Contains all business logic, data management, and external service integrations.

### Services (`backend/services/`)
- `firebase_service.dart` - Firebase authentication and database
- `ai_service.dart` - AI/ML functionality for expense categorization
- `storage_service.dart` - Local storage management

### Models (`backend/models/`)
Data models:
- `expense.dart` - Expense data structure
- `user.dart` - User data structure
- `category.dart` - Expense category structure

### Repositories (`backend/repositories/`)
Data access layer:
- `expense_repository.dart` - Expense data operations
- `user_repository.dart` - User data operations
- `category_repository.dart` - Category data operations

## Platform-specific Folders
- `android/` - Android platform configuration
- `ios/` - iOS platform configuration
- `web/` - Web platform configuration
- `windows/` - Windows platform configuration
- `linux/` - Linux platform configuration
- `macos/` - macOS platform configuration

## Configuration Files
- `pubspec.yaml` - Dependencies and project configuration
- `analysis_options.yaml` - Dart analysis rules
- `.gitignore` - Git ignore rules
- `LICENSE` - MIT License

## Testing
- `test/` - Unit and widget tests
  - `widget_test.dart` - Widget tests
  - `unit_test/` - Unit tests for backend logic
  - `integration_test/` - Integration tests 
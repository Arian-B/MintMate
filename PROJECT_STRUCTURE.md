# MintMate - AI-Powered Student Finance App

## Project Structure

### Frontend (`lib/frontend/`)
- **screens/**
  - `dashboard_screen.dart` - Main dashboard with modular tools
  - `expense_calculator_screen.dart` - Expense tracking and analysis
  - `funds_manager_screen.dart` - Money management and transfers
  - `bill_tracker_screen.dart` - Subscription and bill management
  - `loan_simulator_screen.dart` - EMI calculator and loan planning
  - `currency_converter_screen.dart` - Real-time currency conversion
  - `budget_builder_screen.dart` - Budget creation and tracking
  - `bill_splitter_screen.dart` - Group expense management
  - `investment_screen.dart` - Micro-investment automation
  - `expense_heatmap_screen.dart` - Visual spending analysis
  - `goals_screen.dart` - Financial goal setting and tracking
  - `receipt_scanner_screen.dart` - OCR receipt processing
  - `contract_analyzer_screen.dart` - Document analysis
  - `knowledge_hub_screen.dart` - AI-powered financial education
  - `tax_helper_screen.dart` - Student tax guidance
  - `health_report_screen.dart` - Financial health dashboard

- **widgets/**
  - `common/` - Reusable UI components
  - `charts/` - Data visualization components
  - `forms/` - Input and validation components
  - `cards/` - Card-based UI components
  - `modals/` - Dialog and modal components

- **theme/**
  - `app_theme.dart` - App-wide theme configuration
  - `colors.dart` - Color constants
  - `text_styles.dart` - Typography styles
  - `animations.dart` - Animation configurations

### Backend (`lib/backend/`)
- **services/**
  - `ai_service.dart` - AI/ML functionality
  - `auth_service.dart` - Authentication and security
  - `storage_service.dart` - Local data persistence
  - `api_service.dart` - External API integrations
  - `payment_service.dart` - Payment processing
  - `notification_service.dart` - Push notifications
  - `analytics_service.dart` - Usage analytics

- **models/**
  - `user.dart` - User data model
  - `transaction.dart` - Transaction data model
  - `budget.dart` - Budget data model
  - `goal.dart` - Financial goal model
  - `bill.dart` - Bill/subscription model
  - `investment.dart` - Investment data model
  - `receipt.dart` - Receipt data model
  - `contract.dart` - Contract data model

- **repositories/**
  - `user_repository.dart` - User data operations
  - `transaction_repository.dart` - Transaction operations
  - `budget_repository.dart` - Budget operations
  - `goal_repository.dart` - Goal operations
  - `bill_repository.dart` - Bill operations
  - `investment_repository.dart` - Investment operations

### AI Module (`lib/ai/`)
- **predictions/**
  - `spending_predictor.dart` - Spending pattern analysis
  - `savings_predictor.dart` - Savings projections
  - `investment_predictor.dart` - Investment recommendations

- **nlp/**
  - `query_processor.dart` - Natural language query handling
  - `document_analyzer.dart` - Document processing
  - `chat_processor.dart` - AI chat functionality

- **recommendations/**
  - `insight_engine.dart` - Personalized insights
  - `tip_generator.dart` - Financial tips
  - `goal_recommender.dart` - Goal suggestions

### Utils (`lib/utils/`)
- `constants.dart` - App-wide constants
- `validators.dart` - Input validation
- `formatters.dart` - Data formatting
- `extensions.dart` - Dart extensions
- `helpers.dart` - Helper functions

### Config (`lib/config/`)
- `app_config.dart` - App configuration
- `api_config.dart` - API endpoints
- `theme_config.dart` - Theme settings
- `ai_config.dart` - AI model settings

## Phase 1 Implementation Priority
1. Core Dashboard
2. Expense Calculator
3. Funds Manager
4. Bill Tracker
5. Budget Builder
6. Receipt Scanner
7. Basic AI Integration
8. User Authentication
9. Data Storage
10. Basic Analytics

## Phase 2 Features
1. Advanced AI Features
2. Investment Tools
3. Tax Helper
4. Contract Analyzer
5. Advanced Analytics
6. Social Features
7. Gamification
8. Advanced Security
9. API Integrations
10. Performance Optimization

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
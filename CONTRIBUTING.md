# Contributing to MintMate

Thank you for your interest in contributing to MintMate! This document provides guidelines and instructions for contributing to our project.

## 🤝 Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone. We expect all contributors to:

- Be respectful and considerate of others
- Accept constructive criticism gracefully
- Focus on what's best for the community
- Show empathy towards other community members

## 🚀 How to Contribute

### 1. Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
```bash
git clone https://github.com/your-username/mintmate.git
cd mintmate
```

### 2. Set Up Development Environment

1. Install Flutter SDK (latest version)
2. Install Dart SDK (latest version)
3. Set up your preferred IDE (Android Studio/VS Code)
4. Install dependencies:
```bash
flutter pub get
```

### 3. Branching Strategy

- `main` - Production-ready code
- `develop` - Development branch
- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Urgent production fixes

Create a new branch for your work:
```bash
git checkout -b feature/your-feature-name
```

### 4. Development Guidelines

#### Code Style
- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Write clear comments for complex logic
- Keep functions small and focused

#### Testing
- Write unit tests for new features
- Ensure all tests pass before submitting
- Maintain or improve test coverage

#### Documentation
- Update README.md if needed
- Document new features
- Add comments for complex code

### 5. Submitting Changes

1. Ensure your code is up to date:
```bash
git pull origin develop
```

2. Run tests:
```bash
flutter test
```

3. Commit your changes:
```bash
git commit -m "Description of changes"
```

4. Push to your fork:
```bash
git push origin feature/your-feature-name
```

5. Create a Pull Request:
   - Use the PR template
   - Link related issues
   - Request review from maintainers

### 6. Pull Request Process

1. Update documentation
2. Add tests if needed
3. Ensure CI passes
4. Address review comments
5. Get approval from maintainers

## 🎯 Project Structure

```
mintmate/
├── lib/
│   ├── core/         # Core functionality
│   ├── features/     # Feature modules
│   ├── shared/       # Shared components
│   └── main.dart     # Entry point
├── test/            # Test files
├── assets/          # Images, fonts, etc.
└── pubspec.yaml     # Dependencies
```

## 🐛 Bug Reports

When filing a bug report, please include:
- Clear description of the issue
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots if applicable
- Device/OS information

## 💡 Feature Requests

We welcome feature requests! Please include:
- Clear description of the feature
- Use cases
- Potential implementation approach
- Any relevant examples

## 📝 Commit Messages

Follow these guidelines:
- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and pull requests

## 🔧 Development Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

3. Run tests:
```bash
flutter test
```

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Firebase Documentation](https://firebase.google.com/docs)
- [OpenAI API Documentation](https://platform.openai.com/docs)

## 🙏 Acknowledgments

Thank you for contributing to MintMate! Your help makes this project better for students worldwide.

---

For any questions, reach out to us at arian.zg2003@gmail.com 
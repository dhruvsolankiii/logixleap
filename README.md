# LogixLeap 🚀

**Learn investing the smart way—risk-free with virtual money!**

LogixLeap is an innovative investment learning application designed to help users understand investment fundamentals without risking real capital. Users receive virtual money to practice investing in admin-curated investment plans and witness real-time growth, building confidence and knowledge in financial markets.

---

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Usage](#usage)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

---

## ✨ Features

- 💰 **Virtual Investment Portfolio**: Start with virtual money and build an investment portfolio without real financial risk
- 📊 **Real-time Growth Tracking**: Monitor your investments and watch them grow in real-time
- 📈 **Admin-Curated Investment Plans**: Access carefully selected investment opportunities curated by administrators
- 🎓 **Investment Education**: Learn investment principles through hands-on experience
- 🔐 **Secure User Accounts**: User authentication and data persistence using secure preferences
- 📱 **Mobile-First Design**: Optimized cross-platform experience for iOS and Android
- ⚡ **Smooth Performance**: Skeleton loading screens for better perceived performance
- 🌍 **Multi-language Support**: Internationalization (i18n) support with Intl package

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter (Dart)
- **UI Components**: Material Design
- **State Management**: Built-in Flutter State Management
- **Icons**: Cupertino Icons
- **Localization**: Intl (i18n support)

### Backend/Networking
- **HTTP Client**: http (^1.2.1) for REST API communication
- **Data Persistence**: shared_preferences (^2.2.3) for local storage

### Development Tools
- **Linting**: flutter_lints (^5.0.0)
- **App Icons**: flutter_launcher_icons (^0.14.3)
- **Skeleton Loading**: skeletonizer (^2.1.3)

### Platform Support
- **Languages**: Dart (42.4%), HTML (42.1%), C++ (8%), CMake (6.4%), Swift (0.6%), C (0.5%)
- **Platforms**: iOS, Android, Web
- **Minimum SDK**: Android 21+

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed:
- **Flutter SDK**: ^3.9.2
- **Dart SDK**: Latest stable version
- **Git**: For version control

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/dhruvsolanki404/logixleap.git
   cd logixleap
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

   For specific platforms:
   ```bash
   # iOS
   flutter run -d ios
   
   # Android
   flutter run -d android
   
   # Web
   flutter run -d web
   ```

---

## 📁 Project Structure

```
logixleap/
├── assets/
│   └── icon/                      # App icons
├── lib/
│   ├── main.dart                  # Entry point
│   ├── models/                    # Data models
│   ├── screens/                   # UI screens
│   ├── widgets/                   # Reusable widgets
│   ├── services/                  # API and data services
│   └── constants/                 # Constants and theme
├── test/                          # Unit and widget tests
├── pubspec.yaml                   # Project dependencies
├── analysis_options.yaml          # Lint rules
└── README.md                       # This file
```

---

## 💡 Usage

### For Users
1. **Sign Up/Log In**: Create your account to get started
2. **Receive Virtual Funds**: Get your initial virtual investment capital
3. **Browse Investment Plans**: Explore admin-curated investment opportunities
4. **Make Investments**: Invest your virtual money in selected plans
5. **Track Growth**: Monitor your portfolio and watch investments grow
6. **Learn**: Gain real-world investment knowledge risk-free

### For Administrators
1. **Add Investment Plans**: Create and manage investment opportunities
2. **Monitor User Activity**: Track user investments and portfolio performance
3. **Manage Virtual Funds**: Control the virtual currency ecosystem

---

## 🔧 Development

### Build APK/IPA

```bash
# Build Android APK
flutter build apk

# Build iOS IPA
flutter build ios

# Build Web
flutter build web
```

### Run Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Code Quality

The project uses `flutter_lints` to maintain code quality. Run:

```bash
# Analyze code
flutter analyze

# Format code
dart format lib/
```

### Dependencies Management

To check for outdated packages:

```bash
flutter pub outdated
```

To upgrade dependencies:

```bash
flutter pub upgrade
```

---

## 🤝 Contributing

Contributions are welcome! Here's how to get started:

1. **Fork** the repository
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Commit your changes**: `git commit -am 'Add new feature'`
4. **Push to the branch**: `git push origin feature/your-feature-name`
5. **Submit a Pull Request** with a clear description of changes

### Code Standards
- Follow Dart naming conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Run `flutter analyze` before committing
- Ensure all tests pass

---

## 📝 License

This project is currently open-source. Please refer to the LICENSE file for terms and conditions (if applicable).

---

## 🤔 FAQ

**Q: Is this app available on app stores?**
A: Check the latest releases for APK and IPA builds.

**Q: Can I use real money?**
A: No, LogixLeap uses virtual currency only. No real money is involved.

**Q: How often are investment plans updated?**
A: Investment plans are curated and updated by administrators.

**Q: Is my data secure?**
A: Yes, user data is stored locally with secure preferences and encrypted communication.

---

## 📞 Support & Contact

For issues, feature requests, or questions:
- Open an [Issue](https://github.com/dhruvsolanki404/logixleap/issues)
- Check existing [Discussions](https://github.com/dhruvsolanki404/logixleap/discussions)
- Reach out to the maintainer: [dhruvsolanki404](https://github.com/dhruvsolanki404)

---

## 🌟 Acknowledgments

- Flutter Community for excellent documentation and packages
- All contributors who help improve LogixLeap

---

**Made with ❤️ for investment learners everywhere**

---

*Last updated: 2026*

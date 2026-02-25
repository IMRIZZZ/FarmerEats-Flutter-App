# FarmerEats - Advanced Flutter Marketplace 🍏

FarmerEats is a robust mobile solution designed to bridge the gap between farmers and consumers. This project focuses on a highly secure, user-centric registration and authentication ecosystem.

## 🌟 Key Technical Implementations

### 1. Advanced UX & Navigation Logic
* **Hardware Back-Button Override:** Implemented `WillPopScope` to allow users to navigate backward through signup steps without losing form data or exiting the app.
* **Double-Tap to Exit:** Added a safety mechanism on primary screens to prevent accidental app closures.
* **Auto-Focus OTP Fields:** Designed a seamless 5-digit verification UI that automatically manages keyboard focus for a frictionless experience.

### 2. Validation & Security
* **Localized Data Logic:** Strict validation for 10-digit Indian mobile numbers and 6-digit Pincodes.
* **Complex Auth Rules:** Regex-based password security requiring uppercase, numbers, and special characters.
* **State Persistence:** Used `shared_preferences` to manage onboarding states and user sessions.

### 3. Backend Integration
* **REST API Connectivity:** Integrated with `https://sowlab.com/assignment` using the `http` package.
* **Multipart Requests:** Handles complex data structures including JSON-encoded business hours and image/file uploads for registration proof.

## 📸 Project Showcase
[https://youtu.be/8OkRh_UICBQ]

## 🛠 Tech Stack
- **Framework:** Flutter/Dart
- **Networking:** HTTP Client
- **Storage:** Shared Preferences
- **Architecture:** Clean UI separation with reusable components.

## 📄 License
Distributed under the MIT License. See `LICENSE` for more information.

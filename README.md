# flutter_crm
A cross-platform CRM (Customer Relationship Management) app built with Flutter, featuring real-time chat, peer-to-peer video/audio calls using WebRTC, offline support, and Firebase integration.

## Project Setup Instructions

1. **Clone the repository**
   ```sh
    git clone https://github.com/FLUXY01/PulseCRM.git
   cd flutter_crm
2. **Install dependencies**
   ```sh
   flutter pub get
   ```
3. **Configure Firebase**
   ```sh
   Create a Firebase project at Firebase Console.
   Add Android/iOS apps and download the google-services.json (Android) or GoogleService-Info.plist (iOS).
   Place these files in the respective platform folders:
   android/app/google-services.json
   ios/Runner/GoogleService-Info.plist
   Enable Firestore and Authentication (Email/Password) in the Firebase console.
   ```
4. **Run the app**
   ```sh
    flutter run
    ```
## Features Implemented
1. User Authentication: Sign up and sign in using Firebase Authentication.  
2. Role-based Home Screen: Users are routed to the correct home screen based on their Firestore role.  
3. Customer Management:  
     List, add, and delete customers.
     Real-time updates using Firestore streams.
     Offline support with Hive for local storage.
4. Chat Functionality:  
     Real-time chat between users and customers.
     Each chat is associated with a customer.
5. Call Logs:  
     View call history.
     Initiate calls (UI only; actual call integration depends on further implementation).
6. State Management: 
     Uses BLoC pattern for predictable state and event handling.

## Architecture and Design Decisions

1. Flutter + Firebase: 
    Chosen for rapid development, cross-platform support, and real-time data sync.

2. BLoC Pattern:  
    All business logic is separated from UI.
    Events (e.g., DeleteCustomer) are dispatched from UI and handled in BLoC.
    State changes are emitted and reflected in the UI.

3. Firestore as Source of Truth:  
    All customer and user data is stored in Firestore.
    Streams are used for real-time updates.

4. Offline Support:  
    Hive is used for local caching of customer data.
    On connectivity restoration, data is synced with Firestore.

5. Authentication Flow:  
    The AuthGate widget checks both FirebaseAuth and Firestore user document.
    If a user is authenticated but their Firestore document is missing, they are signed out and redirected to the signup page.
6. UI/UX:
    Material Design with custom gradients and theming.
    Responsive layouts for different device sizes.

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

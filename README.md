# VideoMeet - Flutter Video Call App

A complete, production-ready video calling application built with Flutter and Agora. This project demonstrates real-time video calls, user authentication, a browsable user list, and a modern Picture-in-Picture call UI.

The app is built using a clean architecture (Repository Pattern) and manages state with `Provider` and `get_it`.


| Login | Home Screen | User List | Video Call (PiP) |




## ✨ Features

* **User Authentication:** Full login flow using a real API (`reqres.in`).
* **Persistent Session:** Auth token is saved locally using `shared_preferences`.
* **Bottom Navigation:** Clean navigation between a Home screen and a User List screen.
* **Real-time Video:** 1-on-1 video calls powered by the Agora SDK.
* **Modern Call UI:** Picture-in-Picture (PiP) style call screen with a draggable local video preview, just like WhatsApp or Google Meet.
* **Full Call Controls:**
    * Mute / Unmute Microphone
    * Turn Video On / Off
    * Switch Between Front and Back Cameras
    * End Call
* **Screen Sharing:** (Android only at the moment).
* **Error Handling:** App gracefully handles loading states and API errors.

## 🚀 Tech Stack & Architecture

* **Framework:** Flutter & Dart
* **Architecture:** Repository Pattern
* **State Management:** `Provider`
* **Service Locator:** `get_it`
* **Video SDK:** `agora_rtc_engine`
* **Networking:** `Dio` (for handling all API requests)
* **Local Storage:** `shared_preferences`

### 📂 Project Structure

The project follows a clean, scalable folder structure:
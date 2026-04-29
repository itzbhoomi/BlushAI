# BlushAI 🌸

BlushAI is an AI-powered menstrual and mental health tracking iOS application. It brings together sophisticated cycle predictions, daily wellness logging, and actionable AI insights into a premium, aesthetic interface. 

BlushAI is designed to be more than just a period tracker—it's a holistic wellness coach that adapts to your unique cycle patterns and mental health needs.

## ✨ Features

- **📅 Smart Cycle Tracking**: Log your periods and receive intelligent predictions about your cycle phases.
- **🗓️ Interactive Calendar**: A clear, visual calendar to review past check-ins, moods, and cycle events at a glance.
- **⚠️ Health Risk Assessments**: Proactive health insights delivered via full-width interactive cards and detailed modal sheets.
- **📊 Advanced Insights & Analytics**: A dynamic masonry-style dashboard displaying line, area, and bar charts for cycle and health metrics. 
- **🤖 AI Wellness Coach**: Personalized physical and mental health suggestions based on your historical cycle patterns and daily check-ins.
- **📝 Daily Health & Mood Logging**: Comprehensive check-ins for mood, physical symptoms, and journaling to track your well-being holistically.

## 🛠️ Technology Stack

- **Platform**: iOS 17+
- **UI Framework**: SwiftUI
- **Database**: SwiftData (`UserProfile`, `CycleLog`, `DailyLog`)
- **Architecture**: MVVM / Modular View Extensions

## 🗂️ Project Structure

- `App/`: App entry point (`BlushAIApp`), main lifecycle, and SwiftData model container initialization.
- `Views/`: SwiftUI views categorized by feature (e.g., `Home`, `Insights`, `Calendar`, `Onboarding`, `Settings`). 
  - *Note: Complex views like `InsightsView` are broken down into smaller, modular extensions (`Cards`, `Charts`, `AI`, `Sheets`, etc.) for maintainability.*
- `Models/`: SwiftData models defining the schema (`UserProfile`, `CycleLog`, `DailyLog`).
- `Services/`: Core business logic and integrations, including the `AIService` which powers the conversational AI and personalized suggestions.
- `Components/`: Reusable, modular UI components (e.g., `StatCard`, custom pickers).
- `Core/`: Foundational utilities, design system definitions (`Theme.swift`), and app-wide constants.
- `Resources/`: csv data files used to train the ML model

## 🚀 Getting Started

### Prerequisites
- macOS with Xcode 15 or later.
- iOS 17 Simulator or a physical device running iOS 17+.

### Installation
1. Clone the repository to your local machine.
2. Open `BlushAI.xcodeproj` in Xcode.
3. Select your target device or simulator.
4. Hit `Cmd + R` or click the "Play" button to build and run the app.

## 🎨 Design Philosophy

BlushAI prioritizes a "Pinterest-y," highly aesthetic user experience. We believe that an app designed to manage personal health should feel like a safe, inviting, and premium space. The use of micro-animations, glassmorphic overlays, and non-intrusive modal sheets ensures the UI feels responsive and alive without being overwhelming.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

## 📄 License

This project is proprietary and confidential.

---
*Built with ❤️ for holistic wellness.*

# SMRITIVAN - PHASE 0: PRODUCT DISCOVERY + UX ARCHITECTURE

## 1. Complete App Journey
The application flow is designed for extreme simplicity and clarity, avoiding cognitive overload.

*   **First Launch:** Splash Screen → Progressive Onboarding Flow.
*   **Onboarding Steps:** Welcome → Language (Crucial first step) → Region (For cultural context) → Accessibility (Voice/Text preference) → User Type (Elder/Caregiver) → Basic Profile → Short Interactive Tutorial.
*   **Daily Return (Elder):** Splash → Elder Home (Morning greeting, Today's Game, Reminders, Routine).
*   **Caregiver Access:** Caregiver PIN Entry → Caregiver Dashboard (Trends, Alerts, Adherence).

## 2. Screen Map & Navigation Architecture
*   **Onboarding:** Uses a horizontally paging flow with clear "Next" / "Back" indicators.
*   **Elder Navigation (Bottom Navigation Bar):**
    *   Home (Overview)
    *   Games (Cognitive Activities)
    *   Reminders (Meds, Hydration)
    *   Profile (Settings, Caregiver Access)
*   **Caregiver Navigation:**
    *   Overview (High-level stats)
    *   Progress (Detailed CVS trends)
    *   Alerts (Missed reminders, anomalies)
*   **Game Engine Flow:**
    *   Intro / Rules (Voice-assisted) → Active Gameplay → Subtle Feedback (Haptic+Audio) → Result / CVS Calculation → Return to Games List.

## 3. Design System & Theme
*   **Palette (Calm & Natural):**
    *   Primary: Soft Sage Green (`#84A98C`)
    *   Background: Warm Sand (`#F3EBE1`)
    *   Secondary: Muted Teal (`#52796F`)
    *   Surface: Cream (`#FAFAFA`)
    *   Accent: Soft Blue (`#A2D2FF`)
    *   Text: Dark Charcoal (`#2F3E46`)
*   **Typography:** Large, highly readable. Minimum body text `18sp`. Headings `26-32sp`. Noto Sans fonts for multi-script support (Devanagari, Assamese, etc.).
*   **Interaction:** Minimum touch targets of `64x64 dp`. No complex gestures (swipe, pinch) required for core functions.
*   **UI States:** Explicit, calm screens for Loading, Empty, Error, and Offline states.

## 4. Localization & Regional Personalization Strategy
*   **Localization (Flutter ARB):** Deep integration of `app_en.arb`, `app_hi.arb`, `app_as.arb`, `app_mni.arb`, `app_kha.arb`, `app_brx.arb`. The selected language dictates all UI text and voice prompts.
*   **Regional Engine:** A `RegionProfile` abstraction maps the selected state (e.g., Assam, Meghalaya) to visual assets (handloom patterns), audio (local instruments), and game scenarios (tea preparation routines).

## 5. Component Architecture
*   A feature-first folder structure to ensure maintainability:
    *   `lib/core/`: Theme, Localization, Database, Sync, Audio.
    *   `lib/features/`: Onboarding, Home, Games, Reminders, Caregiver.
    *   `lib/shared/`: Reusable widgets (`SmritivanButton`, `SmritivanCard`, etc.).

## 6. Database / Entity Planning (Offline-First via Drift)
*   `Users`: ID, Name, Native Language, Region, Dementia Stage, Caregiver ID.
*   `GameSessions`: Session ID, User ID, Game Type, Duration, Difficulty, Reaction Time, Success Rate, CVS, Sync Status (Pending/Synced).
*   `Reminders`: ID, User ID, Type, Time, Status (Acknowledged/Missed), Sync Status.
*   `CaregiverAlerts`: Alert ID, User ID, Reason, Urgency, Acknowledged, Sync Status.

## 7. Technical Architecture (Mobile + Backend)
*   **Mobile:** Flutter, Riverpod (State Management), Drift (Local SQLite).
*   **AI/DDA:** Local execution of the Cognitive Vitality Score (CVS) and dynamic difficulty algorithms to ensure immediate, offline response.
*   **Backend:** Python FastAPI + PostgreSQL.
*   **Sync Mechanism:** A background sync queue on the mobile client pushes batched events to the FastAPI backend when the internet is restored, using timestamp-based conflict resolution.

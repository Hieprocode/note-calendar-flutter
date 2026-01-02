# Copilot Instructions — Note Calendar

Purpose: Make AI coding agents immediately productive in this Flutter + GetX app by capturing the project’s architecture, workflows, and conventions that aren’t obvious from code alone.

## Big Picture
- Flutter mobile app for managing shop bookings (salon/spa/etc.).
- GetX drives state, routing, and DI; feature modules follow a consistent pattern.
- Data lives in Firebase (Auth, Firestore, FCM). Supabase is used for Edge Functions and scheduled jobs that send FCM notifications via FCM v1 API.

## Architecture
- Entry: lib/main.dart initializes Firebase, Supabase, local notifications, and FCM, then boots GetMaterialApp with InitialBinding and routes.
- DI: lib/core/base/initial_binding.dart registers repositories/services as singletons. Per-screen controllers are provided by each module’s Binding via Get.lazyPut.
- Routing: lib/routes/app_routes.dart defines names; lib/routes/app_pages.dart maps routes to pages and bindings. Dashboard is a parent shell; feature tabs are inside it.
- Feature Modules: lib/modules/<feature>/ contains three files: <feature>_view.dart (UI), <feature>_controller.dart (logic), <feature>_binding.dart (DI). Controllers extend core/base/base_controller.dart for loading/error helpers.

## Data + Notifications
- Repositories (lib/data/repositories/*) wrap external systems. Example:
  - booking_repository.dart: Firestore CRUD for bookings; also calls Supabase Edge Function send-notification to broadcast FCM and writes a notifications document for history.
  - notification_repository.dart: Streams and updates notifications collection.
- Local notifications: lib/data/services/notification_service.dart sets up channel and shows/schedules notifications (Android/iOS).
- Push notifications: lib/data/services/fcm_service.dart requests permission, saves FCM token in Firestore users/{uid}, subscribes to topic shop_{uid}_notifications, handles foreground/background taps.
- Edge Functions: supabase/functions/send-notification/index.ts sends FCM (topic-based). supabase/functions/check-upcoming-bookings/index.ts runs as a cron job to remind upcoming bookings.
- Firebase Functions (optional path): functions/index.js also triggers on Firestore writes to send FCM and persist notification history.

## Project Conventions
- Naming: files/folders snake_case; classes PascalCase; variables/methods camelCase; constants SCREAMING_SNAKE_CASE (see RULES.md).
- Separation: UI in Views only; business logic in Controllers; external IO in Repositories/Services.
- Imports: relative within a module; absolute (package:note_calendar/...) when crossing modules or using core.
- Bindings: Always add a *Binding for each screen to configure its Controller and dependencies.

## Common Tasks
- Add a screen/module:
  1) Create lib/modules/feature/{feature}_view.dart, {feature}_controller.dart, {feature}_binding.dart.
  2) Register route in lib/routes/app_routes.dart and lib/routes/app_pages.dart.
  3) Wire any repositories/services in the Binding and, if shared, in core/base/initial_binding.dart.
- Work with bookings:
  - Use BookingRepository.createBooking/updateBooking/updateStatus/deleteBooking.
  - Persist/stream notifications through NotificationRepository; prefer topic-based FCM via Supabase function instead of client-to-many.
- Handle notifications in-app:
  - Use NotificationService.showNotification/scheduleBookingReminder. Foreground FCM is mapped to local notifications; taps route via Get.

## Build, Run, Deploy
- Local run:
  - flutter pub get
  - flutter run
- Formatting: dart format .
- Firebase Functions (Node 20 per firebase.json):
  - Deploy: firebase deploy --only functions
- Supabase Edge Functions:
  - Login/link once (see DEPLOY_EDGE_FUNCTION.md), then:
  - npx supabase functions deploy send-notification
  - npx supabase functions deploy check-upcoming-bookings
  - Cron: apply supabase/setup-cron.sql in Supabase SQL editor.

## Configuration
- Firebase config is generated in lib/firebase_options.dart; Android google-services.json is committed for convenience.
- Supabase: lib/core/config/supabase_config.dart contains url and anonKey. Edge functions require FIREBASE_SERVICE_ACCOUNT (JSON) in Supabase secrets.

## Patterns to Follow (Do/Don’t)
- Do put all IO/stateful logic in Controllers/Repositories; Views stay declarative.
- Do provide a Binding per View; don’t access repositories via global singletons without DI.
- Do stream Firestore via repositories and expose Rx in controllers; don’t query directly in Views.
- Do use topic shop_{uid}_notifications for broadcast; don’t send device-by-device from the client.

Reference files to study first: 
- lib/main.dart, lib/core/base/initial_binding.dart, lib/routes/app_routes.dart, lib/routes/app_pages.dart
- lib/data/repositories/booking_repository.dart, lib/data/services/fcm_service.dart, lib/data/services/notification_service.dart
- supabase/functions/send-notification/index.ts, supabase/functions/check-upcoming-bookings/index.ts

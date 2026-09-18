# Role: Mobile Engineer

**Owns:** React Native / Expo, Flutter, native iOS/Android screens, navigation, device APIs (camera, location, notifications), offline behavior, app configuration.

## Before coding
- React Native: Expo managed vs bare (are `ios/` and `android/` committed?), Expo SDK version, router (expo-router vs react-navigation), data layer. Flutter: SDK version, state management (Riverpod/Bloc/Provider), router.
- How is the API base URL configured per environment? (app config `extra`, env files, flavors.)
- Mirror an existing screen: layout primitives, styling system, data fetching, error handling.

## Standards
- **Platform paths:** handle iOS and Android differences — SafeArea, keyboard avoiding, Android hardware back, status bar, permissions including the *denied* path.
- **Networking in dev:** Android emulator reaches the host at `10.0.2.2`; iOS simulator can use `localhost`; physical devices need the LAN IP or a tunnel.
- **Lists:** FlatList/FlashList with stable `keyExtractor` (Flutter: `ListView.builder`); never a ScrollView for long lists.
- **Resilience:** loading, empty, error, and retry states; tolerate missing/null API fields; handle offline and slow networks.
- **Native changes** (new native module, permission, config plugin) require a rebuild: dev client / `expo prebuild`; Expo Go cannot load custom native code.
- **Secrets never ship in the bundle.** Anything in the app binary is public.
- **RTL/i18n:** `I18nManager` (RN) or `Directionality`/`flutter_localizations` (Flutter) when the app supports Arabic or other RTL languages.
- **Backwards compatibility:** old app versions stay installed; don't depend on API changes that break them.
- Only bump version/build numbers or touch signing when the task asks.

## Done checklist
- [ ] Typecheck/lint/tests pass.
- [ ] Builds for at least one platform (both if the change touches platform code).
- [ ] Flow verified on a simulator/emulator (Maestro flow or device tooling). If no simulator is available, verify via Expo web or widget tests and list the gap explicitly.
- [ ] Denied-permission and offline paths checked when relevant.

## Common pitfalls
- Stale Metro cache (`npx expo start --clear`).
- Keyboard covering inputs; content under notches.
- Large images decoded at full size → memory crashes on Android.
- Deep links not registered for both platforms.

# Repository Guidelines

## Project Structure & Module Organization
Core entrypoint lives in `lib/main.dart`, with presentation in `lib/screens/`, orchestration in `lib/controllers/`, data access in `lib/services/`, and state wiring in `lib/providers/`. Shared widgets stay in `lib/components/` and layout scaffolds in `lib/layouts/`; cross-cutting helpers sit in `lib/utils/` and `lib/helpers/`. Store media and JSON in `assets/`, platform shells in `android/`, `ios/`, and `web/`. Mirror this layout under `test/` when introducing suites.

## Build, Test, and Development Commands
Run `flutter pub get` after dependency changes. `flutter run --target=lib/main.dart` gives fast local smoke checks, while `flutter analyze` enforces the `flutter_lints` rules. Use `flutter test` before every PR, and `flutter build apk --release --split-per-abi` or `flutter build appbundle --release` when prepping artifacts; these match the `.github/workflows/release-apk.yml` automation.

## Coding Style & Naming Conventions
Keep the Dart standard 2-space indentation and format with `dart format .` (or `flutter format .`) before committing. Classes and providers use `UpperCamelCase`; methods, fields, and controllers stay `lowerCamelCase`; files use `snake_case.dart`. Group imports by package, third-party, then relative, and prefer structured logging utilities over `print`. Add `///` doc comments wherever intent is non-obvious.

## Testing Guidelines
Place automated coverage in `test/`, mirroring the related `lib/` path and naming files `*_test.dart`. Use widget tests for UI flows and focused unit tests for services and providers. Run `flutter test --coverage` when assessing release readiness and ensure descriptive `group` or `test` names highlight the expected outcome.

## Commit & Pull Request Guidelines
Write small, imperative commits, reflecting the existing log (`Fix async context usage`, `chore(image_helper): remove unused material import`). Conventional Commit prefixes are welcome for scoped maintenance work. Before opening a PR, rebase onto the latest mainline, summarize the change, link issues, and attach emulator screenshots for UI updates. Confirm `flutter analyze` and `flutter test` succeed locally, calling out any intentional skips.

## Release & Configuration Tips
Update `pubspec.yaml` versioning and changelog entries before tagging. Push tags in the `v*` pattern (`git tag v1.2.0 && git push origin v1.2.0`) to trigger the release workflow that produces split APKs and an AAB. Validate signing secrets in GitHub before dispatching a manual run, and keep environment-sensitive values in ignored `.env` files managed through your deployment tooling.

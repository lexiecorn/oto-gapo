# Testing Guide

This directory contains automated tests for the Otogapo application. This guide will help you understand the testing structure, run tests, and write new tests.

## Table of Contents

- [Quick Start](#quick-start)
- [Test Structure](#test-structure)
- [Running Tests](#running-tests)
- [Writing Tests](#writing-tests)
- [Testing Patterns](#testing-patterns)
- [Best Practices](#best-practices)

## Quick Start

Run all tests:

```bash
flutter test
```

Run specific test file:

```bash
flutter test test/app/pages/car_widget_test.dart
```

Run with coverage:

```bash
flutter test --coverage
```

Watch mode (reruns on file changes):

```bash
flutter test --watch
```

## Test Structure

```
test/
├── helpers/                    # Shared test utilities
│   ├── pump_app.dart          # Widget wrapper with MaterialApp & ScreenUtil
│   ├── mock_factories.dart    # Factory methods for test data
│   └── test_helpers.dart      # Convenience re-exports
│
├── app/
│   └── pages/
│       └── car_widget_test.dart  # CarWidget widget tests
│
└── README.md                  # This file
```

## Running Tests

### Run All Tests

```bash
flutter test
```

### Run Specific Test File

```bash
flutter test test/app/pages/car_widget_test.dart
```

### Run Tests by Name Pattern

```bash
# Run all tests with "animation" in the name
flutter test --plain-name animation
```

### Run with Verbose Output

```bash
flutter test --verbose
```

### Run with Coverage Report

```bash
# Generate coverage
flutter test --coverage

# View coverage in terminal (requires lcov)
lcov --summary coverage/lcov.info

# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
# Open coverage/html/index.html in browser
```

### Run in Watch Mode

Watch mode automatically reruns tests when you save changes, providing fast feedback during TDD:

```bash
flutter test --watch
```

**TDD Workflow with Watch Mode:**

1. **Start watch mode** in a terminal: `flutter test --watch`
2. **Write a failing test** first (red phase)
3. **Implement the code** to make the test pass (green phase)
4. **Refactor** while tests remain green
5. **Watch mode automatically reruns** tests on save, giving instant feedback

**Tips:**
- Keep watch mode running while coding for instant feedback
- Tests run automatically when you save any test or source file
- Press `q` to quit watch mode
- Press `r` to manually rerun tests
- Press `Enter` to run all tests again

**Running Specific Tests in Watch Mode:**

```bash
# Watch mode for specific test file
flutter test --watch test/app/modules/auth/auth_bloc_test.dart

# Watch mode for tests matching a pattern
flutter test --watch --plain-name "auth"
```

## Writing Tests

### Test File Organization

Tests should mirror the structure of the `lib/` directory:

```
lib/app/pages/car_widget.dart  →  test/app/pages/car_widget_test.dart
lib/app/widgets/my_widget.dart →  test/app/widgets/my_widget_test.dart
```

### Basic Widget Test Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:otogapo/app/pages/my_widget.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('MyWidget', () {
    testWidgets('displays correctly', (tester) async {
      // Arrange - Set up test data
      final state = createMockProfileState();

      // Act - Render the widget
      await tester.pumpAndSettleTestApp(
        MyWidget(state: state),
      );

      // Assert - Verify expectations
      expect(find.byType(MyWidget), findsOneWidget);
      expect(find.text('Expected Text'), findsOneWidget);
    });
  });
}
```

### Using Test Helpers

#### Creating Test Widgets

```dart
// Pump widget with test app wrapper (theme, ScreenUtil, etc.)
await tester.pumpAndSettleTestApp(
  CarWidget(state: mockState),
);
```

#### Creating Mock Data

```dart
// Create a vehicle with defaults
final vehicle = createMockVehicle();

// Create a vehicle with custom values
final customVehicle = createMockVehicle(
  make: 'Honda',
  model: 'Civic',
  plateNumber: 'ABC-1234',
);

// Create a ProfileState with a vehicle
final state = createProfileStateWithVehicle(
  make: 'Toyota',
  model: 'Vios',
);

// Create an empty ProfileState
final emptyState = createEmptyProfileState();

// Create a loading ProfileState
final loadingState = createLoadingProfileState();
```

#### Using Mock Cubits

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

testWidgets('works with cubit', (tester) async {
  // Create mock cubit with initial state
  final state = createProfileStateWithVehicle();
  final mockCubit = createMockProfileCubitWithState(state);

  // Set up state stream
  whenListen(
    mockCubit,
    Stream.fromIterable([state]),
    initialState: state,
  );

  // Wrap widget with BlocProvider
  await tester.pumpAndSettleTestApp(
    BlocProvider<ProfileCubit>.value(
      value: mockCubit,
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return CarWidget(state: state);
        },
      ),
    ),
  );

  // Assertions...
});
```

## Testing Patterns

### 1. Widget Rendering Tests

Test that widgets render correctly with various states:

```dart
testWidgets('displays vehicle information', (tester) async {
  final state = createProfileStateWithVehicle(
    make: 'Honda',
    model: 'Civic',
  );

  await tester.pumpAndSettleTestApp(CarWidget(state: state));

  expect(find.text('Honda Civic'), findsOneWidget);
});
```

### 2. Empty State Tests

Test how widgets handle empty or missing data:

```dart
testWidgets('shows empty message when no data', (tester) async {
  final state = createEmptyProfileState();

  await tester.pumpAndSettleTestApp(MyWidget(state: state));

  expect(find.text('No data available'), findsOneWidget);
});
```

### 3. Animation Tests

Test that animation widgets exist and complete successfully:

```dart
testWidgets('contains animations', (tester) async {
  final state = createProfileStateWithVehicle();

  await tester.pumpTestApp(CarWidget(state: state));

  // Verify animation widgets exist
  expect(find.byType(FadeTransition), findsOneWidget);
  expect(find.byType(SlideTransition), findsOneWidget);

  // Let animations complete
  await tester.pumpAndSettle();

  // Verify content is visible
  expect(find.text('Toyota Vios'), findsOneWidget);
});
```

**Note:** We use `pumpAndSettle()` to wait for animations to complete. This is pragmatic and avoids brittle timing-based tests.

### 4. FutureBuilder Tests

Test widgets that load data asynchronously:

```dart
testWidgets('shows loading then content', (tester) async {
  final state = createProfileStateWithVehicle();

  // Pump widget but don't settle (catches loading state)
  await tester.pumpTestApp(CarWidget(state: state));
  await tester.pump();

  // Loading indicator should be visible
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  // Let futures resolve
  await tester.pumpAndSettle();

  // Content should be visible
  expect(find.text('Toyota Vios'), findsOneWidget);
});
```

### 5. User Interaction Tests

Test widgets that respond to user input:

```dart
testWidgets('responds to button tap', (tester) async {
  var tapped = false;

  await tester.pumpAndSettleTestApp(
    ElevatedButton(
      onPressed: () => tapped = true,
      child: Text('Tap Me'),
    ),
  );

  await tester.tap(find.text('Tap Me'));
  await tester.pump();

  expect(tapped, isTrue);
});
```

### 6. Edge Cases

Test unusual or extreme scenarios:

```dart
testWidgets('handles very long text', (tester) async {
  final state = createProfileStateWithVehicle(
    make: 'Very Long Make Name',
    model: 'Very Long Model Name That Exceeds Normal Length',
  );

  await tester.pumpAndSettleTestApp(CarWidget(state: state));

  // Should render without overflow
  expect(tester.takeException(), isNull);
});
```

## Best Practices

### 1. Use Descriptive Test Names

❌ Bad:

```dart
testWidgets('test 1', (tester) async { ... });
```

✅ Good:

```dart
testWidgets('displays vehicle information correctly', (tester) async { ... });
```

### 2. Follow Arrange-Act-Assert Pattern

```dart
testWidgets('example test', (tester) async {
  // Arrange - Set up test conditions
  final state = createProfileStateWithVehicle();

  // Act - Perform the action being tested
  await tester.pumpAndSettleTestApp(CarWidget(state: state));

  // Assert - Verify the results
  expect(find.text('Toyota Vios'), findsOneWidget);
});
```

### 3. Use Test Helpers

Always use the helper utilities in `test/helpers/` instead of creating test data inline:

❌ Avoid:

```dart
final vehicle = Vehicle(
  make: 'Toyota',
  model: 'Vios',
  year: '2020',
  type: 'Sedan',
  color: 'Silver',
  plateNumber: 'ABC-1234',
);
```

✅ Prefer:

```dart
final vehicle = createMockVehicle(
  make: 'Toyota',
  model: 'Vios',
);
```

### 4. Group Related Tests

Use `group()` to organize related tests:

```dart
group('MyWidget', () {
  group('Rendering', () {
    testWidgets('test 1', ...);
    testWidgets('test 2', ...);
  });

  group('User Interactions', () {
    testWidgets('test 3', ...);
  });
});
```

### 5. Test Behavior, Not Implementation

❌ Avoid testing internal implementation:

```dart
// Don't test private methods or internal state
expect(widget._internalVariable, equals(42));
```

✅ Test observable behavior:

```dart
// Test what users see and interact with
expect(find.text('Expected Output'), findsOneWidget);
```

### 6. Keep Tests Independent

Each test should be self-contained and not depend on other tests:

❌ Avoid:

```dart
var sharedState; // Don't share state between tests

testWidgets('test 1', (tester) async {
  sharedState = createState();
  // ...
});

testWidgets('test 2', (tester) async {
  // Uses sharedState from test 1 - BAD!
});
```

✅ Prefer:

```dart
testWidgets('test 1', (tester) async {
  final state = createState(); // Each test creates its own state
  // ...
});

testWidgets('test 2', (tester) async {
  final state = createState(); // Independent state
  // ...
});
```

### 7. Use setUp and tearDown Sparingly

Only use `setUp` and `tearDown` for true setup/cleanup that every test needs:

```dart
group('MyWidget', () {
  late MockDependency mockDep;

  setUp(() {
    mockDep = MockDependency();
  });

  tearDown(() {
    mockDep.dispose();
  });

  testWidgets('test with mockDep', (tester) async {
    // mockDep is available here
  });
});
```

## Mock Strategies

### Strategy A: Direct State Mocks (Simple)

Best for: Simple widget tests where you just need state data.

```dart
testWidgets('example', (tester) async {
  final state = createProfileStateWithVehicle(
    make: 'Toyota',
    model: 'Vios',
  );

  await tester.pumpAndSettleTestApp(
    CarWidget(state: state),
  );

  expect(find.text('Toyota Vios'), findsOneWidget);
});
```

### Strategy B: Cubit Mocks (Realistic)

Best for: Testing state changes, cubit interactions, or BlocBuilder behavior.

```dart
testWidgets('example', (tester) async {
  final state = createProfileStateWithVehicle();
  final mockCubit = createMockProfileCubitWithState(state);

  whenListen(
    mockCubit,
    Stream.fromIterable([state]),
    initialState: state,
  );

  await tester.pumpAndSettleTestApp(
    BlocProvider<ProfileCubit>.value(
      value: mockCubit,
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return CarWidget(state: state);
        },
      ),
    ),
  );

  expect(find.text('Toyota Vios'), findsOneWidget);
});
```

## Common Issues and Solutions

### Issue: Test times out

**Problem:** `pumpAndSettle()` never completes.

**Solution:** Widget has infinite or very long animations. Use `pump()` with duration instead:

```dart
await tester.pump(const Duration(seconds: 1));
```

### Issue: "Bad state: No element"

**Problem:** Widget not found when expected.

**Solution:**

1. Check that you're using correct finder
2. Ensure widget has been pumped
3. Use `find.byType()` instead of `find.byWidget()` for easier matching

```dart
// If find.text() doesn't work, try:
expect(find.byWidgetPredicate(
  (widget) => widget is Text && widget.data == 'Expected',
), findsOneWidget);
```

### Issue: "Null check operator used on a null value"

**Problem:** Missing required data in mocks.

**Solution:** Use factory methods that provide sensible defaults:

```dart
final state = createProfileStateWithVehicle(); // Has defaults
```

### Issue: "MediaQuery ancestor not found"

**Problem:** Widget requires MaterialApp ancestor.

**Solution:** Use test helper:

```dart
await tester.pumpAndSettleTestApp(myWidget); // Wraps in MaterialApp
```

## Next Steps

### Phase 2: Golden Tests (Future)

Golden tests capture pixel-perfect screenshots and detect visual regressions:

```bash
# Add to pubspec.yaml dev_dependencies:
# golden_toolkit: ^0.15.0

# Run golden tests
flutter test --update-goldens
```

### Phase 3: Integration Tests (Future)

End-to-end tests that run on real devices or emulators:

```bash
# Run integration tests
flutter test integration_test/
```

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Widget Testing Guide](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [mocktail Package](https://pub.dev/packages/mocktail)
- [bloc_test Package](https://pub.dev/packages/bloc_test)
- [Very Good Engineering Testing Best Practices](https://verygood.ventures/blog/flutter-testing-best-practices)

## Test-Driven Development (TDD) Workflow

### What is TDD?

TDD is a development practice where you write tests before implementing code:

1. **Red**: Write a failing test that describes desired behavior
2. **Green**: Write minimal code to make the test pass
3. **Refactor**: Improve code while keeping tests green

### When to Use TDD

✅ **Recommended for:**
- **Blocs/Cubits**: State management logic with clear state transitions
- **Business logic**: Validators, formatters, calculations
- **Repositories**: Data access and transformation logic
- **Services**: Pure functions and utility methods

⏭️ **Pragmatic approach for:**
- **Complex UI widgets**: Write behavior-focused tests after UI stabilizes
- **Exploratory features**: Spike first, then add tests

### TDD Example: AuthBloc

```dart
// 1. RED: Write failing test first
blocTest<AuthBloc, AuthState>(
  'emits authenticated state when sign-in succeeds',
  setUp: () {
    when(() => mockPocketBaseAuth.signIn(...))
        .thenAnswer((_) async {});
    when(() => mockPocketBaseAuth.user)
        .thenAnswer((_) => Stream.value(mockUser));
  },
  build: () => AuthBloc(...),
  act: (bloc) => bloc.add(SignInRequestedEvent(...)),
  expect: () => [
    AuthState(authStatus: AuthStatus.unknown),
    AuthState(authStatus: AuthStatus.authenticated, user: mockUser),
  ],
);

// 2. GREEN: Implement minimal code to pass
// (In AuthBloc, implement SignInRequestedEvent handler)

// 3. REFACTOR: Improve code while tests remain green
```

### TDD Best Practices

1. **Start with the simplest test** that fails
2. **Write one test at a time** - watch mode helps with this
3. **Make tests pass with minimal code** - avoid over-engineering
4. **Refactor only when tests are green** - safe refactoring
5. **Keep tests fast** - use mocks, avoid I/O in tests

### Running TDD Workflow

```bash
# Terminal 1: Start watch mode
flutter test --watch

# Terminal 2: Edit code
# - Write failing test
# - Watch test fail (RED)
# - Implement code
# - Watch test pass (GREEN)
# - Refactor if needed
```

## Contributing

When adding new features:

1. ✅ **Use TDD for Blocs/Cubits and business logic** - write tests first
2. ✅ Write tests for new widgets
3. ✅ Use existing test helpers
4. ✅ Follow the testing patterns in this guide
5. ✅ Aim for >80% code coverage for widgets, 90%+ for Blocs/Cubits
6. ✅ Run tests before committing: `flutter test`

Happy testing! 🧪

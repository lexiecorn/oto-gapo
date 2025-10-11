# Testing Rules and Conventions

## When to Update or Create Tests

### ✅ ALWAYS write/update tests when:

1. **Creating new widgets or pages**
   - Widget tests for UI components
   - State management tests for Cubits/Blocs
   - Integration with test helpers

2. **Modifying existing widget behavior**
   - Update affected widget tests
   - Add new test cases for new behavior
   - Verify edge cases still pass

3. **Adding new Cubits or Blocs**
   - State transition tests
   - Event/action handling tests
   - Error state tests

4. **Modifying data models**
   - Update mock factories in `test/helpers/mock_factories.dart`
   - Update affected tests using those models

5. **Changing business logic**
   - Update tests to reflect new logic
   - Add tests for new edge cases
   - Verify existing tests still pass

### ⏭️ SKIP tests for:

- Simple formatting changes
- Documentation updates
- Asset additions (images, icons)
- Configuration files (unless logic-related)

## Running Tests

### Quick Commands

```bash
# Run ALL tests
flutter test

# Run specific test file
flutter test test/app/pages/car_widget_test.dart

# Run tests matching a name pattern
flutter test --plain-name "animation"

# Run with coverage report
flutter test --coverage

# Run in watch mode (reruns on changes)
flutter test --watch

# Run with verbose output
flutter test --verbose
```

### Coverage Reports

```bash
# Generate coverage
flutter test --coverage

# View summary (requires lcov)
lcov --summary coverage/lcov.info

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html
# Then open coverage/html/index.html in browser
```

## Test File Structure

### Directory Organization

Mirror `lib/` structure in `test/`:

```
lib/app/pages/car_widget.dart    → test/app/pages/car_widget_test.dart
lib/app/widgets/my_widget.dart   → test/app/widgets/my_widget_test.dart
lib/app/modules/auth/auth_bloc.dart → test/app/modules/auth/auth_bloc_test.dart
```

### Test File Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:otogapo/app/pages/my_widget.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('MyWidget', () {
    group('Rendering', () {
      testWidgets('displays correctly with valid data', (tester) async {
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

    group('Empty State', () {
      testWidgets('shows empty message when no data', (tester) async {
        final state = createEmptyProfileState();

        await tester.pumpAndSettleTestApp(MyWidget(state: state));

        expect(find.text('No data'), findsOneWidget);
      });
    });

    group('User Interactions', () {
      testWidgets('responds to button tap', (tester) async {
        // Test user interactions here
      });
    });
  });
}
```

## Using Test Helpers

### Available Helpers (in `test/helpers/`)

#### 1. Widget Testing Extensions

```dart
// Pump widget with full app wrapper (MaterialApp, ScreenUtil, Theme)
await tester.pumpTestApp(MyWidget());

// Pump and wait for all animations to complete
await tester.pumpAndSettleTestApp(MyWidget());
```

#### 2. Mock Data Factories

```dart
// Create mock ProfileState with vehicle
final state = createProfileStateWithVehicle(
  make: 'Toyota',
  model: 'Vios',
  plateNumber: 'ABC-1234',
  color: 'Silver',
  year: '2020',
);

// Create empty state
final emptyState = createEmptyProfileState();

// Create loading state
final loadingState = createLoadingProfileState();

// Create mock Vehicle directly
final vehicle = createMockVehicle(
  make: 'Honda',
  model: 'Civic',
);
```

#### 3. Mock Cubits (for BlocBuilder tests)

```dart
import 'package:bloc_test/bloc_test.dart';

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
    child: MyWidget(),
  ),
);
```

## Testing Patterns

### 1. Widget Rendering Tests

Test that widgets display correctly:

```dart
testWidgets('displays vehicle information', (tester) async {
  final state = createProfileStateWithVehicle(
    make: 'Honda',
    model: 'Civic',
  );

  await tester.pumpAndSettleTestApp(CarWidget(state: state));

  expect(find.text('Honda Civic'), findsOneWidget);
  expect(find.byType(CarWidget), findsOneWidget);
});
```

### 2. Empty/Null State Tests

Test graceful handling of missing data:

```dart
testWidgets('shows empty message when no data', (tester) async {
  final state = createEmptyProfileState();

  await tester.pumpAndSettleTestApp(MyWidget(state: state));

  expect(find.text('No data available'), findsOneWidget);
});
```

### 3. Animation Tests

**⚠️ Known Issue:** `flutter_animate` creates infinite animations that conflict with `pumpAndSettle()`.

**Solution:** Use manual pumps instead:

```dart
testWidgets('handles animations pragmatically', (tester) async {
  final state = createProfileStateWithVehicle();

  // Pump widget but don't wait for all animations
  await tester.pumpTestApp(CarWidget(state: state));
  
  // Pump a few frames manually
  for (int i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  // Verify content is visible
  expect(find.text('Toyota Vios'), findsOneWidget);
});
```

### 4. User Interaction Tests

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

### 5. Edge Cases

Test unusual scenarios:

```dart
testWidgets('handles very long text without overflow', (tester) async {
  final state = createProfileStateWithVehicle(
    make: 'Very Long Make Name That Exceeds Normal Length',
    model: 'Very Long Model Name',
  );

  await tester.pumpAndSettleTestApp(CarWidget(state: state));

  // Should render without overflow errors
  expect(tester.takeException(), isNull);
});

testWidgets('handles special characters', (tester) async {
  final state = createProfileStateWithVehicle(
    make: "O'Reilly's",
    model: 'Test & Debug',
    plateNumber: 'ÑÂÊ-123',
  );

  await tester.pumpAndSettleTestApp(CarWidget(state: state));

  expect(find.text("O'Reilly's Test & Debug"), findsOneWidget);
});
```

## Best Practices

### 1. Use Descriptive Test Names

❌ **BAD:**
```dart
testWidgets('test 1', (tester) async { ... });
testWidgets('works', (tester) async { ... });
```

✅ **GOOD:**
```dart
testWidgets('displays vehicle information correctly', (tester) async { ... });
testWidgets('shows empty state when vehicles list is empty', (tester) async { ... });
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

### 3. Use Test Helpers, Not Inline Data

❌ **AVOID:**
```dart
final vehicle = Vehicle(
  make: 'Toyota',
  model: 'Vios',
  year: '2020',
  type: 'Sedan',
  color: 'Silver',
  plateNumber: 'ABC-1234',
  // ... many more fields
);
```

✅ **PREFER:**
```dart
final vehicle = createMockVehicle(
  make: 'Toyota',
  model: 'Vios',
);
```

### 4. Group Related Tests

```dart
group('MyWidget', () {
  group('Rendering', () {
    testWidgets('test 1', ...);
    testWidgets('test 2', ...);
  });

  group('User Interactions', () {
    testWidgets('test 3', ...);
  });

  group('Empty State', () {
    testWidgets('test 4', ...);
  });
});
```

### 5. Test Behavior, Not Implementation

❌ **AVOID:**
```dart
// Don't test private methods or internal state
expect(widget._internalVariable, equals(42));
expect(controller.animationValue, closeTo(0.5, 0.01));
```

✅ **PREFER:**
```dart
// Test what users see and interact with
expect(find.text('Expected Output'), findsOneWidget);
expect(find.byType(MyWidget), findsOneWidget);
```

### 6. Keep Tests Independent

Each test should be self-contained:

❌ **AVOID:**
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

✅ **PREFER:**
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

### 7. Prefer pumpAndSettleTestApp for Most Cases

```dart
// Use this for most widget tests
await tester.pumpAndSettleTestApp(MyWidget());

// Use pumpTestApp + manual pumps only for flutter_animate widgets
await tester.pumpTestApp(MyWidget());
await tester.pump(const Duration(milliseconds: 100));
```

## Common Test Scenarios

### Testing Widgets with ProfileState

```dart
testWidgets('example with ProfileState', (tester) async {
  final state = createProfileStateWithVehicle(
    make: 'Toyota',
    model: 'Vios',
  );

  await tester.pumpAndSettleTestApp(MyWidget(state: state));

  expect(find.text('Toyota Vios'), findsOneWidget);
});
```

### Testing with Cubit/Bloc

```dart
testWidgets('example with Cubit', (tester) async {
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
        builder: (context, state) => MyWidget(state: state),
      ),
    ),
  );

  expect(find.text('Toyota Vios'), findsOneWidget);
});
```

### Testing with Multiple States

```dart
testWidgets('responds to state changes', (tester) async {
  final initialState = createEmptyProfileState();
  final updatedState = createProfileStateWithVehicle();
  
  final mockCubit = createMockProfileCubitWithState(initialState);

  whenListen(
    mockCubit,
    Stream.fromIterable([initialState, updatedState]),
    initialState: initialState,
  );

  await tester.pumpAndSettleTestApp(
    BlocProvider<ProfileCubit>.value(
      value: mockCubit,
      child: MyWidget(),
    ),
  );

  // Initially empty
  expect(find.text('No Vehicle'), findsOneWidget);

  // After state change
  await tester.pump();
  expect(find.text('Toyota Vios'), findsOneWidget);
});
```

## Troubleshooting

### Issue: Test times out

**Problem:** `pumpAndSettle()` never completes.

**Solution:** Widget has infinite animations (e.g., `flutter_animate`). Use manual pumps:

```dart
await tester.pumpTestApp(widget);
for (int i = 0; i < 3; i++) {
  await tester.pump(const Duration(milliseconds: 100));
}
```

### Issue: "Bad state: No element"

**Problem:** Widget not found when expected.

**Solutions:**
1. Ensure widget has been pumped
2. Use `find.byType()` instead of `find.byWidget()`
3. Check widget is actually rendered (not in a conditional that's false)

```dart
// Use debugDumpApp() to see widget tree
debugDumpApp();
```

### Issue: "Null check operator used on a null value"

**Problem:** Missing required data in mocks.

**Solution:** Use factory methods that provide sensible defaults:

```dart
final state = createProfileStateWithVehicle(); // Has defaults
```

### Issue: "MediaQuery ancestor not found" or "MaterialLocalizations not found"

**Problem:** Widget requires MaterialApp ancestor.

**Solution:** Use test helper:

```dart
await tester.pumpAndSettleTestApp(myWidget); // Wraps in MaterialApp
```

## Adding New Mock Factories

When creating new models, add factory methods to `test/helpers/mock_factories.dart`:

```dart
/// Creates a mock [MyModel] with sensible defaults.
MyModel createMockMyModel({
  String? field1,
  int? field2,
}) {
  return MyModel(
    field1: field1 ?? 'Default Value',
    field2: field2 ?? 42,
    // ... other fields with defaults
  );
}
```

## Test Coverage Goals

- **Widget Tests:** Aim for >80% coverage
- **Cubit/Bloc Tests:** Aim for 100% coverage of state transitions
- **Critical Business Logic:** Aim for 100% coverage

## Pre-commit Checklist

Before committing code changes:

1. ✅ Run `flutter test` - all tests must pass
2. ✅ Add/update tests for changed code
3. ✅ Verify test coverage hasn't decreased: `flutter test --coverage`
4. ✅ Update mock factories if models changed
5. ✅ Update test documentation if patterns changed

## Resources

- **Full Testing Guide:** `test/README.md`
- **Test Summary:** `test/TESTING_SUMMARY.md`
- **Test Helpers:** `test/helpers/`
- **Example Tests:** `test/app/pages/car_widget_test.dart`

## Quick Reference

```bash
# Essential commands
flutter test                                  # Run all tests
flutter test test/path/to/test.dart          # Run specific test
flutter test --coverage                       # Generate coverage
flutter test --watch                          # Watch mode

# Test file naming
lib/app/pages/my_widget.dart → test/app/pages/my_widget_test.dart

# Test structure
group('MyWidget', () {
  testWidgets('does something', (tester) async {
    // Arrange
    final data = createMockData();
    
    // Act
    await tester.pumpAndSettleTestApp(MyWidget(data: data));
    
    // Assert
    expect(find.text('Expected'), findsOneWidget);
  });
});
```


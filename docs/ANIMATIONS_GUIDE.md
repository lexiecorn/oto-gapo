# Animations Guide

## Overview

OtoGapo implements smooth, purposeful animations throughout the app to enhance user experience. This guide documents animation patterns, best practices, and implementation details.

## Animation Philosophy

### Principles

1. **Purpose**: Every animation serves a functional purpose
2. **Performance**: Animations run at 60fps on target devices
3. **Consistency**: Similar actions use similar animations
4. **Subtlety**: Animations enhance, not distract
5. **Accessibility**: Respect user motion preferences

### Duration Guidelines

- **Micro-interactions**: 150-300ms (buttons, toggles)
- **Page transitions**: 300-400ms
- **List animations**: 375ms
- **Loading states**: Infinite (shimmer, spinners)
- **Celebration**: 500-1000ms (confetti, success)

## Animation Packages Used

### 1. flutter_animate

**Used for**: Widget-level animations

```dart
import 'package:flutter_animate/flutter_animate.dart';

// Example
Text('Hello')
  .animate()
  .fadeIn(duration: 400.ms)
  .slideY(begin: -0.2, end: 0, duration: 400.ms);
```

### 2. flutter_staggered_animations

**Used for**: List and grid animations

```dart
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

AnimationLimiter(
  child: ListView.builder(
    itemBuilder: (context, index) {
      return AnimationConfiguration.staggeredList(
        position: index,
        duration: const Duration(milliseconds: 375),
        child: SlideAnimation(
          verticalOffset: 50.0,
          child: FadeInAnimation(
            child: YourWidget(),
          ),
        ),
      );
    },
  ),
)
```

### 3. Shimmer

**Used for**: Loading skeleton screens

```dart
import 'package:shimmer/shimmer.dart';

Shimmer.fromColors(
  baseColor: Colors.grey[300]!,
  highlightColor: Colors.grey[100]!,
  child: Container(
    width: 200,
    height: 20,
    color: Colors.white,
  ),
)
```

## Animation Patterns

### 1. Page Entry Animations

**Pattern**: Fade + Slide

```dart
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        ProfileCard()
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: -0.2, end: 0, duration: 400.ms),
      ],
    ),
  );
}
```

### 2. List Item Stagger

**Pattern**: Staggered slide + fade

```dart
AnimationConfiguration.staggeredList(
  position: index,
  duration: const Duration(milliseconds: 375),
  child: SlideAnimation(
    verticalOffset: 50.0,
    child: FadeInAnimation(
      child: ListItem(),
    ),
  ),
)
```

### 3. Button Interactions

**Pattern**: Scale + Haptic

```dart
BouncyButton(
  onPressed: () {
    // Action
  },
  child: ElevatedButton(
    onPressed: () {},
    child: Text('Click Me'),
  ),
)
```

### 4. Loading States

**Pattern**: Shimmer skeleton

```dart
if (isLoading) {
  return SkeletonLoader(
    width: double.infinity,
    height: 100.h,
  );
}
```

### 5. Success/Celebration

**Pattern**: Scale with elastic curve

```dart
Icon(Icons.check_circle)
  .animate()
  .scale(
    duration: 500.ms,
    begin: Offset(0, 0),
    end: Offset(1, 1),
    curve: Curves.elasticOut,
  )
```

### 6. Navigation Transitions

**Pattern**: Slide transitions

```dart
PageTransitions.createRoute(
  page: NextPage(),
  transitionBuilder: PageTransitions.slideFromRight,
)
```

### 7. Notification Badge

**Pattern**: Pulsing scale

```dart
Container(
  width: 10.w,
  height: 10.h,
  decoration: BoxDecoration(
    color: Colors.red,
    shape: BoxShape.circle,
  ),
)
  .animate(
    onPlay: (controller) => controller.repeat(reverse: true),
  )
  .scale(
    duration: 1000.ms,
    begin: Offset(0.8, 0.8),
    end: Offset(1.2, 1.2),
  )
```

## Custom Widgets

### BouncyButton

Adds scale animation and haptic feedback to any button.

**Usage**:

```dart
BouncyButton(
  onPressed: () => print('Tapped!'),
  child: ElevatedButton(
    onPressed: () {},
    child: Text('Click Me'),
  ),
)
```

**Variants**:

- `BouncyIconButton` - For icon buttons
- `BouncyElevatedButton` - For elevated buttons
- `BouncyTextButton` - For text buttons

### SkeletonLoader

Shimmer loading placeholders.

**Usage**:

```dart
// Simple loader
SkeletonLoader(
  width: 200.w,
  height: 20.h,
)

// Post card skeleton
SkeletonPostCard()

// Profile skeleton
SkeletonProfileCard()

// Grid skeleton
SkeletonGrid(itemCount: 6)
```

### ConnectivityBanner

Animated banner for offline status.

**Usage**:

```dart
// In AppBar PreferredSize
Column(
  children: [
    ConnectivityBanner(),
    AppBar(...),
  ],
)
```

### ProfileCompletionCard

Progress tracker with animations.

**Usage**:

```dart
// In Profile page
ProfileCompletionCard()
```

## Page-Specific Animations

### Home Page

- **Bottom Navigation**: Slide up + fade on mount
- **Nav Items**: Staggered scale animation
- **Selected Item**: Scale + gradient + shadow
- **Badge**: Pulsing animation

### Social Feed

- **Post Cards**: Staggered slide + fade
- **Pull to Refresh**: Native Material refresh
- **Infinite Scroll**: Smooth loading indicator
- **Search Icon**: Hero animation to search page

### Profile Page

- **Page Entry**: Fade transition
- **Completion Card**: Slide from top + fade
- **Celebration**: Bouncing icon on 100%
- **Refresh**: Reset + replay animation

### Attendance Calendar

- **Calendar**: Fade in
- **Streak Card**: Scale + shimmer
- **Stats**: Staggered fade
- **Date Selection**: Slide up detail card

### Admin Dashboard

- **Stat Cards**: Staggered scale
- **Number Count**: Animated count-up
- **Charts**: Fade in with delay
- **Refresh**: Rotate icon

## Performance Optimization

### Best Practices

1. **Use const**: Mark animated widgets as const when possible
2. **Limit simultaneous animations**: Max 5-10 at once
3. **Dispose controllers**: Always dispose in State.dispose()
4. **Cache animations**: Reuse animation controllers
5. **Test on low-end devices**: Ensure 60fps on slower hardware

### Performance Monitoring

```dart
// Check for jank
import 'package:flutter/scheduler.dart';

SchedulerBinding.instance.addTimingsCallback((timings) {
  for (final timing in timings) {
    if (timing.totalSpan > Duration(milliseconds: 16)) {
      print('Jank detected: ${timing.totalSpan}');
    }
  }
});
```

### Reducing Animation Overhead

```dart
// Conditionally disable on low-end devices
final shouldAnimate = MediaQuery.of(context).platformBrightness != Brightness.dark;

if (shouldAnimate) {
  return widget.animate().fadeIn();
} else {
  return widget;
}
```

## Testing Animations

### Widget Tests

Animations in tests can cause issues. Use these strategies:

```dart
testWidgets('animation test', (tester) async {
  // Use pump with duration instead of pumpAndSettle
  await tester.pumpWidget(MyAnimatedWidget());

  // Advance time manually
  await tester.pump(Duration(milliseconds: 400));

  // Verify final state
  expect(find.byType(MyWidget), findsOneWidget);
});
```

### Known Issues

- `flutter_animate` creates infinite timers in tests
- Use `pump()` with duration instead of `pumpAndSettle()`
- See `test/TESTING_SUMMARY.md` for details

## Accessibility

### Motion Preferences

Respect user motion preferences:

```dart
final reducedMotion = MediaQuery.of(context).accessibleNavigation;

final duration = reducedMotion
  ? Duration.zero
  : Duration(milliseconds: 400);
```

### Screen Reader Support

Ensure animations don't interfere with screen readers:

```dart
Semantics(
  label: 'Loading content',
  child: SkeletonLoader(),
)
```

## Animation Catalog

### Entry Animations

| Animation    | Use Case        | Duration |
| ------------ | --------------- | -------- |
| Fade In      | Cards, images   | 400ms    |
| Slide Y      | From top/bottom | 400ms    |
| Slide X      | From sides      | 300ms    |
| Scale        | Dialogs, modals | 300ms    |
| Fade + Slide | Pages           | 400ms    |

### Exit Animations

| Animation | Use Case      | Duration |
| --------- | ------------- | -------- |
| Fade Out  | Dismiss       | 200ms    |
| Slide Out | Swipe dismiss | 300ms    |
| Scale Out | Close         | 250ms    |

### Loading Animations

| Animation | Use Case | Duration    |
| --------- | -------- | ----------- |
| Shimmer   | Skeleton | Infinite    |
| Spin      | Progress | Infinite    |
| Pulse     | Badge    | 1000ms loop |

### Interaction Animations

| Animation  | Use Case       | Duration |
| ---------- | -------------- | -------- |
| Scale Down | Button press   | 150ms    |
| Ripple     | Touch feedback | Native   |
| Bounce     | Confirmation   | 500ms    |

## Code Examples

### Complete Page Animation

```dart
class MyPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with fade
          HeaderWidget()
            .animate()
            .fadeIn(duration: 400.ms),

          // Staggered list
          Expanded(
            child: AnimationLimiter(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      child: FadeInAnimation(
                        child: ListItem(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Hero Animation

```dart
// Source page
Hero(
  tag: 'profile_image',
  child: CircleAvatar(
    backgroundImage: NetworkImage(imageUrl),
  ),
)

// Destination page
Hero(
  tag: 'profile_image',
  child: Image.network(imageUrl),
)
```

### Custom Animation Controller

```dart
class _MyWidgetState extends State<MyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: MyContent(),
    );
  }
}
```

## Resources

- [Flutter Animations Documentation](https://docs.flutter.dev/development/ui/animations)
- [Material Motion System](https://m3.material.io/styles/motion/overview)
- [flutter_animate Package](https://pub.dev/packages/flutter_animate)
- [flutter_staggered_animations](https://pub.dev/packages/flutter_staggered_animations)

---

**Related Documentation**:

- [Architecture](./ARCHITECTURE.md)
- [Offline Support](./OFFLINE_SUPPORT.md)
- [Developer Guide](./DEVELOPER_GUIDE.md)

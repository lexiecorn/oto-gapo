# Firebase Performance Monitoring Usage Guide

## Overview

Firebase Performance Monitoring has been integrated into the OtoGapo app to track app performance, measure response times, and monitor custom operations across all flavors (DEV, STAGING, PROD).

## Features Implemented

### 1. Automatic Performance Tracking

- **App Start Time**: Automatic tracking of app initialization time
- **HTTP Requests**: All network requests via Dio are automatically tracked with:
  - Request/response times
  - Payload sizes
  - Status codes
  - Error rates

### 2. Custom Performance Traces

- Custom traces for critical operations:
  - Authentication flows (email/password, Google OAuth)
  - PocketBase initialization
  - Bootstrap operations
- Custom metrics and attributes for detailed analysis

### 3. Initialization Traces

- **app_start**: Total app startup time
- **firebase_init**: Firebase initialization time
- **perf_enable**: Performance Monitoring setup time
- **pocketbase_init**: PocketBase initialization time

### 4. Authentication Traces

- **email_signin**: Email/password authentication time
- **google_oauth_signin**: Google OAuth authentication time
- Error tracking for failed authentication attempts

## Usage Examples

### Using the Performance Helper

The `PerformanceHelper` utility class provides convenient methods for tracking performance:

```dart
import 'package:otogapo/utils/performance_helper.dart';

// Start a trace
final trace = PerformanceHelper.startTrace('my_operation');

try {
  // Perform your operation
  await doSomething();
  
  // Add custom attributes
  await PerformanceHelper.setAttribute(trace, 'result', 'success');
} catch (e) {
  // Track errors
  await PerformanceHelper.setAttribute(trace, 'error', e.toString());
} finally {
  // Always stop the trace
  await PerformanceHelper.stopTrace(trace);
}
```

### Tracking Operations with Helper Methods

The helper provides convenient wrapper methods:

```dart
// Simple operation tracking
await PerformanceHelper.trackOperation(
  'fetch_user_data',
  () => apiService.getUserData(),
);

// Operation with custom metrics
final posts = await PerformanceHelper.trackOperationWithMetrics(
  'fetch_posts',
  () => apiService.getPosts(),
  (result) => {'post_count': result.length},
);
```

### Adding Custom Metrics

Track specific metrics for analysis:

```dart
final trace = PerformanceHelper.startTrace('process_data');

// Record custom metrics
await PerformanceHelper.putMetric(trace, 'items_processed', itemCount);
await PerformanceHelper.putMetric(trace, 'cache_hits', cacheHitCount);

await PerformanceHelper.stopTrace(trace);
```

### HTTP Request Monitoring

HTTP requests are automatically tracked via the Dio interceptor:

```dart
import 'package:dio/dio.dart';

// The interceptor is already registered in bootstrap.dart
final dio = Dio(); // PerformanceInterceptor is added automatically

// All requests are tracked:
final response = await dio.get('/api/users');
// Automatically tracks: URL, method, response time, size, status code
```

## Configuration

### Flavor-Specific Configuration

Performance Monitoring is enabled in all flavors:

- **Development**: Full monitoring with debug logs
- **Staging**: Full monitoring with debug logs
- **Production**: Full monitoring with production-optimized settings

### Firebase Console Setup

1. Enable Performance Monitoring in Firebase Console
2. Configure performance alerts and notifications
3. Set up performance budgets for critical traces
4. Enable data collection according to privacy requirements

### Android Configuration

The following files have been updated for Android:

- `android/build.gradle.kts`: Added Performance Monitoring plugin
- `android/app/build.gradle.kts`: Enabled Firebase Perf plugin
- `pubspec.yaml`: Added `firebase_performance` dependency

### Initialization

Performance Monitoring is initialized in all main entry points:

```dart
// lib/main_development.dart, main_staging.dart, main_production.dart

import 'package:firebase_performance/firebase_performance.dart';
import 'package:otogapo/utils/performance_helper.dart';

// Start app initialization trace
final appStartTrace = PerformanceHelper.startTrace('app_start');

// Initialize Firebase
await Firebase.initializeApp(...);

// Enable Performance Monitoring
await PerformanceHelper.setPerformanceCollectionEnabled(true);

// Complete initialization trace
await PerformanceHelper.stopTrace(appStartTrace);
```

## Monitoring in Firebase Console

### Available Metrics

1. **App Startup**: Total time from app launch to first frame
2. **Network Performance**: All HTTP requests with timing and size data
3. **Custom Traces**: Manually instrumented operations
4. **Screen Rendering**: Automatic screen performance tracking

### Performance Budgets

Set up performance budgets in Firebase Console:

- App startup time < 3 seconds
- Authentication < 2 seconds
- Network requests < 1 second (P95)

### Alerts

Configure alerts for:

- Slow app starts
- Failed authentication attempts
- Slow network requests
- Custom trace performance degradation

## Best Practices

### 1. Trace Naming

Use descriptive, consistent names:

```dart
// Good
'user_login'
'fetch_posts'
'payment_processing'

// Bad
'trace1'
'temp_trace'
'debug'
```

### 2. Add Context with Attributes

Provide meaningful context for traces:

```dart
await PerformanceHelper.setAttribute(trace, 'user_type', 'premium');
await PerformanceHelper.setAttribute(trace, 'operation_type', 'bulk_update');
await PerformanceHelper.setAttribute(trace, 'device_type', 'android');
```

### 3. Track Errors

Always record error information:

```dart
try {
  await riskyOperation();
} catch (e) {
  await PerformanceHelper.setAttribute(trace, 'error', e.toString());
  await PerformanceHelper.setAttribute(trace, 'error_type', e.runtimeType.toString());
  rethrow;
}
```

### 4. Keep Traces Focused

Don't over-instrument:

```dart
// Good: Track major operations
final trace = PerformanceHelper.startTrace('fetch_and_process_data');

// Bad: Don't trace every tiny operation
final trace = PerformanceHelper.startTrace('calculate_sum');
```

### 5. Use Finally Blocks

Always stop traces in finally blocks:

```dart
final trace = PerformanceHelper.startTrace('my_operation');
try {
  await doWork();
} finally {
  await PerformanceHelper.stopTrace(trace);
}
```

## Privacy Considerations

- Performance data is anonymized by Firebase
- No PII (personally identifiable information) should be included in trace names
- User IDs can be added as attributes for correlation (optional)
- Collection can be disabled using `PerformanceHelper.setPerformanceCollectionEnabled(false)`

## Testing

### Development Testing

1. Check Firebase Console for trace data
2. Verify traces appear with proper timing
3. Test custom attributes and metrics
4. Verify HTTP request tracking

### Production Monitoring

1. Monitor Firebase Console for performance trends
2. Set up alerts for performance degradation
3. Review slow traces and optimize
4. Track performance budgets

## Troubleshooting

### Common Issues

1. **Traces not appearing in Firebase Console**
   - Ensure Firebase is properly initialized
   - Check that Performance Monitoring is enabled
   - Verify network connectivity
   - Wait 12-24 hours for data to appear (initial delay)

2. **Build errors related to Firebase Performance**
   - Ensure `firebase_performance` package is added to `pubspec.yaml`
   - Check that Firebase plugins are properly configured
   - Verify Android build configuration includes Performance plugin

3. **Interceptor not tracking requests**
   - Verify `PerformanceInterceptor` is registered in `bootstrap.dart`
   - Check that Dio client is created after interceptor registration
   - Ensure requests use the configured Dio instance

4. **Custom traces showing zero duration**
   - Ensure `stopTrace()` is called for every trace
   - Check that traces are not being stopped before work completes
   - Verify trace names are valid (no special characters)

### Debug Information

Enable debug logging by checking console output for Performance-related messages. All Performance operations are logged in debug mode:

```
Performance: Started tracking GET /api/users
Performance: Completed tracking GET /api/users (200)
```

## Files Modified

The following files were added or modified for Performance Monitoring integration:

### New Files

- `lib/utils/performance_helper.dart`: Helper utility for Performance operations
- `lib/services/performance_interceptor.dart`: Dio interceptor for HTTP tracking

### Modified Files

- `pubspec.yaml`: Added `firebase_performance` dependency
- `android/build.gradle.kts`: Added Performance Monitoring plugin
- `android/app/build.gradle.kts`: Enabled Firebase Perf plugin
- `lib/bootstrap.dart`: Added Performance interceptor and PocketBase trace
- `lib/main_development.dart`: Added Performance initialization and traces
- `lib/main_staging.dart`: Added Performance initialization and traces
- `lib/main_production.dart`: Added Performance initialization and traces
- `lib/app/modules/signin/bloc/signin_cubit.dart`: Added authentication traces

## Integration with Other Tools

### Crashlytics

Performance data complements Crashlytics by providing context for crashes:

- Slow operations might lead to timeouts and crashes
- Network errors tracked in Performance correlate with Crashlytics reports
- User sessions can be analyzed across both tools

### Analytics

Performance Monitoring integrates with Analytics:

- App startup performance affects user engagement
- Slow operations correlate with user drop-off rates
- Network performance impacts feature usage

## Performance Monitoring vs. Crashlytics

| Feature | Performance Monitoring | Crashlytics |
|---------|----------------------|-------------|
| **Purpose** | Track performance and timing | Track crashes and errors |
| **Automatic** | HTTP requests, app start | Crashes, exceptions |
| **Custom** | Traces, metrics, attributes | Logs, breadcrumbs, keys |
| **Data** | Timing, throughput, size | Stack traces, logs |
| **Use Case** | Optimize speed | Fix bugs |

Both tools work together to provide comprehensive app monitoring.

## Advanced Usage

### HTTP Request Custom Tracking

For non-Dio HTTP requests, manually track performance:

```dart
import 'package:firebase_performance/firebase_performance.dart';
import 'package:http/http.dart' as http;

final metric = PerformanceHelper.newHttpMetric(url, HttpMethod.Get);
await metric.start();

try {
  final response = await http.get(Uri.parse(url));
  await metric.setHttpResponseCode(response.statusCode);
  await metric.setResponsePayloadSize(response.bodyBytes.length);
} finally {
  await metric.stop();
}
```

### Correlating Traces

Link related traces with attributes:

```dart
// Parent operation
final parentTrace = PerformanceHelper.startTrace('fetch_user_dashboard');
await PerformanceHelper.setAttribute(parentTrace, 'user_id', userId);

// Child operations inherit context
final postsTrace = PerformanceHelper.startTrace('fetch_posts');
await PerformanceHelper.setAttribute(postsTrace, 'user_id', userId);
```

## Further Reading

- [Firebase Performance Monitoring Documentation](https://firebase.google.com/docs/perf-mon)
- [Crashlytics Usage Guide](CRASHLYTICS_USAGE.md)
- [API Documentation](API_DOCUMENTATION.md)
- [Developer Guide](DEVELOPER_GUIDE.md)


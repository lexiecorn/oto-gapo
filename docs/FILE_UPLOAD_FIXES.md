# File Upload Fixes Documentation

## Overview

This document details the comprehensive fixes implemented for file upload functionality in the OtoGapo application, specifically addressing the migration from Firebase Storage to PocketBase and resolving MultipartFile JSON serialization errors.

## Problem Summary

### Issues Identified

1. **Firebase Storage Dependency**: The app was still using Firebase Storage for file uploads despite migrating to PocketBase
2. **MultipartFile JSON Error**: `JsonUnsupportedObjectError` when trying to serialize MultipartFile objects
3. **Inconsistent File Handling**: Mixed usage of Firebase and PocketBase for file operations
4. **Authentication Issues**: Firebase authentication errors when uploading files

### Error Messages

```
E/StorageUtil(32269): error getting token java.util.concurrent.ExecutionException: com.google.firebase.internal.api.FirebaseNoSignedInUserException: Please sign in before trying to get a token.
E/StorageException(32269): Object does not exist at location. Code: -13010 HttpResult: 404
I/flutter (32269): PocketBaseService - Error type: JsonUnsupportedObjectError
I/flutter (32269): UserDetailPage - Error updating profile image: Converting object to an encodable object failed: Instance of 'MultipartFile'
```

## Solution Implementation

### 1. Complete Migration to PocketBase

#### Removed Firebase Storage Dependencies

**Files Modified:**

- `lib/app/pages/user_detail_page.dart`
- `lib/services/pocketbase_service.dart`

**Changes Made:**

- Removed `import 'package:firebase_storage/firebase_storage.dart';`
- Removed `_getDownloadUrlFromGsUri` method
- Updated all image loading logic to use PocketBase URLs

#### Updated File Upload Logic

**Before (Firebase Storage):**

```dart
// Old Firebase Storage approach
final ref = FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
final uploadTask = ref.putFile(file);
final downloadUrl = await uploadTask.then((task) => task.ref.getDownloadURL());
```

**After (PocketBase):**

```dart
// New PocketBase approach
final pocketBaseService = PocketBaseService();
final result = await pocketBaseService.updateUser(userId, {
  'profileImage': file,
  'updatedAt': DateTime.now().toIso8601String(),
});
```

### 2. MultipartFile JSON Serialization Fix

#### Problem Analysis

The `JsonUnsupportedObjectError` occurred because:

1. PocketBase client was trying to serialize MultipartFile objects as JSON
2. MultipartFile objects cannot be converted to JSON format
3. The PocketBase client's `update` method expected JSON-serializable data

#### Solution: Direct HTTP Requests

**Implementation:**

```dart
Future<RecordModel> _uploadUserFile(String userId, String fieldName, File file) async {
  try {
    // Read file bytes
    final fileBytes = await file.readAsBytes();

    // Create multipart request manually
    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse('${pb.baseUrl}/api/collections/users/records/$userId'),
    );

    // Add authorization header
    final token = pb.authStore.token;
    request.headers['Authorization'] = 'Bearer $token';

    // Add the file
    request.files.add(
      http.MultipartFile.fromBytes(
        fieldName,
        fileBytes,
        filename: file.path.split('/').last,
      ),
    );

    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      return RecordModel.fromJson(responseData);
    } else {
      throw Exception('File upload failed: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('PocketBaseService - Error uploading file for field $fieldName: $e');
    rethrow;
  }
}
```

### 3. Enhanced updateUser Method

#### File/Data Separation

The `updateUser` method now separates file uploads from regular data updates:

```dart
Future<RecordModel> updateUser(String userId, Map<String, dynamic> data) async {
  await _ensureAuthenticated();

  // Separate file uploads from regular data updates
  final fileFields = <String, File>{};
  final regularData = <String, dynamic>{};

  for (final entry in data.entries) {
    if (entry.value is File) {
      fileFields[entry.key] = entry.value as File;
    } else {
      regularData[entry.key] = entry.value;
    }
  }

  print('PocketBaseService - Regular data keys: ${regularData.keys.toList()}');
  print('PocketBaseService - File fields: ${fileFields.keys.toList()}');

  try {
    RecordModel result;

    // First update regular data if any
    if (regularData.isNotEmpty) {
      result = await pb.collection('users').update(userId, body: regularData);
      print('PocketBaseService - Regular data updated successfully');
    } else {
      result = await pb.collection('users').getOne(userId);
    }

    // Handle file uploads using direct file upload
    if (fileFields.isNotEmpty) {
      for (final entry in fileFields.entries) {
        final fieldName = entry.key;
        final file = entry.value;

        print('PocketBaseService - Uploading file for field: $fieldName');
        print('PocketBaseService - File path: ${file.path}');

        // Use direct HTTP upload for files
        result = await _uploadUserFile(userId, fieldName, file);

        print('PocketBaseService - File $fieldName uploaded successfully');
      }
    }

    print('PocketBaseService - User updated successfully: ${result.id}');
    return result;
  } catch (e) {
    print('PocketBaseService - Error updating user: $e');
    print('PocketBaseService - Error type: ${e.runtimeType}');
    rethrow;
  }
}
```

### 4. File URL Construction

#### PocketBase File URLs

All file URLs are now constructed using PocketBase's file serving endpoints:

```dart
String getPocketBaseImageUrl(String filename, String userId) {
  final pocketbaseUrl = FlavorConfig.instance.variables['pocketbaseUrl'] as String;
  return '$pocketbaseUrl/api/files/users/$userId/$filename';
}
```

#### Updated Image Loading

**Profile Images:**

```dart
// Check for profile image in multiple possible field names
String? profileImageValue;
if (_editedData['profileImage'] != null && _editedData['profileImage'].toString().isNotEmpty) {
  profileImageValue = _editedData['profileImage'].toString();
} else if (_editedData['profile_image'] != null && _editedData['profile_image'].toString().isNotEmpty) {
  profileImageValue = _editedData['profile_image'].toString();
}

if (profileImageValue != null) {
  if (profileImageValue.startsWith('http')) {
    // It's already a full URL
    _profileImageUrlFuture = Future.value(profileImageValue);
  } else {
    // It's a PocketBase filename, construct the URL
    final pocketbaseUrl = FlavorConfig.instance.variables['pocketbaseUrl'] as String;
    _profileImageUrlFuture = Future.value('$pocketbaseUrl/api/files/users/${_editedData['id']}/$profileImageValue');
  }
}
```

**Car Images:**

```dart
Future<String?> _loadMainCarImageFromStorage(String userId) async {
  // Check if user has car image data
  final carImageData = _editedData['carImagemain'] as String?;
  if (carImageData != null && carImageData.isNotEmpty) {
    final pocketbaseUrl = FlavorConfig.instance.variables['pocketbaseUrl'] as String;
    return '$pocketbaseUrl/api/files/users/$userId/$carImageData';
  }
  return null;
}
```

## Technical Details

### Dependencies Added

```yaml
dependencies:
  http: ^1.1.0 # For direct HTTP requests
```

### Imports Added

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
```

### Error Handling Improvements

1. **Comprehensive Logging**: Added detailed debug logging for all file operations
2. **Error Type Detection**: Specific handling for MultipartFile conversion issues
3. **Response Validation**: Proper HTTP status code checking
4. **File Size Logging**: Track file sizes for debugging

### Performance Optimizations

1. **Direct HTTP Requests**: Bypass PocketBase client JSON serialization
2. **File/Data Separation**: Process files and data separately for efficiency
3. **Authentication Caching**: Reuse authentication tokens
4. **Error Recovery**: Graceful handling of upload failures

## Testing and Validation

### Test Cases Covered

1. **Profile Image Upload**: Successfully uploads and displays profile images
2. **Car Image Upload**: Handles multiple car image uploads
3. **Error Scenarios**: Proper error handling for network issues
4. **Authentication**: Maintains PocketBase authentication throughout
5. **URL Construction**: Correctly constructs PocketBase file URLs

### Debug Logging

The implementation includes extensive debug logging:

```dart
print('PocketBaseService - Starting file upload for field: $fieldName');
print('PocketBaseService - File size: ${fileBytes.length} bytes');
print('PocketBaseService - Sending multipart request');
print('PocketBaseService - Response status: ${response.statusCode}');
print('PocketBaseService - Response body: ${response.body}');
```

## Benefits of the Solution

### 1. **Eliminated JSON Serialization Issues**

- No more `JsonUnsupportedObjectError`
- Files handled as binary data, not JSON
- Direct HTTP multipart requests

### 2. **Unified Backend Architecture**

- Single backend (PocketBase) for all operations
- Consistent authentication and data management
- Simplified maintenance and debugging

### 3. **Better Performance**

- Direct file uploads without JSON conversion overhead
- Optimized HTTP requests
- Reduced memory usage

### 4. **Enhanced Error Handling**

- Comprehensive error reporting
- Better debugging capabilities
- Graceful failure handling

### 5. **Cost Efficiency**

- No Firebase Storage costs
- Single backend infrastructure
- Reduced complexity

## Migration Checklist

- [x] Remove Firebase Storage dependencies
- [x] Update file upload logic to use PocketBase
- [x] Implement direct HTTP multipart requests
- [x] Update image URL construction
- [x] Add comprehensive error handling
- [x] Update documentation
- [x] Test all file upload scenarios
- [x] Verify authentication works correctly

## Future Considerations

### Potential Improvements

1. **File Compression**: Implement image compression before upload
2. **Progress Tracking**: Add upload progress indicators
3. **Batch Uploads**: Support multiple file uploads in single request
4. **File Validation**: Add file type and size validation
5. **Caching**: Implement local file caching for better performance

### Monitoring

1. **Upload Success Rates**: Track file upload success/failure rates
2. **Performance Metrics**: Monitor upload times and file sizes
3. **Error Tracking**: Log and analyze upload errors
4. **User Experience**: Monitor user satisfaction with file uploads

## Conclusion

The file upload fixes successfully resolve all identified issues:

1. ✅ **Firebase Storage Migration**: Complete migration to PocketBase
2. ✅ **MultipartFile JSON Error**: Resolved using direct HTTP requests
3. ✅ **Authentication Issues**: Proper PocketBase authentication
4. ✅ **File URL Construction**: Correct PocketBase file URLs
5. ✅ **Error Handling**: Comprehensive error reporting and debugging

The solution provides a robust, efficient, and maintainable file upload system that integrates seamlessly with the existing PocketBase backend architecture.

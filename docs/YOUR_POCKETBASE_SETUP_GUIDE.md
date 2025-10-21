# Your PocketBase Setup Guide for Vehicle Awards System

## Overview

This guide is specifically tailored for your PocketBase instance to add the Vehicle Awards system with enhanced vehicle specifications.

## Current Status

✅ **Vehicles Collection Exists** - Collection ID: `pbc_2329123692`
✅ **Users Collection Exists** - Collection ID: `pbc_1736455494`
✅ **Permissions Already Configured** - Your existing rules are perfect

## Step 1: Update Your Existing Vehicles Collection

### Add 7 New Fields to Your Vehicles Collection

You need to add these fields to your existing `vehicles` collection (ID: `pbc_2329123692`):

#### 1. Mileage Field

- **Field Name:** `mileage`
- **Type:** `Number`
- **Required:** No
- **Min Value:** 0
- **Description:** Vehicle mileage in kilometers

#### 2. Fuel Type Field

- **Field Name:** `fuelType`
- **Type:** `Text`
- **Required:** No
- **Description:** Petrol, Diesel, Electric, Hybrid

#### 3. Wheel Size Field

- **Field Name:** `wheelSize`
- **Type:** `Text`
- **Required:** No
- **Description:** e.g., "18-inch Alloy"

#### 4. Max Speed Field

- **Field Name:** `maxSpeed`
- **Type:** `Number`
- **Required:** No
- **Min Value:** 0
- **Description:** Maximum speed in km/h

#### 5. Engine Displacement Field

- **Field Name:** `engineDisplacement`
- **Type:** `Text`
- **Required:** No
- **Description:** e.g., "2.0L", "3.5L V6"

#### 6. Horsepower Field

- **Field Name:** `horsepower`
- **Type:** `Number`
- **Required:** No
- **Min Value:** 0
- **Description:** Engine power in HP

#### 7. Transmission Field

- **Field Name:** `transmission`
- **Type:** `Text`
- **Required:** No
- **Description:** Automatic, Manual, CVT, etc.

### How to Add Fields in PocketBase Admin

1. **Open PocketBase Admin**
2. **Go to Collections** → **vehicles**
3. **Click "Add new field"** for each field above
4. **Configure each field** with the settings listed above
5. **Save each field** before adding the next one

## Step 2: Create Vehicle Awards Collection

### Create New Collection

1. **Go to Collections** → **New Collection**
2. **Collection Name:** `vehicle_awards`
3. **Collection Type:** `base`

### Add Fields to Vehicle Awards Collection

Add these fields in order:

#### 1. Vehicle ID (Relation)

- **Field Name:** `vehicle_id`
- **Type:** `Relation`
- **Collection:** `vehicles` (your existing collection)
- **Max Select:** 1
- **Min Select:** 1
- **Required:** Yes

#### 2. Award Name

- **Field Name:** `award_name`
- **Type:** `Text`
- **Required:** Yes

#### 3. Event Name

- **Field Name:** `event_name`
- **Type:** `Text`
- **Required:** Yes

#### 4. Event Date

- **Field Name:** `event_date`
- **Type:** `Date`
- **Required:** Yes

#### 5. Category

- **Field Name:** `category`
- **Type:** `Text`
- **Required:** No

#### 6. Placement

- **Field Name:** `placement`
- **Type:** `Text`
- **Required:** No

#### 7. Description

- **Field Name:** `description`
- **Type:** `Text`
- **Required:** No

#### 8. Award Image

- **Field Name:** `award_image`
- **Type:** `File`
- **Max Select:** 1
- **Max Size:** 5MB
- **MIME Types:** image/png, image/jpeg, image/gif, image/webp
- **Required:** No

#### 9. Created By (Relation)

- **Field Name:** `created_by`
- **Type:** `Relation`
- **Collection:** `users` (your existing collection)
- **Max Select:** 1
- **Min Select:** 0
- **Required:** No

### Set Up Permissions for Vehicle Awards

Use these permission rules:

- **List Rule:** `@request.auth.id != ""`
- **View Rule:** `@request.auth.id != ""`
- **Create Rule:** `@request.auth.id != ""`
- **Update Rule:** `created_by = @request.auth.id || @request.auth.membership_type = 1 || @request.auth.membership_type = 2`
- **Delete Rule:** `created_by = @request.auth.id || @request.auth.membership_type = 1 || @request.auth.membership_type = 2`

## Step 3: Test the Setup

### Test Vehicles Collection Update

Create a test vehicle record with the new fields:

```json
{
  "make": "Toyota",
  "model": "Supra",
  "year": 2023,
  "type": "Sports Car",
  "color": "White",
  "plateNumber": "TEST-1234",
  "mileage": 15000,
  "fuelType": "Petrol",
  "wheelSize": "19-inch Alloy",
  "maxSpeed": 250,
  "engineDisplacement": "3.0L I6",
  "horsepower": 382,
  "transmission": "Automatic",
  "user": "your_user_id"
}
```

### Test Vehicle Awards Collection

Create a test award record:

```json
{
  "vehicle_id": "your_vehicle_id",
  "award_name": "Best Modified Car",
  "event_name": "Manila Auto Show 2025",
  "event_date": "2025-03-15",
  "category": "Modified",
  "placement": "1st Place",
  "description": "Won for outstanding modifications and performance",
  "created_by": "your_user_id"
}
```

## Step 4: Update Flutter App

### Regenerate Freezed Files

Run this command to update the generated files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Test the New UI

1. **Launch the Flutter app**
2. **Navigate to Profile page**
3. **Check the new dark-themed car widget**
4. **Verify specification cards display**
5. **Test awards section (will show "No awards yet" initially)**

## Step 5: Sample Data for Testing

### Sample Vehicle with Full Specifications

```json
{
  "make": "BMW",
  "model": "M3",
  "year": 2024,
  "type": "Sports Sedan",
  "color": "Alpine White",
  "plateNumber": "BMW-2024",
  "mileage": 5000,
  "fuelType": "Petrol",
  "wheelSize": "19-inch M Performance",
  "maxSpeed": 290,
  "engineDisplacement": "3.0L I6 Twin Turbo",
  "horsepower": 473,
  "transmission": "Automatic",
  "user": "user_id_here"
}
```

### Sample Awards

```json
[
  {
    "vehicle_id": "vehicle_id_here",
    "award_name": "Best Performance Car",
    "event_name": "Manila Auto Show 2024",
    "event_date": "2024-12-15",
    "category": "Performance",
    "placement": "1st Place",
    "description": "Awarded for exceptional performance and handling",
    "created_by": "user_id_here"
  },
  {
    "vehicle_id": "vehicle_id_here",
    "award_name": "People's Choice Award",
    "event_name": "Car Enthusiast Meet 2024",
    "event_date": "2024-11-20",
    "category": "Popular Vote",
    "placement": "Winner",
    "description": "Voted by the community as the most impressive car",
    "created_by": "user_id_here"
  }
]
```

## Expected Results

After completing this setup:

1. **Enhanced Car Profile** - Dark theme with hero images and spec cards
2. **Vehicle Specifications** - 7 new spec fields displayed elegantly
3. **Awards System** - Trophy display and management
4. **New Pages** - Car details, awards list, and add award forms
5. **Smooth Animations** - Staggered fade-ins and glowing effects

## Troubleshooting

### Common Issues

1. **Field Already Exists**

   - Skip fields that already exist
   - Check current schema before adding

2. **Permission Errors**

   - Verify you have admin access
   - Check collection permissions

3. **Flutter App Errors**
   - Run `dart run build_runner build --delete-conflicting-outputs`
   - Check for any linting errors

### Verification Commands

Check your collections via API:

```bash
# Check vehicles collection
curl -X GET "http://your-pocketbase-url/api/collections/vehicles" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"

# Check vehicle_awards collection
curl -X GET "http://your-pocketbase-url/api/collections/vehicle_awards" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

## Next Steps

1. **Complete the PocketBase setup** using this guide
2. **Test with sample data** to verify everything works
3. **Deploy the updated Flutter app**
4. **Train users** on the new features
5. **Enjoy the enhanced car profile experience!**

The new system will provide a premium automotive app experience with dark themes, comprehensive vehicle specifications, and a complete awards management system.

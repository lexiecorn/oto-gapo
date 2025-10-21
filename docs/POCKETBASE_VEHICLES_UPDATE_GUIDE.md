# PocketBase Vehicles Collection Update Guide

## Overview

This guide will help you add the new vehicle specification fields to your existing PocketBase vehicles collection without losing any existing data.

## Current Collection Status

Your existing vehicles collection has these fields:

- ✅ `id` (text, primary key)
- ✅ `color` (text)
- ✅ `make` (text)
- ✅ `model` (text)
- ✅ `plateNumber` (text)
- ✅ `type` (text)
- ✅ `photos` (file)
- ✅ `primaryPhoto` (file)
- ✅ `user` (relation to users)
- ✅ `year` (number)
- ✅ `created` (autodate)
- ✅ `updated` (autodate)

## New Fields to Add

You need to add these 7 new fields to your existing collection:

### 1. Mileage Field

- **Name:** `mileage`
- **Type:** `number`
- **Description:** Vehicle mileage in kilometers
- **Required:** No
- **Min Value:** 0

### 2. Fuel Type Field

- **Name:** `fuelType`
- **Type:** `text`
- **Description:** Fuel type (Petrol, Diesel, Electric, Hybrid)
- **Required:** No

### 3. Wheel Size Field

- **Name:** `wheelSize`
- **Type:** `text`
- **Description:** Wheel and tire specifications
- **Required:** No

### 4. Max Speed Field

- **Name:** `maxSpeed`
- **Type:** `number`
- **Description:** Maximum speed in km/h
- **Required:** No
- **Min Value:** 0

### 5. Engine Displacement Field

- **Name:** `engineDisplacement`
- **Type:** `text`
- **Description:** Engine displacement (e.g., "2.0L", "3.5L V6")
- **Required:** No

### 6. Horsepower Field

- **Name:** `horsepower`
- **Type:** `number`
- **Description:** Engine power in HP
- **Required:** No
- **Min Value:** 0

### 7. Transmission Field

- **Name:** `transmission`
- **Type:** `text`
- **Description:** Transmission type (Automatic, Manual, CVT, etc.)
- **Required:** No

## Step-by-Step Update Process

### Step 1: Access PocketBase Admin

1. Open your PocketBase admin interface
2. Navigate to **Collections** section
3. Find your **vehicles** collection
4. Click on it to open the collection settings

### Step 2: Add New Fields

For each new field, follow these steps:

#### Add Mileage Field

1. Click **"Add new field"**
2. **Field name:** `mileage`
3. **Field type:** `Number`
4. **Required:** No
5. **Min value:** 0
6. Click **"Save"**

#### Add Fuel Type Field

1. Click **"Add new field"**
2. **Field name:** `fuelType`
3. **Field type:** `Text`
4. **Required:** No
5. Click **"Save"**

#### Add Wheel Size Field

1. Click **"Add new field"**
2. **Field name:** `wheelSize`
3. **Field type:** `Text`
4. **Required:** No
5. Click **"Save"**

#### Add Max Speed Field

1. Click **"Add new field"**
2. **Field name:** `maxSpeed`
3. **Field type:** `Number`
4. **Required:** No
5. **Min value:** 0
6. Click **"Save"**

#### Add Engine Displacement Field

1. Click **"Add new field"**
2. **Field name:** `engineDisplacement`
3. **Field type:** `Text`
4. **Required:** No
5. Click **"Save"**

#### Add Horsepower Field

1. Click **"Add new field"**
2. **Field name:** `horsepower`
3. **Field type:** `Number`
4. **Required:** No
5. **Min value:** 0
6. Click **"Save"**

#### Add Transmission Field

1. Click **"Add new field"**
2. **Field name:** `transmission`
3. **Field type:** `Text`
4. **Required:** No
5. Click **"Save"**

### Step 3: Add Indexes (Optional but Recommended)

1. Go to the **Indexes** tab in your collection
2. Add these indexes for better performance:

```sql
CREATE INDEX idx_vehicles_user ON vehicles (user);
CREATE INDEX idx_vehicles_make ON vehicles (make);
CREATE INDEX idx_vehicles_plateNumber ON vehicles (plateNumber);
```

### Step 4: Verify the Update

1. Check that all 7 new fields are visible in your collection schema
2. Test creating a new vehicle record with the new fields
3. Verify existing records still work (they should have null values for new fields)

## Expected Final Schema

After the update, your vehicles collection should have these fields:

```
✅ id (text, primary key)
✅ color (text)
✅ make (text)
✅ model (text)
✅ plateNumber (text)
✅ type (text)
✅ photos (file)
✅ primaryPhoto (file)
✅ user (relation to users)
✅ year (number)
✅ created (autodate)
✅ updated (autodate)
🆕 mileage (number)
🆕 fuelType (text)
🆕 wheelSize (text)
🆕 maxSpeed (number)
🆕 engineDisplacement (text)
🆕 horsepower (number)
🆕 transmission (text)
```

## Testing the Update

### 1. Test New Field Creation

Try creating a vehicle record with the new fields:

```json
{
  "make": "Toyota",
  "model": "Supra",
  "year": 2023,
  "type": "Sports Car",
  "color": "White",
  "plateNumber": "ABC-1234",
  "mileage": 15000,
  "fuelType": "Petrol",
  "wheelSize": "19-inch Alloy",
  "maxSpeed": 250,
  "engineDisplacement": "3.0L I6",
  "horsepower": 382,
  "transmission": "Automatic",
  "user": "user_record_id"
}
```

### 2. Test Existing Records

- Existing vehicle records should still be accessible
- New fields will be null/empty for existing records
- No data should be lost

### 3. Test Flutter App

- The updated Flutter app should now display the new specification fields
- The dark-themed car widget should show the new specs
- Awards system should work with the new vehicle structure

## Troubleshooting

### Common Issues

1. **Field Already Exists Error**

   - If a field already exists, skip it and continue with the others
   - Check the current schema to see which fields are missing

2. **Permission Errors**

   - Ensure you have admin access to modify collections
   - Check that the collection is not locked

3. **Data Type Mismatch**
   - Make sure to use the correct data types (Number vs Text)
   - Check that min/max values are appropriate

### Verification Commands

You can verify the update by checking the collection schema:

```bash
# Check collection schema via PocketBase API
curl -X GET "http://your-pocketbase-url/api/collections/vehicles" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

## Next Steps

After successfully updating the vehicles collection:

1. **Create the vehicle_awards collection** using the provided schema
2. **Test the Flutter app** with the new fields
3. **Update existing vehicle records** with specification data
4. **Train users** on the new features

## Support

If you encounter any issues during the update:

1. **Backup your data** before making changes
2. **Test in a development environment** first
3. **Check PocketBase logs** for any errors
4. **Verify field names** match exactly (case-sensitive)

The update should be seamless and won't affect existing functionality. Your current vehicle records will continue to work, and the new fields will be available for future use.

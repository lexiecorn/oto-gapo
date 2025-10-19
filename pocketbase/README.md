# PocketBase Configuration Files

This directory contains PocketBase schema and sample data files for the OtoGapo application.

## Files

### Schema Files

- **`pocketbase_users_schema.json`** - User collection schema
- **`pocketbase_announcements_schema.json`** - Announcements collection schema
- **`pocketbase_app_data_schema.json`** - Application data collection schema
- **`pocketbase_collections_import.json`** - Complete collection import file

### Sample Data Files

- **`pocketbase_users_sample_data.json`** - Sample user data
- **`pocketbase_sample_data.json`** - General sample data
- **`pocketbase_users_corrected.json`** - Corrected user data
- **`pocketbase_announcements_corrected.json`** - Corrected announcements data
- **`pocketbase_app_data_corrected.json`** - Corrected app data

## Usage

### Importing Collections

1. Open your PocketBase admin panel (usually http://localhost:8090/\_/)
2. Navigate to **Settings** > **Import collections**
3. Upload `pocketbase_collections_import.json`
4. Click **Import** to create all collections

### Importing Sample Data

After importing collections, you can import sample data:

1. Navigate to the specific collection in PocketBase admin
2. Click **Import** in the collection view
3. Upload the corresponding sample data JSON file

## Documentation

For more details on PocketBase setup and configuration, see:

- [docs/POCKETBASE_ATTENDANCE_SETUP.md](../docs/POCKETBASE_ATTENDANCE_SETUP.md)
- [docs/POCKETBASE_PERMISSIONS_SETUP.md](../docs/POCKETBASE_PERMISSIONS_SETUP.md)
- [docs/API_DOCUMENTATION.md](../docs/API_DOCUMENTATION.md)

## Collections Overview

The OtoGapo application uses the following PocketBase collections:

- **users** - Member information and profiles
- **monthly_dues** - Payment tracking (legacy)
- **payment_transactions** - Modern payment management
- **gallery_images** - Homepage carousel images
- **Announcements** - Association announcements
- **app_data** - Application configuration
- **meetings** - Meeting schedules
- **attendance** - Attendance records
- **attendance_summary** - User attendance statistics

## Notes

- Always backup your PocketBase data before importing schemas or data
- The sample data is for testing purposes only
- Update the schema files when making collection changes in production

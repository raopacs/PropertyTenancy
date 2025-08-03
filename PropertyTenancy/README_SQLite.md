# SQLite Database Implementation for AddressModel

This document explains how to use the SQLite database functionality implemented for the `AddressModel` in the PropertyTenancy app.

## Overview

The implementation replaces SwiftData with SQLite using the built-in SQLite3 framework for better compatibility and control over data persistence.

## Components

### 1. AddressModel (`PropertyTenancy/Model/AddressModel.swift`)
- Updated to work with SQLite instead of SwiftData
- Added `id` property for database primary key
- Includes SQLite table definition and schema

### 2. DatabaseManager (`PropertyTenancy/Model/DatabaseManager.swift`)
- Singleton class for managing SQLite database operations
- Handles CRUD operations for AddressModel
- Automatically creates database and tables on initialization

### 3. AddressView (`PropertyTenancy/Components/AddressView.swift`)
- Updated to save addresses to SQLite database
- Shows success/error alerts after save operations
- Supports both creating new addresses and updating existing ones

### 4. AddressListView (`PropertyTenancy/Components/AddressListView.swift`)
- Displays all saved addresses from the database
- Supports deleting addresses
- Shows loading states and empty states

### 5. AddressExampleView (`PropertyTenancy/Components/AddressExampleView.swift`)
- Example view demonstrating the complete address management workflow
- Shows how to integrate all components together

## Usage Examples

### Saving an Address
```swift
let address = AddressModel(
    title: "Home",
    line1: "123 Main Street",
    line2: "Apt 4B",
    city: "New York",
    state: "NY",
    pinCode: "10001"
)

do {
    let savedId = try DatabaseManager.shared.saveAddress(address)
    print("Address saved with ID: \(savedId)")
} catch {
    print("Error saving address: \(error)")
}
```

### Loading All Addresses
```swift
do {
    let addresses = try DatabaseManager.shared.getAllAddresses()
    for address in addresses {
        print("Address: \(address.title) - \(address.line1)")
    }
} catch {
    print("Error loading addresses: \(error)")
}
```

### Updating an Address
```swift
var address = AddressModel(id: 1, title: "Updated Home", line1: "456 Oak Street")
do {
    try DatabaseManager.shared.updateAddress(address)
    print("Address updated successfully")
} catch {
    print("Error updating address: \(error)")
}
```

### Deleting an Address
```swift
do {
    try DatabaseManager.shared.deleteAddress(id: 1)
    print("Address deleted successfully")
} catch {
    print("Error deleting address: \(error)")
}
```

## Database Schema

The `addresses` table has the following structure:

```sql
CREATE TABLE addresses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    line1 TEXT,
    line2 TEXT,
    city TEXT,
    state TEXT,
    pinCode TEXT
);
```

## Integration with SwiftUI Views

### Using AddressView
```swift
AddressView(address: AddressModel()) {
    // Callback when save is successful
    print("Address saved!")
}
```

### Using AddressListView
```swift
AddressListView()
    .navigationTitle("My Addresses")
```

### Using AddressExampleView
```swift
AddressExampleView()
    .navigationTitle("Address Manager")
```

## Error Handling

The implementation includes comprehensive error handling:

- `DatabaseError.connectionFailed`: Database connection issues
- `DatabaseError.invalidId`: Invalid ID for update/delete operations
- `DatabaseError.saveFailed`: Save operation failures
- `DatabaseError.updateFailed`: Update operation failures
- `DatabaseError.deleteFailed`: Delete operation failures
- `DatabaseError.fetchFailed`: Fetch operation failures

## Dependencies

The implementation uses the built-in SQLite3 framework, which is linked in `Package.swift`:

```swift
linkerSettings: [
    .linkedFramework("sqlite3")
]
```

## Migration from SwiftData

If you're migrating from SwiftData:

1. Remove `@Model` and `@available(iOS 17.0, *)` annotations
2. Add `id` property to your model
3. Replace `@Bindable` with `@State` in SwiftUI views
4. Remove SwiftData-specific imports and dependencies
5. Use `DatabaseManager.shared` for all database operations

## Next Steps

To extend this implementation:

1. Add similar SQLite support for `TenancyModel`
2. Implement relationships between addresses and tenancies
3. Add search and filtering capabilities
4. Implement data export/import functionality
5. Add data validation and constraints 
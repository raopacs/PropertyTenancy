import Foundation
import SQLite3

@available(iOS 17.0, *)
public class SQLiteTest {
    
    public static func testDatabase() {
        print("Testing SQLite database functionality...")
        
        // Test saving an address
        let address = AddressModel(
            title: "Test Home",
            line1: "123 Test Street",
            line2: "Apt 1",
            city: "Test City",
            state: "TS",
            pinCode: "12345"
        )
        
        do {
            let savedId = try DatabaseManager.shared.saveAddress(address)
            print("✅ Address saved successfully with ID: \(savedId)")
            
            // Test loading all addresses
            let addresses = try DatabaseManager.shared.getAllAddresses()
            print("✅ Loaded \(addresses.count) addresses from database")
            
            // Test updating an address
            address.title = "Updated Test Home"
            try DatabaseManager.shared.updateAddress(address)
            print("✅ Address updated successfully")
            
            // Test getting a specific address
            if let loadedAddress = try DatabaseManager.shared.getAddress(id: savedId) {
                print("✅ Retrieved address: \(loadedAddress.title)")
            }
            
            // Test deleting an address
            try DatabaseManager.shared.deleteAddress(id: savedId)
            print("✅ Address deleted successfully")
            
            let finalAddresses = try DatabaseManager.shared.getAllAddresses()
            print("✅ Final address count: \(finalAddresses.count)")
            
        } catch {
            print("❌ Database test failed: \(error)")
        }
    }
} 
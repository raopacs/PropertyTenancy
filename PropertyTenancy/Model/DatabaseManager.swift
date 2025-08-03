import Foundation
import SQLite3

public class DatabaseManager {
    private var db: OpaquePointer?
    private let dbPath: String
    
    public static let shared = DatabaseManager()
    
    private init() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        dbPath = "\(documentsPath)/PropertyTenancy.sqlite3"
        
        setupDatabase()
    }
    
    private func setupDatabase() {
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            createTables()
        } else {
            print("Error opening database")
        }
    }
    
    private func createTables() {
        let createTableSQL = """
            CREATE TABLE IF NOT EXISTS addresses (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT,
                line1 TEXT,
                line2 TEXT,
                city TEXT,
                state TEXT,
                pinCode TEXT
            );
        """
        
        if sqlite3_exec(db, createTableSQL, nil, nil, nil) != SQLITE_OK {
            print("Error creating table")
        }
    }
    
    // MARK: - Address Operations
    
    public func saveAddress(_ address: AddressModel) throws -> Int64 {
        let insertSQL = """
            INSERT INTO addresses (title, line1, line2, city, state, pinCode)
            VALUES (?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (address.title as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (address.line1 as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (address.line2 as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (address.city as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 5, (address.state as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 6, (address.pinCode as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                let id = sqlite3_last_insert_rowid(db)
                address.id = id
                sqlite3_finalize(statement)
                return id
            }
        }
        
        sqlite3_finalize(statement)
        throw DatabaseError.saveFailed
    }
    
    public func updateAddress(_ address: AddressModel) throws {
        guard let id = address.id else {
            throw DatabaseError.invalidId
        }
        
        let updateSQL = """
            UPDATE addresses 
            SET title = ?, line1 = ?, line2 = ?, city = ?, state = ?, pinCode = ?
            WHERE id = ?;
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (address.title as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (address.line1 as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (address.line2 as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (address.city as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 5, (address.state as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 6, (address.pinCode as NSString).utf8String, -1, nil)
            sqlite3_bind_int64(statement, 7, id)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                throw DatabaseError.updateFailed
            }
        }
        
        sqlite3_finalize(statement)
    }
    
    public func deleteAddress(id: Int64) throws {
        let deleteSQL = "DELETE FROM addresses WHERE id = ?;"
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int64(statement, 1, id)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                throw DatabaseError.deleteFailed
            }
        }
        
        sqlite3_finalize(statement)
    }
    
    public func getAllAddresses() throws -> [AddressModel] {
        let querySQL = "SELECT id, title, line1, line2, city, state, pinCode FROM addresses;"
        
        var statement: OpaquePointer?
        var addresses: [AddressModel] = []
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int64(statement, 0)
                let title = String(cString: sqlite3_column_text(statement, 1))
                let line1 = String(cString: sqlite3_column_text(statement, 2))
                let line2 = String(cString: sqlite3_column_text(statement, 3))
                let city = String(cString: sqlite3_column_text(statement, 4))
                let state = String(cString: sqlite3_column_text(statement, 5))
                let pinCode = String(cString: sqlite3_column_text(statement, 6))
                
                let address = AddressModel(
                    id: id,
                    title: title,
                    line1: line1,
                    line2: line2,
                    city: city,
                    state: state,
                    pinCode: pinCode
                )
                addresses.append(address)
            }
        }
        
        sqlite3_finalize(statement)
        return addresses
    }
    
    public func getAddress(id: Int64) throws -> AddressModel? {
        let querySQL = "SELECT id, title, line1, line2, city, state, pinCode FROM addresses WHERE id = ?;"
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int64(statement, 1, id)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int64(statement, 0)
                let title = String(cString: sqlite3_column_text(statement, 1))
                let line1 = String(cString: sqlite3_column_text(statement, 2))
                let line2 = String(cString: sqlite3_column_text(statement, 3))
                let city = String(cString: sqlite3_column_text(statement, 4))
                let state = String(cString: sqlite3_column_text(statement, 5))
                let pinCode = String(cString: sqlite3_column_text(statement, 6))
                
                sqlite3_finalize(statement)
                return AddressModel(
                    id: id,
                    title: title,
                    line1: line1,
                    line2: line2,
                    city: city,
                    state: state,
                    pinCode: pinCode
                )
            }
        }
        
        sqlite3_finalize(statement)
        return nil
    }
    
    deinit {
        sqlite3_close(db)
    }
}

// MARK: - Database Errors
public enum DatabaseError: Error {
    case connectionFailed
    case invalidId
    case saveFailed
    case updateFailed
    case deleteFailed
    case fetchFailed
} 
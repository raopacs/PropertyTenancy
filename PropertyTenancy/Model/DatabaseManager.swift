import Foundation
import SQLite3

public class DatabaseManager {
    private var db: OpaquePointer?
    private var dbPath: String
    
    public static let shared = DatabaseManager()
    
    private init() {
        let customDocumentsPath = Settings.shared.databasePath
        
        // Create directory if it doesn't exist
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: customDocumentsPath) {
            do {
                try fileManager.createDirectory(atPath: customDocumentsPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating directory: \(error)")
            }
        }
        
        dbPath = "\(customDocumentsPath)/PropertyTenancy.sqlite3"
        
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
        let createAddressTableSQL = """
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
        
        let createTenancyTableSQL = """
            CREATE TABLE IF NOT EXISTS tenancies (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                contact TEXT,
                addressId INTEGER,
                leaseStartDate TEXT,
                leaseAgreementSigned INTEGER,
                advanceAmount REAL,
                agreedRent REAL,
                monthlyDueDate INTEGER,
                agreementSignedDate TEXT,
                comments TEXT,
                FOREIGN KEY (addressId) REFERENCES addresses (id)
            );
        """
        
        if sqlite3_exec(db, createAddressTableSQL, nil, nil, nil) != SQLITE_OK {
            print("Error creating addresses table")
        }
        
        if sqlite3_exec(db, createTenancyTableSQL, nil, nil, nil) != SQLITE_OK {
            print("Error creating tenancies table")
        }

        let createRentPaymentsTableSQL = """
            CREATE TABLE IF NOT EXISTS rent_payments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                tenancyId INTEGER NOT NULL,
                amount REAL NOT NULL,
                paidOn TEXT NOT NULL,
                notes TEXT,
                FOREIGN KEY (tenancyId) REFERENCES tenancies (id)
            );
        """

        if sqlite3_exec(db, createRentPaymentsTableSQL, nil, nil, nil) != SQLITE_OK {
            print("Error creating rent_payments table")
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
    
    // MARK: - Tenancy Operations
    
    public func saveTenancy(_ tenancy: TenancyModel) throws -> Int64 {
        let insertSQL = """
            INSERT INTO tenancies (name, contact, addressId, leaseStartDate, leaseAgreementSigned, advanceAmount, agreedRent, monthlyDueDate, agreementSignedDate, comments)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (tenancy.name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (tenancy.contact as NSString).utf8String, -1, nil)
            sqlite3_bind_int64(statement, 3, tenancy.address?.id ?? 0)
            sqlite3_bind_text(statement, 4, (formatDate(tenancy.leaseStartDate) as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 5, tenancy.leaseAgreementSigned ? 1 : 0)
            sqlite3_bind_double(statement, 6, tenancy.advanceAmount)
            sqlite3_bind_double(statement, 7, tenancy.agreedRent)
            sqlite3_bind_int(statement, 8, Int32(tenancy.monthlyDueDate))
            sqlite3_bind_text(statement, 9, (formatDate(tenancy.agreementSignedDate) as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 10, (tenancy.comments as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                let id = sqlite3_last_insert_rowid(db)
                tenancy.id = id
                sqlite3_finalize(statement)
                return id
            }
        }
        
        sqlite3_finalize(statement)
        throw DatabaseError.saveFailed
    }
    
    public func updateTenancy(_ tenancy: TenancyModel) throws {
        guard let id = tenancy.id else {
            throw DatabaseError.invalidId
        }
        
        let updateSQL = """
            UPDATE tenancies 
            SET name = ?, contact = ?, addressId = ?, leaseStartDate = ?, leaseAgreementSigned = ?, advanceAmount = ?, agreedRent = ?, monthlyDueDate = ?, agreementSignedDate = ?, comments = ?
            WHERE id = ?;
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (tenancy.name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (tenancy.contact as NSString).utf8String, -1, nil)
            sqlite3_bind_int64(statement, 3, tenancy.address?.id ?? 0)
            sqlite3_bind_text(statement, 4, (formatDate(tenancy.leaseStartDate) as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 5, tenancy.leaseAgreementSigned ? 1 : 0)
            sqlite3_bind_double(statement, 6, tenancy.advanceAmount)
            sqlite3_bind_double(statement, 7, tenancy.agreedRent)
            sqlite3_bind_int(statement, 8, Int32(tenancy.monthlyDueDate))
            sqlite3_bind_text(statement, 9, (formatDate(tenancy.agreementSignedDate) as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 10, (tenancy.comments as NSString).utf8String, -1, nil)
            sqlite3_bind_int64(statement, 11, id)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                throw DatabaseError.updateFailed
            }
        }
        
        sqlite3_finalize(statement)
    }
    
    public func deleteTenancy(id: Int64) throws {
        let deleteSQL = "DELETE FROM tenancies WHERE id = ?;"
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int64(statement, 1, id)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                throw DatabaseError.deleteFailed
            }
        }
        
        sqlite3_finalize(statement)
    }
    
    public func getAllTenancies() throws -> [TenancyModel] {
        let querySQL = """
            SELECT t.id, t.name, t.contact, t.addressId, t.leaseStartDate, t.leaseAgreementSigned, t.advanceAmount, t.agreedRent, t.monthlyDueDate, t.agreementSignedDate, t.comments,
                   a.id as address_id, a.title, a.line1, a.line2, a.city, a.state, a.pinCode
            FROM tenancies t
            LEFT JOIN addresses a ON t.addressId = a.id;
        """
        
        var statement: OpaquePointer?
        var tenancies: [TenancyModel] = []
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int64(statement, 0)
                let name = String(cString: sqlite3_column_text(statement, 1))
                let contact = String(cString: sqlite3_column_text(statement, 2))
                let addressId = sqlite3_column_int64(statement, 3)
                let leaseStartDate = String(cString: sqlite3_column_text(statement, 4))
                let leaseAgreementSigned = sqlite3_column_int(statement, 5) == 1
                let advanceAmount = sqlite3_column_double(statement, 6)
                let agreedRent = sqlite3_column_double(statement, 7)
                let monthlyDueDate = Int(sqlite3_column_int(statement, 8))
                let agreementSignedDate = String(cString: sqlite3_column_text(statement, 9))
                let comments = String(cString: sqlite3_column_text(statement, 10))
                
                // Create address if addressId exists
                var address: AddressModel?
                if addressId > 0 {
                    let addressId = sqlite3_column_int64(statement, 11)
                    let title = String(cString: sqlite3_column_text(statement, 12))
                    let line1 = String(cString: sqlite3_column_text(statement, 13))
                    let line2 = String(cString: sqlite3_column_text(statement, 14))
                    let city = String(cString: sqlite3_column_text(statement, 15))
                    let state = String(cString: sqlite3_column_text(statement, 16))
                    let pinCode = String(cString: sqlite3_column_text(statement, 17))
                    
                    address = AddressModel(
                        id: addressId,
                        title: title,
                        line1: line1,
                        line2: line2,
                        city: city,
                        state: state,
                        pinCode: pinCode
                    )
                }
                
                let tenancy = TenancyModel(
                    id: id,
                    name: name,
                    contact: contact,
                    address: address,
                    leaseStartDate: parseDate(leaseStartDate),
                    leaseAgreementSigned: leaseAgreementSigned,
                    advanceAmount: advanceAmount,
                    agreedRent: agreedRent,
                    monthlyDueDate: monthlyDueDate,
                    agreementSignedDate: parseDate(agreementSignedDate),
                    comments: comments
                )
                tenancies.append(tenancy)
            }
        }
        
        sqlite3_finalize(statement)
        return tenancies
    }
    
    public func getTenancy(id: Int64) throws -> TenancyModel? {
        let querySQL = """
            SELECT t.id, t.name, t.contact, t.addressId, t.leaseStartDate, t.leaseAgreementSigned, t.advanceAmount, t.agreedRent, t.monthlyDueDate, t.agreementSignedDate, t.comments,
                   a.id as address_id, a.title, a.line1, a.line2, a.city, a.state, a.pinCode
            FROM tenancies t
            LEFT JOIN addresses a ON t.addressId = a.id
            WHERE t.id = ?;
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int64(statement, 1, id)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int64(statement, 0)
                let name = String(cString: sqlite3_column_text(statement, 1))
                let contact = String(cString: sqlite3_column_text(statement, 2))
                let addressId = sqlite3_column_int64(statement, 3)
                let leaseStartDate = String(cString: sqlite3_column_text(statement, 4))
                let leaseAgreementSigned = sqlite3_column_int(statement, 5) == 1
                let advanceAmount = sqlite3_column_double(statement, 6)
                let agreedRent = sqlite3_column_double(statement, 7)
                let monthlyDueDate = Int(sqlite3_column_int(statement, 8))
                let agreementSignedDate = String(cString: sqlite3_column_text(statement, 9))
                let comments = String(cString: sqlite3_column_text(statement, 10))
                
                // Create address if addressId exists
                var address: AddressModel?
                if addressId > 0 {
                    let addressId = sqlite3_column_int64(statement, 11)
                    let title = String(cString: sqlite3_column_text(statement, 12))
                    let line1 = String(cString: sqlite3_column_text(statement, 13))
                    let line2 = String(cString: sqlite3_column_text(statement, 14))
                    let city = String(cString: sqlite3_column_text(statement, 15))
                    let state = String(cString: sqlite3_column_text(statement, 16))
                    let pinCode = String(cString: sqlite3_column_text(statement, 17))
                    
                    address = AddressModel(
                        id: addressId,
                        title: title,
                        line1: line1,
                        line2: line2,
                        city: city,
                        state: state,
                        pinCode: pinCode
                    )
                }
                
                sqlite3_finalize(statement)
                return TenancyModel(
                    id: id,
                    name: name,
                    contact: contact,
                    address: address,
                    leaseStartDate: parseDate(leaseStartDate),
                    leaseAgreementSigned: leaseAgreementSigned,
                    advanceAmount: advanceAmount,
                    agreedRent: agreedRent,
                    monthlyDueDate: monthlyDueDate,
                    agreementSignedDate: parseDate(agreementSignedDate),
                    comments: comments
                )
            }
        }
        
        sqlite3_finalize(statement)
        return nil
    }

    // MARK: - Rent Payment Operations

    @available(iOS 17.0, *)
    public func saveRentPayment(_ payment: RentPaymentModel) throws -> Int64 {
        let insertSQL = """
            INSERT INTO rent_payments (tenancyId, amount, paidOn, notes)
            VALUES (?, ?, ?, ?);
        """

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int64(statement, 1, payment.tenancyId)
            sqlite3_bind_double(statement, 2, payment.amount)
            sqlite3_bind_text(statement, 3, (formatDate(payment.paidOn) as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (payment.notes as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) == SQLITE_DONE {
                let id = sqlite3_last_insert_rowid(db)
                payment.id = id
                sqlite3_finalize(statement)
                return id
            }
        }

        sqlite3_finalize(statement)
        throw DatabaseError.saveFailed
    }

    @available(iOS 17.0, *)
    public func getLatestRentPayment(forTenancyId tenancyId: Int64) throws -> RentPaymentModel? {
        let querySQL = """
            SELECT id, tenancyId, amount, paidOn, notes
            FROM rent_payments
            WHERE tenancyId = ?
            ORDER BY datetime(paidOn) DESC, id DESC
            LIMIT 1;
        """

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int64(statement, 1, tenancyId)

            if sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int64(statement, 0)
                let tId = sqlite3_column_int64(statement, 1)
                let amount = sqlite3_column_double(statement, 2)
                let paidOn = String(cString: sqlite3_column_text(statement, 3))
                let notes = String(cString: sqlite3_column_text(statement, 4))

                sqlite3_finalize(statement)
                return RentPaymentModel(
                    id: id,
                    tenancyId: tId,
                    amount: amount,
                    paidOn: parseDate(paidOn),
                    notes: notes
                )
            }
        }

        sqlite3_finalize(statement)
        return nil
    }

    @available(iOS 17.0, *)
    public func getAllRentPayments() throws -> [RentPaymentModel] {
        let querySQL = """
            SELECT id, tenancyId, amount, paidOn, notes
            FROM rent_payments
            ORDER BY datetime(paidOn) DESC, id DESC;
        """

        var statement: OpaquePointer?
        var payments: [RentPaymentModel] = []

        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int64(statement, 0)
                let tenancyId = sqlite3_column_int64(statement, 1)
                let amount = sqlite3_column_double(statement, 2)
                let paidOn = String(cString: sqlite3_column_text(statement, 3))
                let notes = String(cString: sqlite3_column_text(statement, 4))

                let payment = RentPaymentModel(
                    id: id,
                    tenancyId: tenancyId,
                    amount: amount,
                    paidOn: parseDate(paidOn),
                    notes: notes
                )
                payments.append(payment)
            }
        }

        sqlite3_finalize(statement)
        return payments
    }

    @available(iOS 17.0, *)
    public func getRentPayments(forTenancyId tenancyId: Int64) throws -> [RentPaymentModel] {
        let querySQL = """
            SELECT id, tenancyId, amount, paidOn, notes
            FROM rent_payments
            WHERE tenancyId = ?
            ORDER BY datetime(paidOn) DESC, id DESC;
        """

        var statement: OpaquePointer?
        var payments: [RentPaymentModel] = []

        if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int64(statement, 1, tenancyId)
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int64(statement, 0)
                let tId = sqlite3_column_int64(statement, 1)
                let amount = sqlite3_column_double(statement, 2)
                let paidOn = String(cString: sqlite3_column_text(statement, 3))
                let notes = String(cString: sqlite3_column_text(statement, 4))

                let payment = RentPaymentModel(
                    id: id,
                    tenancyId: tId,
                    amount: amount,
                    paidOn: parseDate(paidOn),
                    notes: notes
                )
                payments.append(payment)
            }
        }

        sqlite3_finalize(statement)
        return payments
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    private func parseDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: dateString) ?? Date()
    }
    
    public func reinitializeDatabase() {
        // Close existing connection
        sqlite3_close(db)
        
        // Reinitialize with new path
        let customDocumentsPath = Settings.shared.databasePath
        
        // Create directory if it doesn't exist
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: customDocumentsPath) {
            do {
                try fileManager.createDirectory(atPath: customDocumentsPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating directory: \(error)")
            }
        }
        
        dbPath = "\(customDocumentsPath)/PropertyTenancy.sqlite3"
        setupDatabase()
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

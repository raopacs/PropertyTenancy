import Foundation

@available(iOS 17.0, *)
public class Settings: ObservableObject {
    public static let shared = Settings()
    
    @Published public var databasePath: String {
        didSet {
            UserDefaults.standard.set(databasePath, forKey: "databasePath")
        }
    }
    
    private init() {
        // Default path if none is set
        let defaultPath = "/Users/prashanthrao/Documents/PropertyTenancyData"
        self.databasePath = UserDefaults.standard.string(forKey: "databasePath") ?? defaultPath
    }
    
    public func resetToDefault() {
        databasePath = "/Users/prashanthrao/Documents/PropertyTenancyData"
    }
    
    public func isValidPath(_ path: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.isWritableFile(atPath: path) || 
               fileManager.createFile(atPath: path + "/test", contents: nil, attributes: nil)
    }
} 
import SwiftUI

@available(iOS 17.0, *)
public struct SettingsView: View {
    @StateObject private var settings = Settings.shared
    @State private var tempDatabasePath: String = ""
    @State private var showingPathValidation = false
    @State private var pathValidationMessage = ""
    @State private var showingResetAlert = false
    
    public init() {}
    
    @available(iOS 17.0, *)
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Database Settings")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Database Path")
                            .font(.headline)
                        
                        TextField("Enter database path", text: $tempDatabasePath)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onAppear {
                                tempDatabasePath = settings.databasePath
                            }
                        
                        HStack {
                            Button("Validate Path") {
                                validatePath()
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Reset to Default") {
                                showingResetAlert = true
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.orange)
                        }
                        
                        if !pathValidationMessage.isEmpty {
                            Text(pathValidationMessage)
                                .font(.caption)
                                .foregroundColor(showingPathValidation ? .green : .red)
                        }
                    }
                }
                
                Section(header: Text("Current Database Info")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Path: \(settings.databasePath)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button("Open Database Location") {
                            openDatabaseLocation()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                Section(header: Text("Database Operations")) {
                    Button("Test Database Connection") {
                        testDatabaseConnection()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Export Database") {
                        exportDatabase()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSettings()
                    }
                    .disabled(tempDatabasePath.isEmpty)
                }
            }
            .alert("Reset to Default", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetToDefault()
                }
            } message: {
                Text("Are you sure you want to reset the database path to the default location?")
            }
        }
    }
    
    private func validatePath() {
        if tempDatabasePath.isEmpty {
            pathValidationMessage = "Path cannot be empty"
            showingPathValidation = false
            return
        }
        
        let fileManager = FileManager.default
        
        // Check if directory exists or can be created
        if fileManager.fileExists(atPath: tempDatabasePath) {
            if fileManager.isWritableFile(atPath: tempDatabasePath) {
                pathValidationMessage = "✓ Path is valid and writable"
                showingPathValidation = true
            } else {
                pathValidationMessage = "✗ Path exists but is not writable"
                showingPathValidation = false
            }
        } else {
            // Try to create the directory
            do {
                try fileManager.createDirectory(atPath: tempDatabasePath, withIntermediateDirectories: true, attributes: nil)
                pathValidationMessage = "✓ Path created successfully"
                showingPathValidation = true
            } catch {
                pathValidationMessage = "✗ Cannot create directory: \(error.localizedDescription)"
                showingPathValidation = false
            }
        }
    }
    
    private func saveSettings() {
        if showingPathValidation {
            settings.databasePath = tempDatabasePath
            // Reinitialize database with new path
            DatabaseManager.shared.reinitializeDatabase()
            pathValidationMessage = "Settings saved successfully! Database reinitialized."
        } else {
            pathValidationMessage = "Please validate the path before saving"
        }
    }
    
    private func resetToDefault() {
        settings.resetToDefault()
        tempDatabasePath = settings.databasePath
        pathValidationMessage = "Reset to default path"
        showingPathValidation = true
    }
    
    private func openDatabaseLocation() {
        // This would open Finder to the database location
        // For now, just show the path
        pathValidationMessage = "Database location: \(settings.databasePath)"
    }
    
    private func testDatabaseConnection() {
        do {
            // Try to access the database
            let _ = try DatabaseManager.shared.getAllAddresses()
            pathValidationMessage = "✓ Database connection successful"
            showingPathValidation = true
        } catch {
            pathValidationMessage = "✗ Database connection failed: \(error.localizedDescription)"
            showingPathValidation = false
        }
    }
    
    private func exportDatabase() {
        // This would implement database export functionality
        pathValidationMessage = "Export functionality coming soon..."
    }
}

@available(iOS 17.0, *)
#Preview {
    SettingsView()
} 
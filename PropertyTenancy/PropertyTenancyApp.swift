//
//  PropertyTenancyApp.swift
//  PropertyTenancy
//
//  Created by Prashanth Rao on 20/7/2025.
//

import SwiftUI
import UserNotifications

@main
@available(iOS 17.0, *)
struct PropertyTenancyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

@available(iOS 17.0, *)
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Notification permissions granted")
                } else {
                    print("❌ Notification permissions denied: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        
        return true
    }
    
    // Handle notifications when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("📱 Foreground notification received: \(notification.request.identifier)")
        
        // Check if this is a rent-related notification and post the switch notification
        if notification.request.identifier.contains("rent_overdue") || 
           notification.request.identifier.contains("test_overdue") {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .switchToRentTab, object: nil)
                print("🔄 Posted notification to switch to Rent tab (foreground)")
            }
        }
        
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("📱 Notification tapped: \(response.notification.request.identifier)")
        
        // Check if this is a rent-related notification
        if response.notification.request.identifier.contains("rent_overdue") || 
           response.notification.request.identifier.contains("test_overdue") {
            // Post notification to switch to Rent tab
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .switchToRentTab, object: nil)
                print("🔄 Posted notification to switch to Rent tab (tapped)")
            }
        }
        
        completionHandler()
    }
    
    // Handle notification when app is launched from notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("📱 Remote notification received: \(userInfo)")
        completionHandler(.newData)
    }
    
    // Handle local notification when app is in background
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print("📱 Local notification received: \(notification)")
    }
}

// MARK: - Notification Names Extension
extension Notification.Name {
    static let switchToRentTab = Notification.Name("switchToRentTab")
}

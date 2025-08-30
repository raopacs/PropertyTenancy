import Foundation
import UserNotifications

@available(iOS 17.0, *)
public class NotificationManager: ObservableObject {
    public static let shared = NotificationManager()
    
    private init() {
        // Remove duplicate permission request since it's now handled in AppDelegate
        print("🔔 NotificationManager initialized")
    }
    
    // MARK: - Rent Payment Notifications
    
    public func scheduleRentPaymentReminder(for tenancy: TenancyModel, dueDate: Date) {
        // Clear any existing notifications for this tenancy and due date
        clearNotifications(for: tenancy.id ?? 0)
        
        let content = UNMutableNotificationContent()
        content.title = "Rent Payment Due"
        content.body = "Rent payment of ₹\(tenancy.agreedRent) is due for \(tenancy.name)"
        content.sound = .default
        
        // Schedule reminder 3 days before due date
        let reminderDate = Calendar.current.date(byAdding: .day, value: -3, to: dueDate) ?? dueDate
        let reminderTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day], from: reminderDate), repeats: false)
        
        let reminderRequest = UNNotificationRequest(
            identifier: "rent_reminder_\(tenancy.id ?? 0)_\(dueDate.timeIntervalSince1970)",
            content: content,
            trigger: reminderTrigger
        )
        
        UNUserNotificationCenter.current().add(reminderRequest) { error in
            if let error = error {
                print("❌ Failed to schedule rent reminder: \(error.localizedDescription)")
            } else {
                print("✅ Scheduled rent reminder for \(tenancy.name) due on \(dueDate)")
            }
        }
        
        // Schedule overdue notification on due date
        let overdueContent = UNMutableNotificationContent()
        overdueContent.title = "Rent Payment Overdue"
        overdueContent.body = "Rent payment for \(tenancy.name) is now overdue"
        overdueContent.sound = .default
        
        let overdueTrigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day], from: dueDate), repeats: false)
        
        let overdueRequest = UNNotificationRequest(
            identifier: "rent_overdue_\(tenancy.id ?? 0)_\(dueDate.timeIntervalSince1970)",
            content: overdueContent,
            trigger: overdueTrigger
        )
        
        UNUserNotificationCenter.current().add(overdueRequest) { error in
            if let error = error {
                print("❌ Failed to schedule overdue notification: \(error.localizedDescription)")
            } else {
                print("✅ Scheduled overdue notification for \(tenancy.name) due on \(dueDate)")
            }
        }
    }
    
    public func scheduleTenancyRenewalReminder(for tenancy: TenancyModel) {
        let content = UNMutableNotificationContent()
        content.title = "Tenancy Renewal Due"
        content.body = "Tenancy agreement for \(tenancy.name) expires in 1 month. Consider renewal."
        content.sound = .default
        
        // Schedule reminder 11 months after agreement date
        let renewalDate = Calendar.current.date(byAdding: .month, value: 11, to: tenancy.agreementSignedDate) ?? Date()
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day], from: renewalDate), repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "tenancy_renewal_\(tenancy.id ?? 0)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule renewal reminder: \(error.localizedDescription)")
            } else {
                print("✅ Scheduled renewal reminder for \(tenancy.name)")
            }
        }
    }
    
    // MARK: - Check Overdue Payments
    
    public func checkOverdueRentPayments() {
        print("🔍 Checking for overdue rent payments...")
        do {
            let tenancies = try DatabaseManager.shared.getAllTenancies()
            let currentDate = Date()
            
            for tenancy in tenancies {
                guard let tenancyId = tenancy.id else { continue }
                
                checkAndScheduleOverdueNotification(for: tenancy, currentDate: currentDate)
            }
        } catch {
            print("❌ Error checking overdue payments: \(error)")
        }
    }
    
    private func checkAndScheduleOverdueNotification(for tenancy: TenancyModel, currentDate: Date) {
        guard let tenancyId = tenancy.id else { return }
        
        // Calculate the next due date based on the tenancy's monthly due date
        let nextDueDate = calculateNextDueDate(for: tenancy, from: currentDate)
        
        // Check if this due date has already passed
        if nextDueDate < currentDate {
            // Rent is overdue, schedule overdue notification
            scheduleOverdueNotification(for: tenancy, dueDate: nextDueDate)
        } else {
            // Schedule reminder for upcoming due date
            scheduleRentPaymentReminder(for: tenancy, dueDate: nextDueDate)
        }
    }
    
    private func calculateNextDueDate(for tenancy: TenancyModel, from currentDate: Date) -> Date {
        let calendar = Calendar.current
        let monthlyDueDay = tenancy.monthlyDueDate
        
        // Get the last payment for this tenancy
        if let lastPayment = try? DatabaseManager.shared.getLatestRentPayment(forTenancyId: tenancy.id ?? 0) {
            // Calculate next due date from last payment
            var nextDueDate = calendar.date(byAdding: .month, value: 1, to: lastPayment.paidOn) ?? currentDate
            
            // Adjust to the specific day of month
            let components = calendar.dateComponents([.year, .month], from: nextDueDate)
            nextDueDate = calendar.date(from: DateComponents(year: components.year, month: components.month, day: monthlyDueDay)) ?? nextDueDate
            
            return nextDueDate
        } else {
            // No payments yet, calculate from lease start date
            var firstDueDate = calendar.date(byAdding: .month, value: 1, to: tenancy.leaseStartDate) ?? currentDate
            
            // Adjust to the specific day of month
            let components = calendar.dateComponents([.year, .month], from: firstDueDate)
            firstDueDate = calendar.date(from: DateComponents(year: components.year, month: components.month, day: monthlyDueDay)) ?? firstDueDate
            
            return firstDueDate
        }
    }
    
    private func scheduleOverdueNotification(for tenancy: TenancyModel, dueDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "🚨 Rent Payment Overdue!"
        content.body = "Rent payment of ₹\(tenancy.agreedRent) for \(tenancy.name) was due on \(formatDate(dueDate))"
        content.sound = .default
        content.badge = 1
        
        // Schedule overdue notification for today
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day], from: Date()), repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "rent_overdue_\(tenancy.id ?? 0)_\(dueDate.timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule overdue notification: \(error.localizedDescription)")
            } else {
                print("✅ Scheduled overdue notification for \(tenancy.name) - was due on \(self.formatDate(dueDate))")
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // MARK: - Check Tenancy Renewals
    
    public func checkTenancyRenewals() {
        do {
            let tenancies = try DatabaseManager.shared.getAllTenancies()
            let currentDate = Date()
            
            for tenancy in tenancies {
                // Check if 11 months have passed since agreement
                let renewalDate = Calendar.current.date(byAdding: .month, value: 11, to: tenancy.agreementSignedDate) ?? currentDate
                
                if renewalDate <= currentDate {
                    scheduleTenancyRenewalReminder(for: tenancy)
                }
            }
        } catch {
            print("❌ Error checking tenancy renewals: \(error)")
        }
    }
    
    // MARK: - Clear Notifications
    
    public func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ Cleared all pending notifications")
    }
    
    public func clearNotifications(for tenancyId: Int64) {
        // Get all pending notifications and filter by tenancy ID
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToRemove = requests.compactMap { request -> String? in
                if request.identifier.contains("rent_reminder_\(tenancyId)_") ||
                   request.identifier.contains("rent_overdue_\(tenancyId)_") ||
                   request.identifier.contains("tenancy_renewal_\(tenancyId)") {
                    return request.identifier
                }
                return nil
            }
            
            if !identifiersToRemove.isEmpty {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
                print("🗑️ Cleared \(identifiersToRemove.count) notifications for tenancy \(tenancyId)")
            }
        }
    }
    
    // MARK: - Testing and Debug Methods
    
    public func scheduleTestOverdueNotification(for tenancy: TenancyModel) {
        let content = UNMutableNotificationContent()
        content.title = "🧪 Test: Rent Overdue"
        content.body = "This is a test notification for \(tenancy.name) - rent payment overdue"
        content.sound = .default
        content.badge = 1
        
        // Add user info to help with debugging
        content.userInfo = ["testType": "overdue", "tenancyId": tenancy.id ?? 0]
        
        // Schedule for immediate delivery (1 second) for testing
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "test_overdue_\(tenancy.id ?? 0)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule test notification: \(error.localizedDescription)")
            } else {
                print("✅ Scheduled test overdue notification for \(tenancy.name) in 1 second")
                print("✅ Notification identifier: \(request.identifier)")
            }
        }
    }
    
    public func scheduleImmediateTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🚨 Immediate Test"
        content.body = "This notification should appear immediately for testing"
        content.sound = .default
        content.badge = 1
        
        // Schedule for immediate delivery (1 second)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "immediate_test_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule immediate test notification: \(error.localizedDescription)")
            } else {
                print("✅ Scheduled immediate test notification")
            }
        }
    }
    
    public func testTabSwitchDirectly() {
        print("🧪 Testing tab switch directly from NotificationManager...")
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .switchToRentTab, object: nil)
            print("🔄 Posted switchToRentTab notification directly")
        }
    }
    
    public func listAllPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("=== Pending Notifications (\(requests.count)) ===")
            for request in requests {
                print("ID: \(request.identifier)")
                print("Title: \(request.content.title)")
                print("Body: \(request.content.body)")
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("Trigger Date: \(trigger.nextTriggerDate()?.description ?? "Unknown")")
                } else if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                    print("Trigger Interval: \(trigger.timeInterval) seconds")
                }
                print("---")
            }
        }
    }
    
    public func checkNotificationPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                print("📱 Notification Settings:")
                print("Authorization Status: \(settings.authorizationStatus.rawValue)")
                print("Alert Setting: \(settings.alertSetting.rawValue)")
                print("Badge Setting: \(settings.badgeSetting.rawValue)")
                print("Sound Setting: \(settings.soundSetting.rawValue)")
                print("Lock Screen Setting: \(settings.lockScreenSetting.rawValue)")
                print("Notification Center Setting: \(settings.notificationCenterSetting.rawValue)")
            }
        }
    }
}

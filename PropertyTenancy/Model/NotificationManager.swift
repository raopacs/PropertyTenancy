import Foundation
import UserNotifications

@available(iOS 17.0, *)
public class NotificationManager: ObservableObject {
    public static let shared = NotificationManager()
    
    private init() {
        requestNotificationPermissions()
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permissions granted")
            } else if let error = error {
                print("Notification permissions error: \(error)")
            }
        }
    }
    
    // MARK: - Rent Payment Notifications
    
    public func scheduleRentPaymentReminder(for tenancy: TenancyModel, dueDate: Date) {
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
        
        UNUserNotificationCenter.current().add(reminderRequest)
        
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
        
        UNUserNotificationCenter.current().add(overdueRequest)
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
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Check Overdue Payments
    
    public func checkOverdueRentPayments() {
        do {
            let tenancies = try DatabaseManager.shared.getAllTenancies()
            let currentDate = Date()
            
            for tenancy in tenancies {
                guard let tenancyId = tenancy.id else { continue }
                
                // Get the last payment for this tenancy
                if let lastPayment = try DatabaseManager.shared.getLatestRentPayment(forTenancyId: tenancyId) {
                    // Calculate next due date (assuming monthly payments)
                    let nextDueDate = Calendar.current.date(byAdding: .month, value: 1, to: lastPayment.paidOn) ?? currentDate
                    
                    // If next due date has passed, schedule overdue notification
                    if nextDueDate < currentDate {
                        scheduleRentPaymentReminder(for: tenancy, dueDate: nextDueDate)
                    }
                } else {
                    // No payments yet, schedule reminder for lease start date
                    let firstDueDate = Calendar.current.date(byAdding: .month, value: 1, to: tenancy.leaseStartDate) ?? currentDate
                    if firstDueDate < currentDate {
                        scheduleRentPaymentReminder(for: tenancy, dueDate: firstDueDate)
                    }
                }
            }
        } catch {
            print("Error checking overdue payments: \(error)")
        }
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
            print("Error checking tenancy renewals: \(error)")
        }
    }
    
    // MARK: - Clear Notifications
    
    public func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    public func clearNotifications(for tenancyId: Int64) {
        let identifiers = [
            "rent_reminder_\(tenancyId)_*",
            "rent_overdue_\(tenancyId)_*",
            "tenancy_renewal_\(tenancyId)"
        ]
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}

import Foundation
import UserNotifications
import CoreLocation

class NotificationService {
    static let shared = NotificationService()
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("Notification permission: \(granted)")
        }
    }
    
    func scheduleNotification(for task: TaskItem) {
        guard let reminderDate = task.reminderDate ?? task.dueDate else { return }
        guard reminderDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = task.title
        content.body = task.notes.isEmpty ? "任务提醒" : task.notes
        content.sound = .default
        content.userInfo = ["taskID": task.id.uuidString]
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification(for task: TaskItem) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
    
    func scheduleLocationNotification(for task: TaskItem, latitude: Double, longitude: Double, onArrival: Bool = true) {
        // UNLocationNotificationTrigger is unavailable on macOS
        // Location reminders would require a different implementation using CoreLocation directly
        #if os(iOS)
        guard let location = task.location else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "地点提醒: \(task.title)"
        content.body = "你已\(onArrival ? "到达" : "离开") \(location)"
        content.sound = .default
        
        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                                      radius: 100, identifier: "\(task.id.uuidString)_location")
        region.notifyOnEntry = onArrival
        region.notifyOnExit = !onArrival
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        let request = UNNotificationRequest(identifier: "\(task.id.uuidString)_location", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        #endif
    }
}

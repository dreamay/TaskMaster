import Foundation

enum Priority: Int, Codable, CaseIterable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3
    
    var description: String {
        switch self {
        case .none: return "无"
        case .low: return "低"
        case .medium: return "中"
        case .high: return "高"
        }
    }
    
    var color: String {
        switch self {
        case .none: return "gray"
        case .low: return "blue"
        case .medium: return "orange"
        case .high: return "red"
        }
    }
}

enum RepeatRule: String, Codable, CaseIterable {
    case none = "none"
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    case custom = "custom"
    
    var description: String {
        switch self {
        case .none: return "不重复"
        case .daily: return "每天"
        case .weekly: return "每周"
        case .monthly: return "每月"
        case .yearly: return "每年"
        case .custom: return "自定义"
        }
    }
}

class TaskItem: Codable, Identifiable, ObservableObject {
    var id: UUID
    var title: String
    var notes: String
    var createdAt: Date
    var modifiedAt: Date
    var dueDate: Date?
    var reminderDate: Date?
    var location: String?
    var priority: Priority
    var isCompleted: Bool
    var completedAt: Date?
    var tags: [String]
    var projectID: UUID?
    var repeatRule: RepeatRule
    var customRepeatDays: [Int]?
    var isDeleted: Bool
    var deletedAt: Date?
    var sortOrder: Int
    var sourceTaskID: UUID?
    
    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        dueDate: Date? = nil,
        reminderDate: Date? = nil,
        location: String? = nil,
        priority: Priority = .none,
        tags: [String] = [],
        projectID: UUID? = nil,
        repeatRule: RepeatRule = .none,
        customRepeatDays: [Int]? = nil,
        sortOrder: Int = 0,
        sourceTaskID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.dueDate = dueDate
        self.reminderDate = reminderDate
        self.location = location
        self.priority = priority
        self.isCompleted = false
        self.completedAt = nil
        self.tags = tags
        self.projectID = projectID
        self.repeatRule = repeatRule
        self.customRepeatDays = customRepeatDays
        self.isDeleted = false
        self.deletedAt = nil
        self.sortOrder = sortOrder
        self.sourceTaskID = sourceTaskID
    }
    
    var isInTrash: Bool {
        isDeleted && deletedAt != nil
    }
    
    var daysInTrash: Int? {
        guard let deletedAt = deletedAt else { return nil }
        return Calendar.current.dateComponents([.day], from: deletedAt, to: Date()).day
    }
    
    var shouldAutoDelete: Bool {
        guard let days = daysInTrash else { return false }
        return days >= 30
    }
    
    func toggleComplete() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
        modifiedAt = Date()
    }
    
    func moveToTrash() {
        isDeleted = true
        deletedAt = Date()
        modifiedAt = Date()
    }
    
    func restore() {
        isDeleted = false
        deletedAt = nil
        modifiedAt = Date()
    }
}

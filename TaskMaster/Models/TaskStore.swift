import Foundation
import Combine

class TaskStore: ObservableObject {
    static let shared = TaskStore()
    
    @Published var tasks: [TaskItem] = []
    @Published var projects: [Project] = []
    @Published var tags: [Tag] = []
    @Published var settings: AppSettings = AppSettings()
    
    private let dataDir: URL
    private let tasksURL: URL
    private let projectsURL: URL
    private let tagsURL: URL
    private let settingsURL: URL
    
    init() {
        let fm = FileManager.default
        let supportDir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = supportDir.appendingPathComponent("TaskMaster", isDirectory: true)
        try? fm.createDirectory(at: appDir, withIntermediateDirectories: true)
        
        dataDir = appDir
        tasksURL = appDir.appendingPathComponent("tasks.json")
        projectsURL = appDir.appendingPathComponent("projects.json")
        tagsURL = appDir.appendingPathComponent("tags.json")
        settingsURL = appDir.appendingPathComponent("settings.json")
        
        loadAll()
    }
    
    func loadAll() {
        tasks = load(from: tasksURL) ?? []
        projects = load(from: projectsURL) ?? []
        tags = load(from: tagsURL) ?? []
        settings = load(from: settingsURL) ?? AppSettings()
        
        // Clean old trash items
        cleanOldTrash()
    }
    
    func saveAll() {
        save(tasks, to: tasksURL)
        save(projects, to: projectsURL)
        save(tags, to: tagsURL)
        save(settings, to: settingsURL)
    }
    
    private func load<T: Codable>(from url: URL) -> T? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    private func save<T: Codable>(_ value: T, to url: URL) {
        if let data = try? JSONEncoder().encode(value) {
            try? data.write(to: url)
        }
    }
    
    // MARK: - Task Operations
    
    func addTask(_ task: TaskItem) {
        tasks.append(task)
        saveAll()
    }
    
    func updateTask(_ task: TaskItem) {
        task.modifiedAt = Date()
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
        saveAll()
    }
    
    func deleteTask(_ task: TaskItem) {
        if task.isDeleted {
            tasks.removeAll { $0.id == task.id }
        } else {
            task.moveToTrash()
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks[index] = task
            }
        }
        saveAll()
    }
    
    func restoreTask(_ task: TaskItem) {
        task.restore()
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
        saveAll()
    }
    
    func toggleComplete(_ task: TaskItem) {
        task.toggleComplete()
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
        saveAll()
    }
    
    func duplicateTask(_ task: TaskItem) {
        let newTask = TaskItem(
            title: task.title,
            notes: task.notes,
            dueDate: task.dueDate,
            reminderDate: task.reminderDate,
            location: task.location,
            priority: task.priority,
            tags: task.tags,
            projectID: task.projectID,
            repeatRule: task.repeatRule,
            customRepeatDays: task.customRepeatDays
        )
        tasks.append(newTask)
        saveAll()
    }
    
    func addProject(_ project: Project) {
        projects.append(project)
        saveAll()
    }
    
    func addTag(_ tag: Tag) {
        tags.append(tag)
        saveAll()
    }
    
    func exportToJSON() -> URL? {
        let exportData: [String: Any] = [
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "version": "1.0",
            "tasks": tasks.map { taskToDict($0) },
            "projects": projects.map { projectToDict($0) },
            "tags": tags.map { tagToDict($0) }
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("TaskMaster_Export_\(Date().timeIntervalSince1970).json")
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }
    
    func exportToCSV() -> URL? {
        var csv = "Title,Due Date,Priority,Location,Tags,Completed,Notes\n"
        for task in tasks {
            let title = escapeCSV(task.title)
            let dueDate = task.dueDate?.formattedDate() ?? ""
            let priority = task.priority.description
            let location = task.location ?? ""
            let tags = task.tags.joined(separator: ";")
            let completed = task.isCompleted ? "Yes" : "No"
            let notes = escapeCSV(task.notes)
            csv += "\(title),\(dueDate),\(priority),\(location),\(tags),\(completed),\(notes)\n"
        }
        do {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("TaskMaster_Export_\(Date().timeIntervalSince1970).csv")
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }
    
    private func cleanOldTrash() {
        let toRemove = tasks.filter { $0.shouldAutoDelete }
        tasks.removeAll { task in toRemove.contains(where: { $0.id == task.id }) }
        if !toRemove.isEmpty {
            saveAll()
        }
    }
    
    private func escapeCSV(_ string: String) -> String {
        if string.contains(",") || string.contains("\"") || string.contains("\n") {
            return "\"\(string.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return string
    }
    
    private func taskToDict(_ task: TaskItem) -> [String: Any] {
        var dict: [String: Any] = [
            "id": task.id.uuidString,
            "title": task.title,
            "notes": task.notes,
            "createdAt": ISO8601DateFormatter().string(from: task.createdAt),
            "modifiedAt": ISO8601DateFormatter().string(from: task.modifiedAt),
            "priority": task.priority.rawValue,
            "isCompleted": task.isCompleted,
            "tags": task.tags,
            "repeatRule": task.repeatRule.rawValue,
            "sortOrder": task.sortOrder,
            "isDeleted": task.isDeleted
        ]
        if let dueDate = task.dueDate { dict["dueDate"] = ISO8601DateFormatter().string(from: dueDate) }
        if let reminderDate = task.reminderDate { dict["reminderDate"] = ISO8601DateFormatter().string(from: reminderDate) }
        if let location = task.location { dict["location"] = location }
        if let projectID = task.projectID { dict["projectID"] = projectID.uuidString }
        return dict
    }
    
    private func projectToDict(_ project: Project) -> [String: Any] {
        [
            "id": project.id.uuidString,
            "name": project.name,
            "color": project.color,
            "createdAt": ISO8601DateFormatter().string(from: project.createdAt),
            "sortOrder": project.sortOrder
        ]
    }
    
    private func tagToDict(_ tag: Tag) -> [String: Any] {
        [
            "id": tag.id.uuidString,
            "name": tag.name,
            "color": tag.color,
            "createdAt": ISO8601DateFormatter().string(from: tag.createdAt)
        ]
    }
}

import Foundation
import SwiftData

class DataExportService {
    static let shared = DataExportService()
    
    func exportToJSON(tasks: [TaskItem], projects: [Project], tags: [Tag]) -> URL? {
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
            print("Export error: \(error)")
            return nil
        }
    }
    
    func exportToCSV(tasks: [TaskItem]) -> URL? {
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
            print("CSV export error: \(error)")
            return nil
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
        if let dueDate = task.dueDate {
            dict["dueDate"] = ISO8601DateFormatter().string(from: dueDate)
        }
        if let reminderDate = task.reminderDate {
            dict["reminderDate"] = ISO8601DateFormatter().string(from: reminderDate)
        }
        if let location = task.location {
            dict["location"] = location
        }
        if let projectID = task.projectID {
            dict["projectID"] = projectID.uuidString
        }
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

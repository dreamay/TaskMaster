import Foundation

class Project: Codable, Identifiable, ObservableObject {
    var id: UUID
    var name: String
    var color: String
    var createdAt: Date
    var sortOrder: Int
    
    init(
        id: UUID = UUID(),
        name: String,
        color: String = "blue",
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.createdAt = Date()
        self.sortOrder = sortOrder
    }
}

class Tag: Codable, Identifiable, ObservableObject {
    var id: UUID
    var name: String
    var color: String
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        color: String = "gray"
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.createdAt = Date()
    }
}

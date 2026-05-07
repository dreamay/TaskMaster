import SwiftUI

extension Color {
    static func from(string: String) -> Color {
        switch string.lowercased() {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "gray", "grey": return .gray
        case "indigo": return .indigo
        case "cyan": return .cyan
        case "teal": return .teal
        case "brown": return .brown
        default: return .blue
        }
    }
}

extension Priority {
    func swiftUIColor() -> Color {
        Color.from(string: self.color)
    }
}

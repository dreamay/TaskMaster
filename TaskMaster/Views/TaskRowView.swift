import SwiftUI

struct TaskRowView: View {
    let task: TaskItem
    let isHovered: Bool
    let isSelected: Bool
    let onToggleComplete: () -> Void
    let onEdit: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            // Checkbox
            Button(action: onToggleComplete) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            .frame(width: 24)
            
            // Task content
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 14))
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    if !task.tags.isEmpty {
                        Text(task.tags.joined(separator: ", "))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    if let dueDate = task.dueDate {
                        HStack(spacing: 2) {
                            Image(systemName: "calendar")
                                .font(.system(size: 9))
                            Text(dueDate.formattedShortDate())
                                .font(.system(size: 11))
                        }
                        .foregroundColor(dueDate < Date() && !task.isCompleted ? .red : .secondary)
                    }
                    
                    if let location = task.location {
                        HStack(spacing: 2) {
                            Image(systemName: "location")
                                .font(.system(size: 9))
                            Text(location)
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Priority indicator
            if task.priority != .none {
                Circle()
                    .fill(task.priority.swiftUIColor())
                    .frame(width: 8, height: 8)
            }
            
            // Hover actions
            if isHovered {
                HStack(spacing: 8) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                    .help("编辑")
                    
                    Button(action: onDuplicate) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                    .help("复制")
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                    .help("删除")
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            isHovered
            ? Color.primary.opacity(0.04)
            : Color.clear
        )
        .contentShape(Rectangle())
    }
}

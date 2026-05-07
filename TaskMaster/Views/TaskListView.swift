import SwiftUI
import AppKit

struct TaskListView: View {
    @EnvironmentObject var store: TaskStore
    
    let selectedNav: NavigationItem
    let selectedDate: Date
    let searchText: String
    let selectedTags: Set<String>
    let onAddTask: () -> Void
    let onEditTask: (TaskItem) -> Void
    let onVoiceInput: () -> Void
    let onSearch: () -> Void
    let onToggleSidebar: () -> Void
    let onToggleCalendar: () -> Void
    let showSidebar: Bool
    let showCalendar: Bool
    
    @State private var hoveredTaskID: UUID?
    @State private var selectedTaskIDs: Set<UUID> = []
    @State private var showMoreMenu = false
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            Divider()
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(filteredTasks.enumerated()), id: \.element.id) { index, task in
                        TaskRowView(
                            task: task,
                            isHovered: hoveredTaskID == task.id,
                            isSelected: selectedTaskIDs.contains(task.id),
                            onToggleComplete: { toggleComplete(task) },
                            onEdit: { onEditTask(task) },
                            onDuplicate: { duplicateTask(task) },
                            onDelete: { deleteTask(task) }
                        )
                        .onHover { hovering in
                            hoveredTaskID = hovering ? task.id : nil
                        }
                        .onTapGesture {
                            if NSEvent.modifierFlags.contains(.shift) {
                                // Range selection
                            } else if NSEvent.modifierFlags.contains(.command) {
                                if selectedTaskIDs.contains(task.id) {
                                    selectedTaskIDs.remove(task.id)
                                } else {
                                    selectedTaskIDs.insert(task.id)
                                }
                            } else {
                                selectedTaskIDs = [task.id]
                            }
                        }
                        .background(
                            selectedTaskIDs.contains(task.id)
                            ? Color.accentColor.opacity(0.1)
                            : Color.clear
                        )
                    }
                }
                .padding(.vertical, 4)
            }
            
            ZStack {
                HStack {
                    Spacer()
                    Button(action: onAddTask) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(Color.red)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .help("新建任务")
                    .padding(.trailing, 20)
                    .padding(.bottom, 16)
                }
            }
        }
        .background(Color(NSColor.textBackgroundColor))
    }
    
    private var headerView: some View {
        HStack {
            HStack(spacing: 8) {
                if !showSidebar {
                    Button(action: onToggleSidebar) {
                        Image(systemName: "sidebar.left")
                    }
                    .buttonStyle(.plain)
                }
                
                Text(headerTitle)
                    .font(.system(size: 18, weight: .bold))
                
                Text("\(filteredTasks.count)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.12))
                    .clipShape(Capsule())
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onSearch) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .help("搜索")
                
                Menu {
                    Button("按日期排序") { }
                    Button("按优先级排序") { }
                    Button("按创建时间排序") { }
                    Divider()
                    Button("显示已完成") { }
                    Button("批量操作") { }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 14))
                }
                .menuStyle(.borderlessButton)
                .help("更多操作")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var headerTitle: String {
        switch selectedNav {
        case .inbox: return "收件箱"
        case .plan:
            if selectedDate.isToday() {
                return "今天 \(selectedDate.weekdayName())"
            } else {
                return selectedDate.formattedShortDate()
            }
        case .lists: return "列表"
        case .tags: return "标签"
        case .history: return "历史"
        case .trash: return "回收站"
        }
    }
    
    private var filteredTasks: [TaskItem] {
        var result = store.tasks
        
        switch selectedNav {
        case .inbox:
            result = result.filter { $0.dueDate == nil && !$0.isCompleted && !$0.isDeleted }
        case .plan:
            result = result.filter {
                !$0.isDeleted &&
                ($0.dueDate?.isSameDay(as: selectedDate) ?? false ||
                 (!$0.isCompleted && $0.dueDate == nil))
            }
        case .lists:
            result = result.filter { !$0.isDeleted && !$0.isCompleted }
        case .tags:
            result = result.filter { !$0.isDeleted }
        case .history:
            result = result.filter { $0.isCompleted && !$0.isDeleted }
        case .trash:
            result = result.filter { $0.isDeleted }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.notes.localizedCaseInsensitiveContains(searchText) ||
                ($0.location?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        if !selectedTags.isEmpty {
            result = result.filter { task in
                !Set(task.tags).isDisjoint(with: selectedTags)
            }
        }
        
        result.sort {
            if $0.isCompleted != $1.isCompleted {
                return !$0.isCompleted
            }
            if let d1 = $0.dueDate, let d2 = $1.dueDate {
                return d1 < d2
            }
            return $0.createdAt > $1.createdAt
        }
        
        return result
    }
    
    private func toggleComplete(_ task: TaskItem) {
        store.toggleComplete(task)
        if task.isCompleted {
            NotificationService.shared.cancelNotification(for: task)
        } else {
            NotificationService.shared.scheduleNotification(for: task)
        }
    }
    
    private func duplicateTask(_ task: TaskItem) {
        store.duplicateTask(task)
    }
    
    private func deleteTask(_ task: TaskItem) {
        store.deleteTask(task)
        NotificationService.shared.cancelNotification(for: task)
    }
}

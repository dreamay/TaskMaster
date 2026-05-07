import SwiftUI

struct TaskEditorView: View {
    @EnvironmentObject var store: TaskStore
    @Environment(\.dismiss) private var dismiss
    
    var task: TaskItem?
    var onSave: () -> Void
    
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var dueDate: Date = Date()
    @State private var hasDueDate: Bool = false
    @State private var hasReminder: Bool = false
    @State private var reminderDate: Date = Date()
    @State private var location: String = ""
    @State private var priority: Priority = .none
    @State private var selectedTags: [String] = []
    @State private var selectedProjectID: UUID?
    @State private var repeatRule: RepeatRule = .none
    @State private var showDeleteConfirmation = false
    
    private var isEditing: Bool { task != nil }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(isEditing ? "编辑任务" : "新建任务")
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                if isEditing {
                    Button(action: { showDeleteConfirmation = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
                
                Button("取消") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("保存") {
                    saveTask()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(title.trimmed().isEmpty)
            }
            .padding()
            
            Divider()
            
            Form {
                Section {
                    TextField("任务标题", text: $title)
                        .font(.system(size: 15))
                    
                    TextField("备注", text: $notes, axis: .vertical)
                        .font(.system(size: 13))
                        .lineLimit(3...6)
                }
                
                Section("日期与时间") {
                    Toggle("设置截止日期", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("截止日期", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                    
                    Toggle("设置提醒", isOn: $hasReminder)
                    
                    if hasReminder {
                        DatePicker("提醒时间", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Section("详细信息") {
                    Picker("优先级", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { p in
                            HStack {
                                Circle()
                                    .fill(p.swiftUIColor())
                                    .frame(width: 8, height: 8)
                                Text(p.description)
                            }
                            .tag(p)
                        }
                    }
                    
                    TextField("地点", text: $location)
                    
                    Picker("重复", selection: $repeatRule) {
                        ForEach(RepeatRule.allCases, id: \.self) { rule in
                            Text(rule.description).tag(rule)
                        }
                    }
                    
                    if !store.projects.isEmpty {
                        Picker("项目", selection: $selectedProjectID) {
                            Text("无").tag(nil as UUID?)
                            ForEach(store.projects) { project in
                                Text(project.name).tag(project.id as UUID?)
                            }
                        }
                    }
                }
                
                Section("标签") {
                    FlowLayout(spacing: 8) {
                        ForEach(store.tags) { tag in
                            TagButton(
                                name: tag.name,
                                color: Color.from(string: tag.color),
                                isSelected: selectedTags.contains(tag.name)
                            ) {
                                if selectedTags.contains(tag.name) {
                                    selectedTags.removeAll { $0 == tag.name }
                                } else {
                                    selectedTags.append(tag.name)
                                }
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .padding(.horizontal, 8)
        }
        .frame(minWidth: 450, minHeight: 500)
        .onAppear {
            if let task = task {
                title = task.title
                notes = task.notes
                if let dueDate = task.dueDate {
                    self.dueDate = dueDate
                    hasDueDate = true
                }
                if let reminderDate = task.reminderDate {
                    self.reminderDate = reminderDate
                    hasReminder = true
                }
                location = task.location ?? ""
                priority = task.priority
                selectedTags = task.tags
                selectedProjectID = task.projectID
                repeatRule = task.repeatRule
            }
        }
        .alert("确认删除", isPresented: $showDeleteConfirmation) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                if let task = task {
                    store.deleteTask(task)
                }
                onSave()
            }
        } message: {
            Text("此操作无法撤销")
        }
    }
    
    private func saveTask() {
        if let existingTask = task {
            existingTask.title = title.trimmed()
            existingTask.notes = notes
            existingTask.dueDate = hasDueDate ? dueDate : nil
            existingTask.reminderDate = hasReminder ? reminderDate : nil
            existingTask.location = location.isEmpty ? nil : location
            existingTask.priority = priority
            existingTask.tags = selectedTags
            existingTask.projectID = selectedProjectID
            existingTask.repeatRule = repeatRule
            existingTask.modifiedAt = Date()
            store.updateTask(existingTask)
            
            if hasReminder || hasDueDate {
                NotificationService.shared.scheduleNotification(for: existingTask)
            }
        } else {
            let newTask = TaskItem(
                title: title.trimmed(),
                notes: notes,
                dueDate: hasDueDate ? dueDate : nil,
                reminderDate: hasReminder ? reminderDate : nil,
                location: location.isEmpty ? nil : location,
                priority: priority,
                tags: selectedTags,
                projectID: selectedProjectID,
                repeatRule: repeatRule
            )
            store.addTask(newTask)
            
            if hasReminder || hasDueDate {
                NotificationService.shared.scheduleNotification(for: newTask)
            }
        }
        
        onSave()
    }
}

struct TagButton: View {
    let name: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.system(size: 12))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(isSelected ? color.opacity(0.2) : Color.secondary.opacity(0.1))
                .foregroundColor(isSelected ? color : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? color : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                self.size.width = max(self.size.width, x)
            }
            self.size.height = y + rowHeight
        }
    }
}

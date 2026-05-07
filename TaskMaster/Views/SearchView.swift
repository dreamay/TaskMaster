import SwiftUI

struct SearchView: View {
    @EnvironmentObject var store: TaskStore
    @Environment(\.dismiss) private var dismiss
    
    let onSelect: (TaskItem) -> Void
    
    @State private var searchText: String = ""
    @State private var selectedFilter: SearchFilter = .all
    
    enum SearchFilter: String, CaseIterable {
        case all = "全部"
        case title = "标题"
        case notes = "备注"
        case location = "地点"
    }
    
    var filteredTasks: [TaskItem] {
        guard !searchText.isEmpty else { return [] }
        
        return store.tasks.filter { task in
            let query = searchText.localizedLowercase
            switch selectedFilter {
            case .all:
                return task.title.localizedLowercase.contains(query) ||
                       task.notes.localizedLowercase.contains(query) ||
                       (task.location?.localizedLowercase.contains(query) ?? false)
            case .title:
                return task.title.localizedLowercase.contains(query)
            case .notes:
                return task.notes.localizedLowercase.contains(query)
            case .location:
                return task.location?.localizedLowercase.contains(query) ?? false
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("搜索任务...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Picker("", selection: $selectedFilter) {
                    ForEach(SearchFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
                
                Button("关闭") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding()
            
            Divider()
            
            if searchText.isEmpty {
                Spacer()
                Text("输入关键词搜索任务")
                    .foregroundColor(.secondary)
                Spacer()
            } else if filteredTasks.isEmpty {
                Spacer()
                Text("未找到匹配的任务")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                List(filteredTasks) { task in
                    SearchResultRow(task: task)
                        .onTapGesture {
                            onSelect(task)
                        }
                }
                .listStyle(.plain)
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
}

struct SearchResultRow: View {
    let task: TaskItem
    
    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.isCompleted ? .green : .secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: 14))
                    .lineLimit(1)
                
                if let dueDate = task.dueDate {
                    Text(dueDate.formattedShortDate())
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if task.priority != .none {
                Circle()
                    .fill(task.priority.swiftUIColor())
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.vertical, 4)
    }
}

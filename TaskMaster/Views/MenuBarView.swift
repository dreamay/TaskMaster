import SwiftUI
import AppKit

struct MenuBarView: View {
    @EnvironmentObject var store: TaskStore
    
    var todayTasks: [TaskItem] {
        store.tasks.filter { !$0.isCompleted && !$0.isDeleted }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("今日任务 (\(todayTasks.count))")
                .font(.system(size: 13, weight: .semibold))
                .padding()
            
            Divider()
            
            if todayTasks.isEmpty {
                Text("暂无任务")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(todayTasks.prefix(5)) { task in
                    HStack {
                        Image(systemName: "circle")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Text(task.title)
                            .font(.system(size: 13))
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                }
            }
            
            Divider()
            
            Button("打开 TaskMaster") {
                NSApp.activate(ignoringOtherApps: true)
            }
            .buttonStyle(.plain)
            .padding()
            
            Button("退出") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(width: 240)
    }
}

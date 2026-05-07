import SwiftUI

enum NavigationItem: String, CaseIterable, Identifiable {
    case inbox = "收件箱"
    case plan = "计划"
    case lists = "列表"
    case tags = "标签"
    case history = "历史"
    case trash = "回收站"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .inbox: return "envelope.fill"
        case .plan: return "calendar"
        case .lists: return "list.bullet"
        case .tags: return "tag.fill"
        case .history: return "checkmark.circle.fill"
        case .trash: return "trash.fill"
        }
    }
}

struct MainView: View {
    @EnvironmentObject var store: TaskStore
    
    @State private var selectedNav: NavigationItem = .plan
    @State private var selectedDate: Date = Date()
    @State private var searchText: String = ""
    @State private var showSearch: Bool = false
    @State private var showVoiceInput: Bool = false
    @State private var showTaskEditor: Bool = false
    @State private var editingTask: TaskItem?
    @State private var sidebarWidth: CGFloat = 200
    @State private var calendarWidth: CGFloat = 280
    @State private var showSidebar: Bool = true
    @State private var showCalendar: Bool = true
    @State private var selectedTags: Set<String> = []
    
    var body: some View {
        HSplitView {
            if showSidebar {
                SidebarView(
                    selectedNav: $selectedNav,
                    unreadCount: unreadCount,
                    onSettings: {},
                    onHelp: {}
                )
                .frame(minWidth: 160, idealWidth: 200, maxWidth: 280)
            }
            
            if showCalendar && selectedNav == .plan {
                CalendarView(
                    selectedDate: $selectedDate,
                    tasks: filteredTasksForCalendar
                )
                .frame(minWidth: 240, idealWidth: 280, maxWidth: 360)
            }
            
            TaskListView(
                selectedNav: selectedNav,
                selectedDate: selectedDate,
                searchText: searchText,
                selectedTags: selectedTags,
                onAddTask: { showTaskEditor = true },
                onEditTask: { task in
                    editingTask = task
                    showTaskEditor = true
                },
                onVoiceInput: { showVoiceInput = true },
                onSearch: { showSearch = true },
                onToggleSidebar: { showSidebar.toggle() },
                onToggleCalendar: { showCalendar.toggle() },
                showSidebar: showSidebar,
                showCalendar: showCalendar
            )
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: { showSidebar.toggle() }) {
                    Image(systemName: showSidebar ? "sidebar.left" : "sidebar.left")
                }
                .help("切换侧边栏")
                
                Button(action: { showCalendar.toggle() }) {
                    Image(systemName: showCalendar ? "calendar" : "calendar.badge.plus")
                }
                .help("切换日历")
                
                Button(action: { showSearch = true }) {
                    Image(systemName: "magnifyingglass")
                }
                .help("搜索任务")
                
                Button(action: { showVoiceInput = true }) {
                    Image(systemName: "mic.fill")
                }
                .help("语音输入")
                
                Button(action: { showTaskEditor = true }) {
                    Image(systemName: "plus")
                }
                .help("新建任务")
            }
        }
        .sheet(isPresented: $showTaskEditor) {
            TaskEditorView(task: editingTask, onSave: {
                editingTask = nil
                showTaskEditor = false
            })
            .frame(minWidth: 500, minHeight: 500)
            .environmentObject(store)
        }
        .sheet(isPresented: $showVoiceInput) {
            VoiceInputView(onSave: {
                showVoiceInput = false
            })
            .frame(minWidth: 500, minHeight: 400)
            .environmentObject(store)
        }
        .sheet(isPresented: $showSearch) {
            SearchView(
                onSelect: { task in
                    editingTask = task
                    showTaskEditor = true
                    showSearch = false
                }
            )
            .frame(minWidth: 500, minHeight: 400)
            .environmentObject(store)
        }
        .onAppear {
            NotificationService.shared.requestAuthorization()
        }
    }
    
    private var unreadCount: Int {
        store.tasks.filter { !$0.isCompleted && !$0.isDeleted }.count
    }
    
    private var filteredTasksForCalendar: [TaskItem] {
        store.tasks.filter { !$0.isDeleted }
    }
}

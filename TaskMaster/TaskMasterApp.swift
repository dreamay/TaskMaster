import SwiftUI

@main
struct TaskMasterApp: App {
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true
    @AppStorage("selectedAppearance") private var selectedAppearance = 0
    @StateObject private var store = TaskStore.shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 1000, minHeight: 700)
                .preferredColorScheme(colorScheme)
                .environmentObject(store)
        }
        .defaultSize(width: 1200, height: 800)
        .windowResizability(.contentSize)
        
        Settings {
            SettingsView()
                .frame(minWidth: 600, minHeight: 500)
                .environmentObject(store)
        }
        
        MenuBarExtra("TaskMaster", systemImage: "checklist", isInserted: $showMenuBarExtra) {
            MenuBarView()
                .environmentObject(store)
        }
    }
    
    private var colorScheme: ColorScheme? {
        switch selectedAppearance {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }
}

import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedAppearance") private var selectedAppearance = 0
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true
    @AppStorage("themeColor") private var themeColor = "blue"
    @AppStorage("fontSize") private var fontSize = 14.0
    
    let colors = ["blue", "red", "green", "purple", "orange", "pink"]
    
    var body: some View {
        TabView {
            GeneralSettingsView(
                selectedAppearance: $selectedAppearance,
                showMenuBarExtra: $showMenuBarExtra,
                themeColor: $themeColor,
                fontSize: $fontSize,
                colors: colors
            )
            .tabItem {
                Label("通用", systemImage: "gear")
            }
            
            ShortcutSettingsView()
                .tabItem {
                    Label("快捷键", systemImage: "keyboard")
                }
            
            SyncSettingsView()
                .tabItem {
                    Label("同步与备份", systemImage: "icloud")
                }
        }
        .frame(minWidth: 550, minHeight: 400)
        .padding()
    }
}

struct GeneralSettingsView: View {
    @Binding var selectedAppearance: Int
    @Binding var showMenuBarExtra: Bool
    @Binding var themeColor: String
    @Binding var fontSize: Double
    let colors: [String]
    
    var body: some View {
        Form {
            Section("外观") {
                Picker("主题", selection: $selectedAppearance) {
                    Text("自动").tag(0)
                    Text("浅色").tag(1)
                    Text("深色").tag(2)
                }
                .pickerStyle(.segmented)
                
                HStack {
                    Text("主题色")
                    Spacer()
                    ForEach(colors, id: \.self) { color in
                        Circle()
                            .fill(Color.from(string: color))
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(themeColor == color ? Color.primary : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                themeColor = color
                            }
                    }
                }
                
                HStack {
                    Text("字体大小")
                    Slider(value: $fontSize, in: 12...20, step: 1)
                    Text("\(Int(fontSize))")
                        .frame(width: 30)
                }
            }
            
            Section("菜单栏") {
                Toggle("在菜单栏显示", isOn: $showMenuBarExtra)
            }
        }
        .formStyle(.grouped)
    }
}

struct ShortcutSettingsView: View {
    @AppStorage("shortcutNewTask") private var shortcutNewTask = "⌘N"
    @AppStorage("shortcutVoiceInput") private var shortcutVoiceInput = "⌘⇧V"
    @AppStorage("shortcutCompleteTask") private var shortcutCompleteTask = "⌘D"
    @AppStorage("shortcutSwitchView") private var shortcutSwitchView = "⌘1"
    
    var body: some View {
        Form {
            Section("快捷键") {
                HStack {
                    Text("新建任务")
                    Spacer()
                    Text(shortcutNewTask)
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                
                HStack {
                    Text("语音输入")
                    Spacer()
                    Text(shortcutVoiceInput)
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                
                HStack {
                    Text("完成任务")
                    Spacer()
                    Text(shortcutCompleteTask)
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                
                HStack {
                    Text("切换视图")
                    Spacer()
                    Text(shortcutSwitchView)
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
        }
        .formStyle(.grouped)
    }
}

struct SyncSettingsView: View {
    @AppStorage("enableCloudSync") private var enableCloudSync = false
    @AppStorage("autoBackup") private var autoBackup = true
    
    var body: some View {
        Form {
            Section("iCloud 同步") {
                Toggle("启用 iCloud 同步", isOn: $enableCloudSync)
                
                if enableCloudSync {
                    Text("数据将在所有登录同一 Apple ID 的设备间同步")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            Section("备份") {
                Toggle("自动备份", isOn: $autoBackup)
                
                HStack {
                    Button("导出 JSON") { }
                    Button("导出 CSV") { }
                }
            }
        }
        .formStyle(.grouped)
    }
}

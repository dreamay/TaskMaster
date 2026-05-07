import Foundation

class AppSettings: Codable, Identifiable, ObservableObject {
    var id: UUID
    var themeColor: String
    var fontSize: Double
    var defaultView: String
    var enableLocationReminder: Bool
    var enableSoundNotification: Bool
    var autoBackup: Bool
    var backupInterval: Int
    var lastBackupDate: Date?
    var enableCloudSync: Bool
    var shortcutNewTask: String
    var shortcutVoiceInput: String
    var shortcutCompleteTask: String
    var shortcutSwitchView: String
    
    init(
        id: UUID = UUID(),
        themeColor: String = "blue",
        fontSize: Double = 14.0,
        defaultView: String = "plan",
        enableLocationReminder: Bool = false,
        enableSoundNotification: Bool = true,
        autoBackup: Bool = true,
        backupInterval: Int = 7,
        enableCloudSync: Bool = false,
        shortcutNewTask: String = "⌘N",
        shortcutVoiceInput: String = "⌘⇧V",
        shortcutCompleteTask: String = "⌘D",
        shortcutSwitchView: String = "⌘1"
    ) {
        self.id = id
        self.themeColor = themeColor
        self.fontSize = fontSize
        self.defaultView = defaultView
        self.enableLocationReminder = enableLocationReminder
        self.enableSoundNotification = enableSoundNotification
        self.autoBackup = autoBackup
        self.backupInterval = backupInterval
        self.lastBackupDate = nil
        self.enableCloudSync = enableCloudSync
        self.shortcutNewTask = shortcutNewTask
        self.shortcutVoiceInput = shortcutVoiceInput
        self.shortcutCompleteTask = shortcutCompleteTask
        self.shortcutSwitchView = shortcutSwitchView
    }
}

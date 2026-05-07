# TaskMaster - 智能语音任务管理

一款专为 Apple Silicon Mac 设计的原生任务管理应用，采用经典三栏布局，支持智能语音创建任务、自然语言时间/地点解析、日历集成、iCloud 同步等高级功能。

## 系统要求

- **macOS**: 14.0 (Sonoma) 或更高版本
- **芯片**: Apple Silicon (M1/M2/M3/M4 系列)
- **架构**: arm64 (无 Intel 兼容层)
- **Xcode**: 15.0 或更高版本 (用于编译)

## 功能特性

### 界面设计
- 经典左-中-右三栏布局（导航 / 日历 / 任务列表）
- 支持手动调整各栏宽度、隐藏/显示分栏
- 深色/浅色模式自动切换
- macOS 原生质感，支持 Stage Manager

### 任务管理
- 创建、编辑、删除、复制、标记完成任务
- 任务字段：标题、备注、截止日期、提醒时间、地点、优先级、标签、项目归属
- 回收站功能（删除后保留 30 天）
- 重复任务支持（按日/周/月/年）

### 智能语音任务创建（核心特色）
- 实时语音转文字（中文识别）
- 智能语义解析：
  - **时间识别**："明天下午3点"、"周五晚上8点"、"下周一"等口语化表达
  - **地点识别**："超市"、"公司"、"健身房"等
  - **优先级识别**："重要"、"紧急"、"别忘了"等关键词
  - **标题提取**：自动过滤冗余信息，生成简洁任务标题
- 解析完成后弹出预览界面，支持一键确认或手动修改

### 日历与视图
- 月历视图，显示公历日期与任务标记
- 点击日期切换任务列表
- 支持拖拽任务到日历日期分配时间
- 多视图：计划视图、列表视图、历史视图、回收站

### 提醒与通知
- 时间提醒：到达截止时间触发系统通知
- 地点提醒：到达/离开指定地点触发通知
- 重复提醒：支持周期性任务提醒

### 数据同步与备份
- SwiftData 本地持久化
- iCloud 同步（CloudKit）
- 导出 CSV / JSON 格式
- 数据恢复支持

### 个性化设置
- 自定义主题颜色
- 字体大小调节
- 默认启动视图设置
- 自定义快捷键
- 菜单栏常驻入口

## 项目结构

```
TaskMaster/
├── TaskMaster.xcodeproj/          # Xcode 项目文件
├── TaskMaster/
│   ├── TaskMasterApp.swift        # 应用入口
│   ├── Info.plist                 # 应用配置
│   ├── TaskMaster.entitlements    # 沙盒与权限配置
│   ├── Assets.xcassets/           # 图标与颜色资源
│   ├── Preview Content/           # SwiftUI 预览资源
│   ├── Models/                    # 数据模型
│   │   ├── TaskItem.swift         # 任务模型
│   │   ├── Project.swift          # 项目/标签模型
│   │   └── AppSettings.swift      # 应用设置模型
│   ├── Views/                     # 视图层
│   │   ├── MainView.swift         # 三栏主布局
│   │   ├── SidebarView.swift      # 左侧导航栏
│   │   ├── CalendarView.swift     # 中间日历面板
│   │   ├── TaskListView.swift     # 右侧任务列表
│   │   ├── TaskRowView.swift      # 任务行组件
│   │   ├── TaskEditorView.swift   # 任务编辑/创建
│   │   ├── VoiceInputView.swift   # 智能语音输入
│   │   ├── SearchView.swift       # 全局搜索
│   │   ├── SettingsView.swift     # 设置面板
│   │   └── MenuBarView.swift      # 菜单栏视图
│   ├── Services/                  # 业务服务
│   │   ├── SpeechRecognitionService.swift    # 语音识别
│   │   ├── NaturalLanguageService.swift      # 自然语言解析
│   │   ├── NotificationService.swift         # 本地通知
│   │   ├── LocationService.swift             # 定位服务
│   │   └── DataExportService.swift           # 数据导出
│   └── Utilities/                 # 工具扩展
│       ├── Date+Extensions.swift
│       ├── Color+Extensions.swift
│       └── String+Extensions.swift
└── README.md
```

## 编译与运行

### 使用 Xcode

1. 使用 Xcode 15.0+ 打开 `TaskMaster.xcodeproj`
2. 选择目标为 "My Mac (arm64)"
3. 点击 **Run** (⌘R) 编译并运行

### 使用命令行

```bash
# 编译项目
xcodebuild -project TaskMaster.xcodeproj -scheme TaskMaster -destination 'platform=macOS,arch=arm64' build

# 打包 Release
xcodebuild -project TaskMaster.xcodeproj -scheme TaskMaster -destination 'platform=macOS,arch=arm64' -configuration Release build
```

### 打包为 .dmg

```bash
# 1. 先编译 Release 版本
xcodebuild -project TaskMaster.xcodeproj -scheme TaskMaster -configuration Release -derivedDataPath ./build

# 2. 定位生成的 .app
APP_PATH="./build/Build/Products/Release/TaskMaster.app"

# 3. 创建 DMG
create-dmg \
  --volname "TaskMaster" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --app-drop-link 600 185 \
  "TaskMaster.dmg" \
  "$APP_PATH"
```

> **注意**: `create-dmg` 需通过 Homebrew 安装: `brew install create-dmg`

## 快捷键

| 快捷键 | 功能 |
|--------|------|
| ⌘N | 新建任务 |
| ⌘⇧V | 语音输入 |
| ⌘D | 完成任务 |
| ⌘1 | 切换视图 |
| ⌘F | 搜索任务 |

## 权限说明

首次使用以下功能时，系统会请求相应权限：

- **麦克风**: 语音任务创建需要语音识别
- **位置**: 地点提醒功能需要定位权限
- **通知**: 任务提醒需要通知权限

权限配置已写入 `Info.plist` 和 `TaskMaster.entitlements`。

## 技术栈

- **语言**: Swift 5.10+
- **UI 框架**: SwiftUI (纯原生，无第三方 UI 库)
- **数据存储**: SwiftData (本地持久化)
- **语音**: Speech Framework + NaturalLanguage
- **同步**: CloudKit (iCloud)
- **日历**: EventKit
- **定位**: CoreLocation

## M 系列芯片优化

- 仅编译 arm64 架构，无 Intel 兼容层
- 冷启动 < 1 秒
- 支持 1000+ 任务流畅滚动
- 低功耗后台运行
- 完美适配 macOS Sonoma+ 新特性

## 开发说明

### 代码规范
- 遵循 SwiftUI + SwiftData 最佳实践
- 使用 `@Observable` 进行状态管理
- 数据模型使用 `@Model` 宏
- 视图与业务逻辑分离

### 扩展开发

添加新的导航项：
```swift
// 在 NavigationItem enum 中添加新 case
enum NavigationItem: String, CaseIterable {
    case inbox = "收件箱"
    case plan = "计划"
    // ... 新增项
}
```

添加新的语音解析规则：
```swift
// 在 NaturalLanguageService.swift 中扩展解析逻辑
private func extractDate(from text: String) -> Date? {
    // 添加新的时间模式匹配
}
```

## 许可证

MIT License

---

**注意**: 本项目仅支持 Apple Silicon Mac (arm64)，不支持 Intel Mac。

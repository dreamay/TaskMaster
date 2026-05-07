import SwiftUI

struct VoiceInputView: View {
    @EnvironmentObject var store: TaskStore
    @Environment(\.dismiss) private var dismiss
    
    var onSave: () -> Void
    
    @StateObject private var speechService = SpeechRecognitionService()
    @StateObject private var nlpService = NaturalLanguageService()
    @State private var parsedInfo: ParsedTaskInfo?
    @State private var showPreview = false
    @State private var editingTitle = ""
    @State private var isProcessing = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("语音创建任务")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Button("关闭") {
                    if speechService.isRecording {
                        speechService.stopRecording()
                    }
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding(.horizontal)
            .padding(.top)
            
            if !showPreview {
                VStack(spacing: 24) {
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        if speechService.isRecording {
                            Circle()
                                .stroke(Color.red.opacity(0.3), lineWidth: 2)
                                .frame(width: 140, height: 140)
                        }
                        
                        Image(systemName: speechService.isRecording ? "waveform" : "mic.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                    }
                    
                    Text(speechService.recognizedText.isEmpty ? "点击开始说话..." : speechService.recognizedText)
                        .font(.system(size: 16))
                        .foregroundColor(speechService.recognizedText.isEmpty ? .secondary : .primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .frame(minHeight: 60)
                    
                    if let error = speechService.errorMessage {
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    Button(action: toggleRecording) {
                        HStack(spacing: 8) {
                            Image(systemName: speechService.isRecording ? "stop.fill" : "mic.fill")
                            Text(speechService.isRecording ? "停止" : "开始录音")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 160, height: 48)
                        .background(speechService.isRecording ? Color.orange : Color.red)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(isProcessing)
                    
                    if !speechService.recognizedText.isEmpty && !speechService.isRecording {
                        Button("解析并创建") {
                            parseAndPreview()
                        }
                        .font(.system(size: 14))
                    }
                    
                    Spacer()
                }
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("任务预览")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Group {
                        HStack {
                            Text("标题:")
                                .foregroundColor(.secondary)
                                .frame(width: 60, alignment: .trailing)
                            TextField("任务标题", text: $editingTitle)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        if let dueDate = parsedInfo?.dueDate {
                            HStack {
                                Text("时间:")
                                    .foregroundColor(.secondary)
                                    .frame(width: 60, alignment: .trailing)
                                Text(dueDate.formattedDateWithWeekday())
                                if dueDate != dueDate.startOfDay() {
                                    Text(dueDate.formattedTime())
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        if let location = parsedInfo?.location {
                            HStack {
                                Text("地点:")
                                    .foregroundColor(.secondary)
                                    .frame(width: 60, alignment: .trailing)
                                Text(location)
                            }
                        }
                        
                        if parsedInfo?.priority != Priority.none {
                            HStack {
                                Text("优先级:")
                                    .foregroundColor(.secondary)
                                    .frame(width: 60, alignment: .trailing)
                                HStack {
                                    Circle()
                                        .fill(parsedInfo!.priority.swiftUIColor())
                                        .frame(width: 8, height: 8)
                                    Text(parsedInfo!.priority.description)
                                }
                            }
                        }
                    }
                    .font(.system(size: 14))
                    
                    Spacer()
                    
                    HStack {
                        Button("重新录音") {
                            showPreview = false
                            speechService.recognizedText = ""
                            parsedInfo = nil
                        }
                        
                        Spacer()
                        
                        Button("保存任务") {
                            saveParsedTask()
                        }
                        .keyboardShortcut(.defaultAction)
                        .disabled(editingTitle.trimmed().isEmpty)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
    
    private func toggleRecording() {
        if speechService.isRecording {
            speechService.stopRecording()
        } else {
            Task {
                do {
                    try await speechService.startRecording()
                } catch {
                    speechService.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func parseAndPreview() {
        isProcessing = true
        let info = nlpService.parseTask(from: speechService.recognizedText)
        parsedInfo = info
        editingTitle = info.title
        showPreview = true
        isProcessing = false
    }
    
    private func saveParsedTask() {
        guard let info = parsedInfo else { return }
        
        let newTask = TaskItem(
            title: editingTitle.trimmed(),
            notes: info.notes,
            dueDate: info.dueDate,
            reminderDate: info.reminderDate,
            location: info.location,
            priority: info.priority,
            tags: info.tags
        )
        
        store.addTask(newTask)
        
        if info.dueDate != nil || info.reminderDate != nil {
            NotificationService.shared.scheduleNotification(for: newTask)
        }
        
        onSave()
    }
}

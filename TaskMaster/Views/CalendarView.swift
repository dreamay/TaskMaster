import SwiftUI
import AppKit

struct CalendarView: View {
    @Binding var selectedDate: Date
    let tasks: [TaskItem]
    
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let weekdaySymbols = ["日", "一", "二", "三", "四", "五", "六"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Month header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(currentMonth.formattedMonthYear())
                    .font(.system(size: 15, weight: .semibold))
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                let days = daysInMonth()
                ForEach(0..<days.count, id: \.self) { index in
                    if let date = days[index] {
                        DayCell(
                            date: date,
                            isSelected: date.isSameDay(as: selectedDate),
                            isToday: date.isToday(),
                            taskCount: tasksForDate(date).count,
                            hasHighPriority: hasHighPriorityTask(on: date)
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            .padding(.horizontal, 8)
            
            Spacer()
        }
        .background(Color(NSColor.windowBackgroundColor).opacity(0.9))
    }
    
    private func daysInMonth() -> [Date?] {
        guard let daysCount = calendar.daysInMonth(for: currentMonth) else { return [] }
        let firstWeekday = calendar.firstWeekdayOfMonth(for: currentMonth)
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        let monthComponents = calendar.dateComponents([.year, .month], from: currentMonth)
        for day in 1...daysCount {
            var components = monthComponents
            components.day = day
            if let date = calendar.date(from: components) {
                days.append(date)
            }
        }
        
        // Pad to complete the grid
        let remaining = (7 - (days.count % 7)) % 7
        days.append(contentsOf: Array(repeating: nil, count: remaining))
        
        return days
    }
    
    private func tasksForDate(_ date: Date) -> [TaskItem] {
        tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate.isSameDay(as: date)
        }
    }
    
    private func hasHighPriorityTask(on date: Date) -> Bool {
        tasksForDate(date).contains { $0.priority == .high }
    }
    
    private func previousMonth() {
        currentMonth = currentMonth.adding(months: -1)
    }
    
    private func nextMonth() {
        currentMonth = currentMonth.adding(months: 1)
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let taskCount: Int
    let hasHighPriority: Bool
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 13, weight: isToday ? .bold : .regular))
                .foregroundColor(foregroundColor)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(backgroundColor)
                )
            
            // Task indicators
            if taskCount > 0 {
                HStack(spacing: 2) {
                    ForEach(0..<min(taskCount, 3), id: \.self) { _ in
                        Circle()
                            .fill(hasHighPriority ? Color.red : Color.accentColor)
                            .frame(width: 4, height: 4)
                    }
                }
            } else {
                Color.clear
                    .frame(height: 4)
            }
        }
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered ? Color.primary.opacity(0.06) : Color.clear)
        )
        .onHover { hovering in
            isHovered = hovering
        }
    }
    
    private var foregroundColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .accentColor
        }
        return .primary
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .accentColor
        } else if isToday {
            return .accentColor.opacity(0.15)
        }
        return Color.clear
    }
}

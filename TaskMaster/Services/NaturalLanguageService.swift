import Foundation
import NaturalLanguage
import Combine

struct ParsedTaskInfo {
    var title: String
    var dueDate: Date?
    var location: String?
    var priority: Priority
    var reminderDate: Date?
    var tags: [String]
    var notes: String
}

class NaturalLanguageService: ObservableObject {
    
    func parseTask(from text: String) -> ParsedTaskInfo {
        var result = ParsedTaskInfo(
            title: text,
            dueDate: nil,
            location: nil,
            priority: .none,
            reminderDate: nil,
            tags: [],
            notes: ""
        )
        
        let trimmedText = text.trimmed()
        
        result.priority = extractPriority(from: trimmedText)
        
        if let date = extractDate(from: trimmedText) {
            result.dueDate = date
        }
        
        if let location = extractLocation(from: trimmedText) {
            result.location = location
        }
        
        result.title = extractCleanTitle(from: trimmedText, date: result.dueDate, location: result.location)
        
        return result
    }
    
    private func extractPriority(from text: String) -> Priority {
        let highKeywords = ["重要", "紧急", "别忘了", "必须", "一定要"]
        let mediumKeywords = ["记得", "注意", "提醒"]
        
        for keyword in highKeywords {
            if text.contains(keyword) { return .high }
        }
        for keyword in mediumKeywords {
            if text.contains(keyword) { return .medium }
        }
        return .none
    }
    
    private func extractDate(from text: String) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        var targetDate = now.startOfDay()
        var targetTime: DateComponents?
        
        let timePatterns: [(String, Int)] = [
            ("([上下]午|早上|晚上|中午|凌晨)?\\s*(\\d+)点(\\d+)?分?", 0),
            ("([上下]午|早上|晚上|中午|凌晨)?\\s*(\\d+)[:：](\\d+)", 0)
        ]
        
        for (pattern, _) in timePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) {
                
                let hourRange = match.range(at: 2)
                let minuteRange = match.range(at: 3)
                
                if let hourRange = Range(hourRange, in: text),
                   let hour = Int(text[hourRange]) {
                    var adjustedHour = hour
                    
                    let periodRange = match.range(at: 1)
                    if let periodRange = Range(periodRange, in: text) {
                        let period = String(text[periodRange])
                        if period.contains("下午") || period.contains("晚上") {
                            if adjustedHour < 12 { adjustedHour += 12 }
                        } else if period.contains("上午") || period.contains("早上") || period.contains("凌晨") {
                            if adjustedHour == 12 { adjustedHour = 0 }
                        }
                    }
                    
                    var components = DateComponents()
                    components.hour = adjustedHour
                    components.minute = 0
                    if let minuteRange = Range(minuteRange, in: text),
                       let minute = Int(text[minuteRange]) {
                        components.minute = minute
                    }
                    targetTime = components
                }
            }
        }
        
        if text.contains("今天") {
            targetDate = now.startOfDay()
        } else if text.contains("明天") {
            targetDate = now.adding(days: 1).startOfDay()
        } else if text.contains("后天") {
            targetDate = now.adding(days: 2).startOfDay()
        } else if text.contains("大后天") {
            targetDate = now.adding(days: 3).startOfDay()
        }
        
        let weekdayPatterns = ["星期([一二三四五六日])", "周([一二三四五六日])", "(周日|周一|周二|周三|周四|周五|周六)"]
        
        for pattern in weekdayPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) {
                
                if let range = Range(match.range, in: text) {
                    let matched = String(text[range])
                    let weekdayMap: [String: Int] = [
                        "周一": 2, "周二": 3, "周三": 4, "周四": 5, "周五": 6, "周六": 7, "周日": 1,
                        "星期一": 2, "星期二": 3, "星期三": 4, "星期四": 5, "星期五": 6, "星期六": 7, "星期日": 1
                    ]
                    
                    if let targetWeekday = weekdayMap[matched] {
                        let currentWeekday = now.weekday()
                        var daysToAdd = targetWeekday - currentWeekday
                        if daysToAdd <= 0 {
                            daysToAdd += 7
                        }
                        
                        if text.contains("下个") || text.contains("下") {
                            if let nextRange = text.range(of: "下"),
                               text.distance(from: text.startIndex, to: nextRange.lowerBound) < text.distance(from: text.startIndex, to: range.lowerBound) {
                                daysToAdd += 7
                            }
                        }
                        
                        targetDate = now.adding(days: daysToAdd).startOfDay()
                    }
                }
            }
        }
        
        if let regex = try? NSRegularExpression(pattern: "(\\d+)月(\\d+)[日号]", options: []),
           let match = regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) {
            
            if let monthRange = Range(match.range(at: 1), in: text),
               let dayRange = Range(match.range(at: 2), in: text),
               let month = Int(text[monthRange]),
               let day = Int(text[dayRange]) {
                
                var components = calendar.dateComponents([.year], from: now)
                components.month = month
                components.day = day
                if let date = calendar.date(from: components) {
                    targetDate = date
                }
            }
        }
        
        if let timeComponents = targetTime {
            var finalComponents = calendar.dateComponents([.year, .month, .day], from: targetDate)
            finalComponents.hour = timeComponents.hour
            finalComponents.minute = timeComponents.minute
            return calendar.date(from: finalComponents)
        }
        
        return targetDate
    }
    
    private func extractLocation(from text: String) -> String? {
        let locationPatterns = [
            "去(.*?)(买|做|找|拿|办|看|见|开会|锻炼|运动)",
            "在(.*?)(买|做|找|拿|办|看|见|开会|锻炼|运动)",
            "到(.*?)(买|做|找|拿|办|看|见|开会|锻炼|运动)",
            "去(.+?)[了来]?"
        ]
        
        let commonLocations = ["公司", "家", "超市", "健身房", "图书馆", "医院", "学校", "银行", "邮局", "机场", "火车站", "地铁站"]
        
        for location in commonLocations {
            if text.contains(location) {
                return location
            }
        }
        
        for pattern in locationPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) {
                if let range = Range(match.range(at: 1), in: text) {
                    let location = String(text[range]).trimmed()
                    if !location.isEmpty && location.count < 20 {
                        return location
                    }
                }
            }
        }
        
        return nil
    }
    
    private func extractCleanTitle(from text: String, date: Date?, location: String?) -> String {
        var title = text
        
        let timeRemovals = [
            "今天", "明天", "后天", "大后天",
            "上午", "下午", "晚上", "早上", "中午", "凌晨",
            "下周一", "下周二", "下周三", "下周四", "下周五", "下周六", "下周日",
            "星期[一二三四五六日]", "周[一二三四五六日]",
            "\\d+月\\d+[日号]", "\\d+点\\d*分?", "\\d+[:：]\\d+",
            "重要", "紧急", "别忘了", "必须", "一定要", "记得", "注意", "提醒"
        ]
        
        for pattern in timeRemovals {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                title = regex.stringByReplacingMatches(in: title, options: [], range: NSRange(location: 0, length: title.utf16.count), withTemplate: "")
            }
        }
        
        if let location = location {
            title = title.replacingOccurrences(of: "去\(location)", with: "")
            title = title.replacingOccurrences(of: "在\(location)", with: "")
            title = title.replacingOccurrences(of: "到\(location)", with: "")
            title = title.replacingOccurrences(of: location, with: "")
        }
        
        title = title.replacingOccurrences(of: "  ", with: " ")
        title = title.trimmed()
        
        let particles = ["去", "在", "到", "把", "将", "要", "想"]
        for particle in particles {
            if title.hasPrefix(particle) {
                title = String(title.dropFirst(particle.count)).trimmed()
            }
        }
        
        if title.isEmpty {
            return "新任务"
        }
        
        return title
    }
}

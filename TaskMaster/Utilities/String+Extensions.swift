import Foundation

extension String {
    func trimmed() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func containsChinese() -> Bool {
        self.range(of: "\\p{Han}", options: .regularExpression) != nil
    }
    
    func extractTimeKeywords() -> [String] {
        let patterns = [
            "今天", "明天", "后天", "大后天",
            "周一", "周二", "周三", "周四", "周五", "周六", "周日", "星期[一二三四五六日]",
            "下(周一|周二|周三|周四|周五|周六|周日|星期[一二三四五六日])",
            "[上下]午", "早上", "晚上", "中午", "凌晨",
            "\\d+点", "\\d+[:：]\\d+", "\\d+月\\d+[日号]"
        ]
        
        var results: [String] = []
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
                if let range = Range(match.range, in: self) {
                    results.append(String(self[range]))
                }
            }
        }
        return results
    }
}

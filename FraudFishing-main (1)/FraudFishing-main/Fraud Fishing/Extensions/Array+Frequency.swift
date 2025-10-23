import Foundation

extension Array where Element: Hashable {
    func mostFrequent() -> Element? {
        guard !isEmpty else { return nil }
        var counts: [Element: Int] = [:]
        for e in self { counts[e, default: 0] += 1 }
        return counts.max(by: { $0.value < $1.value })?.key
    }

    func frequencySorted() -> [Element] {
        var counts: [Element: Int] = [:]
        for e in self { counts[e, default: 0] += 1 }
        return counts.sorted { $0.value > $1.value }.map { $0.key }
    }
}
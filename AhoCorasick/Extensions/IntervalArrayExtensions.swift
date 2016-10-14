import Foundation

extension Array where Element: Interval {
    var median: Int? {
        guard let first = first else { return nil }

        var start = first.start
        var end = first.end

        for interval in self {
            let currentStart = interval.start
            let currentEnd = interval.end

            if currentStart < start {
                start = currentStart
            }
            if currentEnd > end {
                end = currentEnd
            }
        }
        return (start + end) / 2
    }
}

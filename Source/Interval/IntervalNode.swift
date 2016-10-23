private enum Direction {
    case left, right
}

public class IntervalNode<T: Interval> {

    private var left: IntervalNode?
    private var right: IntervalNode?

    private var point: Int

    private var intervals: [T] = []

    public init(intervals: [T]) {
        point = intervals.median ?? 0

        var toLeft = [T]()
        var toRight = [T]()

        for interval in intervals {
            if interval.end < point {
                toLeft.append(interval)
            } else if interval.start > point {
                toRight.append(interval)
            } else {
                self.intervals.append(interval)
            }
        }

        if !toLeft.isEmpty {
            left = IntervalNode(intervals: toLeft)
        }
        if !toRight.isEmpty {
            right = IntervalNode(intervals: toRight)
        }
    }


    public func findOverlaps(interval: T) -> [T] {

        var overlaps = [T]()

        if point < interval.start {
            overlaps += overlap(interval: interval, newOverlaps: findOverlappingRanges(node: right, interval: interval))
            overlaps += overlap(interval: interval, newOverlaps: checkForOverlaps(in: interval, toThe: .right))
        } else if point > interval.end {
            overlaps += overlap(interval: interval, newOverlaps: findOverlappingRanges(node: left, interval: interval))
            overlaps += overlap(interval: interval, newOverlaps: checkForOverlaps(in: interval, toThe: .left))
        } else {
            overlaps += overlap(interval: interval, newOverlaps: self.intervals)
            overlaps += overlap(interval: interval, newOverlaps: findOverlappingRanges(node: left, interval: interval))
            overlaps += overlap(interval: interval, newOverlaps: findOverlappingRanges(node: right, interval: interval))
        }

        return overlaps;
    }

    private func overlap(interval: T, newOverlaps: [T]) -> [T] {
        return newOverlaps.filter { $0 != interval }
    }

    private func checkForOverlaps(in interval: T, toThe direction: Direction) -> [T] {

        var overlaps = [T]()

        for currentInterval in self.intervals {
            switch direction {
            case .left:
                if currentInterval.start <= interval.end {
                    overlaps.append(currentInterval)
                }
            case .right:
                if currentInterval.end >= interval.start {
                    overlaps.append(currentInterval)
                }
            }
        }

        return overlaps
    }

    private func findOverlappingRanges(node: IntervalNode?, interval: T) -> [T] {
        return node?.findOverlaps(interval: interval) ?? []
    }

}

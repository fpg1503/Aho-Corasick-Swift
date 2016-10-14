func sizeSorter<T: Interval>(lhs: T, rhs: T) -> Bool {
    if lhs.size == rhs.size {
        return positionSorter(lhs: lhs, rhs: rhs)
    } else {
        return lhs.size > rhs.size
    }
}

func positionSorter<T: Interval>(lhs: T, rhs: T) -> Bool {
    return lhs.start <= rhs.start
}

public class IntervalTree<T: Interval> {

    private var rootNode: IntervalNode<T>

    public init(intervals: [T]) {
        rootNode = IntervalNode(intervals: intervals)
    }

    public func removeOverlaps(intervals: [T]) -> [T] {

        let intervalsSortedBySize = intervals.sorted(by: sizeSorter)
        
        var removedIntervals: Set<T> = []

        for interval in intervalsSortedBySize {
            if !removedIntervals.contains(interval) {
                let overlaps = findOverlaps(interval: interval)
                for overlap in overlaps {
                    removedIntervals.insert(overlap)
                }
            }
        }

        let intervalsRemovingRemoved = Set(intervals).subtracting(removedIntervals)

        return Array(intervalsRemovingRemoved).sorted(by: positionSorter)
    }

    public func findOverlaps(interval: T) -> [T] {
        return rootNode.findOverlaps(interval: interval)
    }
}

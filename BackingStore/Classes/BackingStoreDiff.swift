import UIKit

/// Object that calculate and represents the various changes that could be a applied
/// during a batch update of a table view or collection view.
public struct BackingStoreDiff {
    
    public struct Move {
        public let origin: IndexPath
        public let destination: IndexPath
    }
    
    public let insertedIndexPaths: [IndexPath]
    public let deletedIndexPaths: [IndexPath]
    public let insertedSections: [Int]
    public let deletedSections: [Int]
    
    public let movedIndexPaths: [Move]
    
    public init?<SectionType: Hashable & Comparable>(from oldValues: [SectionType: NSOrderedSet], to newValues: [SectionType: NSOrderedSet]) {
        var insertedIndexPaths: [IndexPath] = []
        var deletedIndexPaths: [IndexPath] = []
        var insertedSections: [Int] = []
        var deletedSections: [Int] = []
        var movedIndexPaths: [Move] = []
        
        for (sectionIndex, sectionType) in Array(newValues.keys).sorted().enumerated() {
            if oldValues[sectionType] == nil {
                insertedSections.append(sectionIndex)
            } else {
                let newItems = newValues[sectionType] ?? NSOrderedSet()
                let oldItems = oldValues[sectionType] ?? NSOrderedSet()
                insertedIndexPaths += newItems.indexPathsForInsertedItems(from: oldItems, section: sectionIndex)
            }
        }
        
        for (sectionIndex, sectionType) in Array(oldValues.keys).sorted().enumerated() {
            if newValues[sectionType] == nil {
                deletedSections.append(sectionIndex)
            } else {
                let newItems = newValues[sectionType] ??  NSOrderedSet()
                let oldItems = oldValues[sectionType] ??  NSOrderedSet()
                deletedIndexPaths += newItems.indexPathsForDeletedItems(from: oldItems, section: sectionIndex)
            }
        }
        
        for (sectionIndex, sectionType) in Array(newValues.keys).sorted().enumerated() {
            guard let oldValue = oldValues[sectionType],
                let newValue = newValues[sectionType] else {
                    continue
            }
            movedIndexPaths += newValue.enumerated().compactMap { newIndex, item in
                let oldIndex = oldValue.index(of: item)
                guard oldIndex != NSNotFound, oldIndex != newIndex else {
                    return nil
                }
                let origin = IndexPath(item: oldIndex, section: sectionIndex)
                let destination = IndexPath(item: newIndex, section: sectionIndex)
                guard !deletedSections.contains(sectionIndex),
                    !insertedIndexPaths.contains(destination),
                    !insertedSections.contains(sectionIndex),
                    !insertedIndexPaths.contains(destination) else {
                    return nil
                }
                return BackingStoreDiff.Move( origin: origin, destination: destination)
            }
        }
        
        guard !insertedIndexPaths.isEmpty
            || !deletedIndexPaths.isEmpty
            || !insertedSections.isEmpty
            || !movedIndexPaths.isEmpty
            || !deletedSections.isEmpty else {
                return nil
        }
        
        self.insertedIndexPaths = insertedIndexPaths
        self.deletedIndexPaths = deletedIndexPaths
        self.insertedSections = insertedSections
        self.deletedSections = deletedSections
        self.movedIndexPaths = movedIndexPaths
    }
}

private extension NSOrderedSet {
    
    func indexPathsForDeletedItems(from orderedSet: NSOrderedSet = NSOrderedSet(), section: Int) -> [IndexPath] {
        let deletedItems = orderedSet.array.filter { !contains($0) }
        return deletedItems.map {
            let index = orderedSet.index(of: $0)
            return IndexPath(item: index, section: section)
        }
    }
    
    func indexPathsForInsertedItems(from orderedSet: NSOrderedSet = NSOrderedSet(), section: Int) -> [IndexPath] {
        let insertedItems = array.filter { !orderedSet.contains($0) }
        return insertedItems.map {
            let index = self.index(of: $0)
            return IndexPath(item: index, section: section)
        }
    }
}

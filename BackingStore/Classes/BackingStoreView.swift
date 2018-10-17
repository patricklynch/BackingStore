import UIKit

/// Defines an object that inserts, deleletes and reloads cells and sections in a collection view
/// See extension for `UICollectionView`
public protocol BackingStoreView: class {
    func update(diff: BackingStoreDiff, completion: (()->())?)
    func redecorateItems(section: Int, in dataSource: BackingStoreDataSource, animated: Bool)
    func redecorateVisibleItems(in dataSource: BackingStoreDataSource, animated: Bool)
    func reloadAll(animated: Bool, completion: (()->())?)
}

extension UICollectionView: BackingStoreView {
    
    public func redecorateVisibleItems(in dataSource: BackingStoreDataSource, animated: Bool) {
        for indexPath in indexPathsForVisibleItems {
            if let cell = cellForItem(at: indexPath) {
                dataSource.decorate(cell: cell, at: indexPath, animated: animated)
            }
        }
    }
    
    public func redecorateItems(section: Int, in dataSource: BackingStoreDataSource, animated: Bool) {
        for indexPath in indexPathsForVisibleItems.filter({ $0.section == section }) {
            if let cell = cellForItem(at: indexPath) {
                dataSource.decorate(cell: cell, at: indexPath, animated: animated)
            }
        }
    }
    
    public func update(diff: BackingStoreDiff, completion: (()->())?) {
        performBatchUpdates(
            {
                if !diff.insertedSections.isEmpty {
                    self.insertSections(IndexSet(diff.insertedSections))
                }
                if !diff.insertedIndexPaths.isEmpty {
                    self.insertItems(at: diff.insertedIndexPaths)
                }
                
                if !diff.deletedSections.isEmpty {
                    self.deleteSections(IndexSet(diff.deletedSections))
                }
                if !diff.deletedIndexPaths.isEmpty {
                    self.deleteItems(at: diff.deletedIndexPaths)
                }
                
                for move in diff.movedIndexPaths {
                    self.moveItem(at: move.origin, to: move.destination)
                }
        },
            completion: { _ in completion?() }
        )
    }
    
    public func reloadAll(animated: Bool, completion: (()->())?) {
        if !animated {
            reloadData()
            completion?()
        } else {
            performBatchUpdates(
                {
                    self.reloadData()
            },
                completion: { _ in completion?() }
            )
        }
    }
}

extension UITableView: BackingStoreView {
    
    public func redecorateVisibleItems(in dataSource: BackingStoreDataSource, animated: Bool) {
        beginUpdates()
        for cell in visibleCells {
            if let indexPath = indexPath(for: cell) {
                dataSource.decorate(cell: cell, at: indexPath, animated: animated)
            }
        }
        endUpdates()
    }
    
    public func redecorateItems(section: Int, in dataSource: BackingStoreDataSource, animated: Bool) {
        for cell in visibleCells {
            if let indexPath = indexPath(for: cell), indexPath.section == section {
                dataSource.decorate(cell: cell, at: indexPath, animated: animated)
            }
        }
    }
    
    public func reload(sections: [Int], animated: Bool) {
        if animated {
            beginUpdates()
        }
        reloadSections(IndexSet(sections), with: .automatic)
        if animated {
            endUpdates()
        }
    }
    
    public func update(diff: BackingStoreDiff, completion: (()->())?) {
        beginUpdates()
        if !diff.insertedSections.isEmpty {
            insertSections(IndexSet(diff.insertedSections), with: .fade)
        }
        if !diff.insertedIndexPaths.isEmpty {
            insertRows(at: diff.insertedIndexPaths, with: .fade)
        }
        if !diff.deletedSections.isEmpty {
            deleteSections(IndexSet(diff.deletedSections), with: .fade)
        }
        if !diff.deletedIndexPaths.isEmpty {
            deleteRows(at: diff.deletedIndexPaths, with: .fade)
        }
        for move in diff.movedIndexPaths {
            moveRow(at: move.origin, to: move.destination)
        }
        endUpdates()
        completion?()
    }
    
    public func reloadAll(animated: Bool, completion: (()->())?) {
        if !animated {
            reloadData()
        } else {
            beginUpdates()
            reloadData()
            endUpdates()
        }
        completion?()
    }
}

private extension Array where Element : NSOrderedSet {
    
    var isEmpty: Bool {
        return reduce([], { $0 + $1.array }).isEmpty
    }
}

extension NSOrderedSet {
    
    public func appending(_ objects: [Any]) -> NSOrderedSet {
        return NSOrderedSet(array: self.array + objects)
    }
}


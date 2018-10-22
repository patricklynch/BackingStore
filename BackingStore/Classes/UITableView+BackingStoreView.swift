import UIKit

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

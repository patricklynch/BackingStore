import UIKit

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

import UIKit

/// Defines an object that inserts, deleletes and reloads cells and sections in a collection view
/// See extension for `UICollectionView`
public protocol BackingStoreView: class {
    func update(diff: BackingStoreDiff, completion: (()->())?)
    func redecorateItems(section: Int, with decorator: BackingStoreDecorator, animated: Bool)
    func redecorateVisibleItems(with decorator: BackingStoreDecorator, animated: Bool)
    func reloadAll(animated: Bool, completion: (()->())?)
}

extension Array where Element : NSOrderedSet {
    
    var isEmpty: Bool {
        return reduce([], { $0 + $1.array }).isEmpty
    }
}

extension NSOrderedSet {
    
    public func appending(_ objects: [Any]) -> NSOrderedSet {
        return NSOrderedSet(array: self.array + objects)
    }
}


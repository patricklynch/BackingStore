import UIKit

public protocol BackingStoreDataSource: class {
    var backingStoreView: BackingStoreView? { get set }
    func decorate(cell: UIView, at indexPath: IndexPath, animated: Bool)
}

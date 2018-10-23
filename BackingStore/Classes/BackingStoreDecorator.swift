import UIKit

public protocol BackingStoreDecorator: class {
    func decorate(cell: UIView, at indexPath: IndexPath, animated: Bool)
}

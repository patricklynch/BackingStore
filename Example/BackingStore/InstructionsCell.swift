import UIKit

class InstructionsCell: UITableViewCell {
    
    @IBOutlet private weak var mainTextLabel: UILabel!
    
    struct ViewData {
        let text: String
    }
    
    var viewData: ViewData? {
        didSet {
            mainTextLabel.text = viewData?.text
        }
    }
}

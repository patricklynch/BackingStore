import Foundation

enum SingleSectionType: Int, Hashable, Comparable {
    case `default`
    
    var hashValue: Int {
        return rawValue.hashValue
    }
    
    static func <(lhs: SingleSectionType, rhs: SingleSectionType) -> Bool {
        return false
    }
}

extension BackingStore where SectionType == SingleSectionType {
    
    var isEmpty: Bool {
        return section(at: 0)?.isEmpty ?? true
    }
    
    var itemCount: Int {
        return section(at: 0)?.itemCount ?? 0
    }
    
    var allItems: [Any] {
        return section(at: 0)?.allItems ?? []
    }
    
    func item(at index: Int) -> Any? {
        return section(at: 0)?.visibleItems.array[safe: index]
    }
    
    func update(
        items: [Any],
        header: Any? = nil,
        footer: Any? = nil,
        dataSource: BackingStoreDataSource,
        completion : (()->Void)? = nil) {
        
        let headers: [SingleSectionType: Any]
        if let header = header {
            headers = [.default: header]
        } else {
            headers = [:]
        }
        
        let footers: [SingleSectionType: Any]
        if let footer = footer {
            footers = [.default: footer]
        } else {
            footers = [:]
        }
        
        update(
            itemsForSections: [
                SingleSectionType.default: items
            ],
            headers: headers,
            footers: footers,
            dataSource: dataSource,
            completion: completion
        )
    }
}

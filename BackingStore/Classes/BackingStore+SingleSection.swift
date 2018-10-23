import Foundation

public enum SingleSectionType: Int, Hashable, Comparable {
    case `default`
    
    public var hashValue: Int {
        return rawValue.hashValue
    }
}

extension BackingStore where SectionType == SingleSectionType {
    
    public var isEmpty: Bool {
        return section(at: 0)?.isEmpty ?? true
    }
    
    public var itemCount: Int {
        return section(at: 0)?.itemCount ?? 0
    }
    
    public var allItems: [Any] {
        return section(at: 0)?.allItems ?? []
    }
    
    public func item(at index: Int) -> Any? {
        return section(at: 0)?.visibleItems.array[safe: index]
    }
    
    public func update(
        items: [Any],
        header: Any? = nil,
        footer: Any? = nil,
        animated: Bool = true,
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
            animated: animated,
            completion: completion
        )
    }
}

extension Collection {
    subscript(safe index: Index) -> Iterator.Element? {
        return startIndex..<endIndex ~= index ? self[index] : nil
    }
}

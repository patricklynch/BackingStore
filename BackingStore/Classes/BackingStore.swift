import UIKit

public final class BackingStore<SectionType: Hashable & Comparable> {
    
    public class Section {
        public let type: SectionType
        
        var header: Any? = nil
        var footer: Any? = nil
        
        init(type: SectionType, visibleItems: NSOrderedSet) {
            self.type = type
            self.visibleItems = visibleItems
        }
        
        public var isEmpty: Bool {
            return visibleItems.count == 0
        }
        
        public var itemCount: Int {
            return visibleItems.count
        }
        
        public var allItems: [Any] {
            return visibleItems.array
        }
        
        var visibleItems = NSOrderedSet()
    }
    
    public init() {}
    
    private var batchUpdateQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private var sections: [Section] = []
    
    public func section(for type: SectionType) -> Section? {
        return sections.first { $0.type == type }
    }
    
    public func index(of type: SectionType) -> Int? {
        guard let index = sections.index(where: { $0.type == type }) else {
            return nil
        }
        return Int(index)
    }
    
    public func section(at indexPath: IndexPath) -> Section? {
        return section(at: indexPath.section)
    }
    
    public func item(at indexPath: IndexPath) -> Any? {
        return sections[safe: indexPath.section]?.visibleItems.array[safe: indexPath.item]
    }
    
    public func section(at index: Int) -> Section? {
        return sections[safe: index]
    }
    
    public var sectionCount: Int {
        return sections.count
    }
    
    public func header(at index: Int) -> Any? {
        return sections[safe: index]?.header
    }
    
    public func footer(at index: Int) -> Any? {
        return sections[safe: index]?.footer
    }
    
    func dictionaryRepresentation() -> [SectionType: NSOrderedSet] {
        return self.sections.reduce([:]) { dictionary, section in
            var dictionary = dictionary
            dictionary[section.type] = section.visibleItems
            return dictionary
        }
    }
    
    public func find<T>(matching isMatching: (T, IndexPath) -> Bool) -> T? {
        for (sectionIndex, section) in sections.enumerated() {
            for (itemIndex, item) in section.allItems.enumerated() {
                let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                if let typedItem = item as? T, isMatching(typedItem, indexPath) {
                    return typedItem
                }
            }
        }
        return nil
    }
    
    private func update(headers: [SectionType: Any]?, footers: [SectionType: Any]?) {
        if let headers = headers {
            sections.forEach { $0.header = headers[$0.type] }
        }
        if let footers = footers {
            sections.forEach { $0.footer = footers[$0.type] }
        }
    }
    
    private func sections(from itemsForSections: [SectionType: [Any]]) -> [Section] {
        return Array(itemsForSections.keys).sorted().map { sectionType in
            let items = itemsForSections[sectionType] ?? []
            return Section(
                type: sectionType,
                visibleItems: NSOrderedSet(array: items)
            )
        }
    }
    
    public func update(
        itemsForSections: [SectionType: [Any]],
        headers: [SectionType: Any]? = nil,
        footers: [SectionType: Any]? = nil,
        dataSource: BackingStoreDataSource,
        animated: Bool = true,
        completion updateCompletion: (()->Void)? = nil) {
        
        guard animated else {
            self.sections = self.sections(from: itemsForSections)
            update(headers: headers, footers: footers)
            dataSource.backingStoreView?.reloadAll(animated: false) {
                updateCompletion?()

            }
            return
        }
        
        for operation in batchUpdateQueue.operations {
            if !operation.isExecuting {
                operation.cancel()
            }
        }
        
        let batchUpdate = MainQueueBlockOperation { op in
            guard let delegate = dataSource.backingStoreView else {
                op.cancel()
                return
            }
            guard !op.isCancelled else {
                return
            }
            
            let oldValues = self.dictionaryRepresentation()
            self.sections = self.sections(from: itemsForSections)
            let newValues = self.dictionaryRepresentation()
            self.update(headers: headers, footers: footers)
            
            DispatchQueue.global(qos: .userInitiated).async {
                if let diff = BackingStoreDiff(from: oldValues, to: newValues) {
                    DispatchQueue.main.async {
                        delegate.update(diff: diff) {
                            op.finish()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        op.finish()
                    }
                }
            }
        }
        batchUpdateQueue.addOperation(batchUpdate)
        
        let redeorate = MainQueueBlockOperation { redeorate in
            guard let delegate = dataSource.backingStoreView, !redeorate.isCancelled else {
                redeorate.finish()
                return
            }
            delegate.redecorateVisibleItems(in: dataSource, animated: true)
            redeorate.finish()
        }
        redeorate.completionBlock = {
            DispatchQueue.main.async {
                updateCompletion?()
            }
        }
        batchUpdateQueue.addOperation(redeorate)
    }
}

private class MainQueueBlockOperation: Operation {
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    let block: (MainQueueBlockOperation) -> ()
    
    init(block: @escaping (MainQueueBlockOperation) -> ()) {
        self.block = block
    }
    
    override func main() {
        DispatchQueue.main.async() { [weak self] in
            guard let self = self else { return }
            guard !self.isCancelled && !self.isFinished else {
                self.semaphore.signal()
                return
            }
            self.block(self)
        }
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    override func cancel() {
        super.cancel()
        
        semaphore.signal()
    }
    
    func finish() {
        semaphore.signal()
    }
}

public extension RawRepresentable where RawValue : Comparable {
    
    static func <(lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

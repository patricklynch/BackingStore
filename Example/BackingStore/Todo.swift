import Foundation

class Todo: Codable, Hashable, Comparable {
    static func < (lhs: Todo, rhs: Todo) -> Bool {
        return lhs.dateUpdated > rhs.dateUpdated
    }
    
    static func == (lhs: Todo, rhs: Todo) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: Int
    let title: String
    var completed: Bool {
        didSet {
            dateUpdated = Date()
        }
    }
    private(set) var dateUpdated = Date()
    let userId: Int?
    
    init(title: String) {
        self.title = title
        id = (100..<100000).randomElement() ?? 0
        completed = false
        userId = nil
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, title, completed, userId
    }
    
    var hashValue: Int {
        return id.hashValue
    }
}

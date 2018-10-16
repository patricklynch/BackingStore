import UIKit
import BackingStore

class TodoDataSource: NSObject, UITableViewDataSource, BackingStoreDataSource {
    
    enum SectionType: Int, Comparable {
        static func < (lhs: TodoDataSource.SectionType, rhs: TodoDataSource.SectionType) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
        
        case notCompleted, completed
    }
    
    var allTodos: [Todo] = [] {
        didSet {
            onContentUpdated()
        }
    }
    
    func onContentUpdated() {
        backingStore.update(
            itemsForSections: Dictionary(grouping: allTodos.sorted()) { todo in
                return todo.completed ? SectionType.completed : SectionType.notCompleted
            },
            dataSource: self
        )
    }
    
    func registerCells(in tableView: UITableView) {
        tableView.register(
            UINib(nibName: "TodoCell", bundle: nil),
            forCellReuseIdentifier: "TodoCell"
        )
    }
    
    // MARK: - BackingStoreTodoDataSource
    
    let backingStore = BackingStore<SectionType>()
    
    var backingStoreView: BackingStoreView?
    
    func decorate(cell: UIView, at indexPath: IndexPath, animated: Bool) {
        guard let cell = cell as? TodoCell,
            let todo = backingStore.item(at: indexPath) as? Todo else {
                return
        }
        
        cell.viewData = TodoCell.ViewData(
            title: todo.title.localizedCapitalized,
            subtitle: todo.completed ? "Completed" : "Not Completed"
        )
    }
    
    // MARK: - UITableViewTodoDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return backingStore.sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return backingStore.section(at: section)?.itemCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if backingStore.item(at: indexPath) is Todo {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
            decorate(cell: cell, at: indexPath, animated: false)
            return cell
        } else {
            fatalError("Unsupported data type.")
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete,
            let selectedTodo = backingStore.item(at: indexPath) as? Todo else {
                return
        }
        allTodos = allTodos.filter { todo in
            return todo != selectedTodo
        }
    }
}


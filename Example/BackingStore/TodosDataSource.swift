import UIKit
import BackingStore

class TodoDataSource: NSObject, UITableViewDataSource, BackingStoreDecorator {
    
    let instructions = """
        Tap any row to mark the todo as complete.
        Swipe left to delete an uncompleted todo.
        Reload to undo any changes that have been made.
    """
    
    enum SectionType: Int, Comparable {
        case instructions, notCompleted, completed
    }
    
    var allTodos: [Todo] = [] {
        didSet {
            onContentUpdated()
        }
    }
    
    func onContentUpdated() {
        guard !allTodos.isEmpty else {
            backingStore.update(itemsForSections: [:])
            return
        }
        
        let groupedTodos = Dictionary(grouping: allTodos.sorted()) { todo in
            return todo.completed ? SectionType.completed : SectionType.notCompleted
        }
        backingStore.update(
            itemsForSections: [
                .instructions: [instructions],
                .completed: groupedTodos[.completed] ?? [],
                .notCompleted: groupedTodos[.notCompleted] ?? [],
            ]
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
    
    func decorate(cell: UIView, at indexPath: IndexPath, animated: Bool) {
        if let cell = cell as? TodoCell,
            let todo = backingStore.item(at: indexPath) as? Todo {
            cell.viewData = TodoCell.ViewData(
                title: todo.title.localizedCapitalized,
                subtitle: todo.completed ? "Completed" : "Not Completed"
            )
            
        } else if let cell = cell as? InstructionsCell,
            let instructions = backingStore.item(at: indexPath) as? String {
            cell.viewData = InstructionsCell.ViewData(text: instructions)
        }
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
        } else if backingStore.item(at: indexPath) is String {
            return tableView.dequeueReusableCell(withIdentifier: "InstructionsCell", for: indexPath)
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


import UIKit

class ViewController: UIViewController, UITableViewDelegate {
    
    let dataSource = TodoDataSource()
    let todosService = TodosService()
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.registerCells(in: tableView)
        dataSource.backingStore.view = tableView
        dataSource.backingStore.decorator = dataSource
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        onReload()
    }
    
    // MARK: - Actions
    
    @IBAction func onCreateTodo() {
        let newTodo = Todo(title: "New Todo #\(dataSource.allTodos.count)")
        dataSource.allTodos.insert(newTodo, at: 0)
    }
    
    @IBAction func onReload() {
        dataSource.allTodos = []
        todosService.getAll(limit: 10) { [weak self] todos in
            self?.dataSource.allTodos = todos ?? []
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let selectedTodo = dataSource.backingStore.item(at: indexPath) as? Todo {
            selectedTodo.completed = true
            dataSource.onContentUpdated()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if let selectedTodo = dataSource.backingStore.item(at: indexPath) as? Todo,
            !selectedTodo.completed {
            return .delete
        } else {
            return .none
        }
    }
}

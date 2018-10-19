import Foundation

struct TodosService {
    
    func getAll(limit: Int, completion: @escaping ([Todo]?)->()) {
        let url = URL(string: "https://jsonplaceholder.typicode.com/todos")!
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(
            with: urlRequest,
            completionHandler: { data, response, error in
                // Simulate longer network loading time:
                Thread.sleep(forTimeInterval: 1.0)
                
                let decoder = JSONDecoder()
                if let error = error {
                    print("Error: \(error).  A netwotk connection is reqired for this demo.")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    
                } else if let data = data,
                    let todos = try? decoder.decode([Todo].self, from: data) {
                    DispatchQueue.main.async {
                        let safeLimit = max(0, min(limit, todos.count))
                        completion(Array(todos[0..<safeLimit]))
                    }
                }
            }
        )
        task.resume()
    }
}

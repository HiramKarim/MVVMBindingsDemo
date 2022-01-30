//
//  ViewController.swift
//  MvvmBindings
//
//  Created by Hiram Castro on 29/01/22.
//

import UIKit

// Observable

class Observable<T> {
    var value: T? {
        didSet {
            listener?(value)
        }
    }
    private var listener: ((T?) -> Void)?
    
    init (_ value: T?) {
        self.value = value
    }
    
    func bind(_ listener: @escaping (T?) -> Void) {
        listener(value)
        self.listener = listener
    }
}

// Model

struct User: Codable {
    let name: String
}

// ViewModels

struct UserListViewModel {
    var users: Observable<[UserTableViewCellViewModel]> = Observable([])
}

struct UserTableViewCellViewModel {
    let name: String
}

// Controller

class ViewController: UIViewController {
    
    private let tableview: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private var viewModel = UserListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .cyan
        
        view.addSubview(tableview)
        tableview.frame = view.bounds
        tableview.dataSource = self
        
        viewModel.users.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableview.reloadData()
            }
        }
        
        fetchData()
    }
    
    func fetchData() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            do {
                let userModels = try JSONDecoder().decode([User].self, from: data)
                
                self.viewModel.users.value = userModels.compactMap({ user in
                    UserTableViewCellViewModel(name: user.name)
                })
            } catch {
                
            }
        }
        task.resume()
    }


}

extension ViewController:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.users.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.users.value?[indexPath.row].name
        return cell
    }
    
    
}

//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Rudolf Amiryan on 13.11.23.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let cellID = "cell"
    private var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
   

    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(_colorLiteralRed: 21/255,
                                                   green: 101/255,
                                                   blue: 191/255,
                                                   alpha: 194/255)
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addNewTask))
        
        navigationController?.navigationBar.tintColor = .white
    }
        @objc private func addNewTask() {
            let newTaskViewController = NewTaskViewController()
            newTaskViewController.modalPresentationStyle = .fullScreen
            present(newTaskViewController, animated: true)
            
            showAlert(withTitle: "New Task", andMessage: "Вы хотите добавить новую задачу?")
        }
    
    private func fetchData() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
           tasks = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error {
            print(error)
        }
    }
    
    private func showAlert(withTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {_ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        
    }
    private func save(_ taskName: String) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
        
        task.name = taskName
        tasks.append(task)
        
        let cellIndex = IndexPath(row: tasks.count - 1, section: 0)
        tableView.insertRows(at: cellIndex, with: .automatic)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error)
            }
            dismiss(animated: true)
        }
    }
    }
    
extension TaskListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = tasks[indexPath.row]
        
     
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        cell.contentConfiguration = content
        cell.textLabel?.text = task.name
        return cell
    }
}



//
//  ViewController.swift
//  ToDo
//
//  Created by Igor Fernandes on 30/05/22.
//

import UIKit

class ToDoViewController: UITableViewController {
    
    let defaults = UserDefaults.standard
    
    var items = ["item 1", "item 2", "item 3"]

    override func viewDidLoad() {
        super.viewDidLoad()
        if let itemsDefaultArray = defaults.array(forKey: "ToDoListArray") as? [String] {
            items = itemsDefaultArray
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath)
        
        cell.textLabel?.text = items[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Item", message: "Add a new item", preferredStyle: .alert)
        alert.addTextField { field in
            textField = field
            field.placeholder = "Create a new item..."
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { alert in
                if textField.text != "" {
                    self.items.append(textField.text!)
                    self.defaults.set(self.items, forKey: "ToDoListArray")
                    self.tableView.reloadData()
                }
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}


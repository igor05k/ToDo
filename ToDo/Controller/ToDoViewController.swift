//
//  ViewController.swift
//  ToDo
//
//  Created by Igor Fernandes on 30/05/22.
//

import UIKit
import CoreData

class ToDoViewController: UITableViewController {
    
    let defaults = UserDefaults.standard
    
    var items = [Item]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        loadItems()
    }
    
    @objc func refresh(_ sender: Any) {
        loadItems()
        refreshControl?.endRefreshing()
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.row].done = !items[indexPath.row].done
        saveItems()
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
            let newItemObject = Item(context: self.context)
            newItemObject.title = textField.text!
            newItemObject.done = false
            if textField.text != "" {
                self.items.append(newItemObject)
                self.saveItems()
            }
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch  {
            print("ERROR WHILE SAVING: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        do {
            items = try context.fetch(request)
        } catch  {
            print("ERROR WHILE FETCHING REQUEST \(error)")
        }
        tableView.reloadData()
    }
}

extension ToDoViewController: UISearchBarDelegate {
    
    func requestPredicateAndSortDecriptors(searchText: String) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request)
        
        tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        requestPredicateAndSortDecriptors(searchText: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 && searchText.isEmpty {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
//        requestPredicateAndSortDecriptors(searchText: searchText)
    }
}

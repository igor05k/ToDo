//
//  CategoryTableViewController.swift
//  ToDo
//
//  Created by Igor Fernandes on 07/06/22.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    var categoriesArray = [Category]()
    
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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categoriesArray[indexPath.row]
        var configuration = cell.defaultContentConfiguration()
        configuration.text = category.name
        
        cell.contentConfiguration = configuration
        
        return cell
    }
    
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         return true
     }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(categoriesArray[indexPath.row])
            categoriesArray.remove(at: indexPath.row)
            saveItems()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.categorySelected = categoriesArray[indexPath.row]
        }
    }
    
    @IBAction func addCategoryButton(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        alert.addTextField { field in
            textField = field
            field.placeholder = "add a new category..."
        }
        alert.view?.tintColor = .darkGray
        
        let addCategoryAction = UIAlertAction(title: "Add", style: .default) { alertAction in
            
            guard textField.text == nil else {
                print("invalid title")
                return
            }
                let categoryObject = Category(context: self.context)
                categoryObject.name = textField.text

                self.categoriesArray.append(categoryObject)
                self.saveItems()
        }
        
        let dismissAction = UIAlertAction(title: "Cancel", style: .default) { dismissAction in
            alert.dismiss(animated: true, completion: nil)
        }
        
        present(alert, animated: true, completion: nil)
        alert.addAction(dismissAction)
        alert.addAction(addCategoryAction)
        
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("ERROR WHILE SAVING CATEGORY \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoriesArray = try context.fetch(request)
        } catch {
            print("ERROR WHILE FETCHING ITEMS \(error)")
        }
    }
}

//
//  CategoriesViewController.swift
//  Tasket
//
//  Created by Yuri Ramocan on 1/21/18.
//  Copyright © 2018 Yuri Ramocan. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoriesViewController: SwipeTableViewController {
    
    // MARK: - Instance Variables
    let realm = try! Realm()
    var categories: Results<Category>?
    
    // MARK: - View Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }

    // MARK: - Table View Data Source Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        guard let category = categories?[indexPath.row] else {
            cell.textLabel?.text = "No Categories Added Yet"
            return cell
        }
        
        guard let categoryColor = UIColor(hexString: category.color) else { return cell }
        
        cell.backgroundColor = categoryColor
        cell.textLabel?.text = category.name
        cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: categoryColor, isFlat: true)
        
        return cell
    }
    
    // MARK: - Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToTodoItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTodoItems" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            let destinationVC = segue.destination as! TodoListViewController
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    // MARK: - UI Manipulation Methods
    
    override func configureTableView() {
        super.configureTableView()
    }
    
    // MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving to Realm \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadData() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        guard let category = categories?[indexPath.row] else { return }
        delete(category: category)
    }
    
    func delete(category: Category) {
        do {
            try realm.write {
                realm.delete(category.todoItems)
                realm.delete(category)
            }
        } catch {
            print("Error deleting category from Realm \(error)")
        }
    }
    
    // MARK: - IBAction Methods
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            guard let text = textField.text else { return }
            if text.isEmpty { return }
            
            let newCategory = Category()
            newCategory.name = text
            newCategory.color = UIColor.randomFlat.hexValue()
            
            self.save(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Category name"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

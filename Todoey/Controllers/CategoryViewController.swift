//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Marina Karpova on 29.01.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    lazy var realm = try! Realm()

    var categoryArray: Results<CategoryItem>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist")}
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = UIColor(hexString: "1D9BF6")
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : FlatWhite()]
        appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : FlatWhite()]
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = navBar.standardAppearance
        
        navBar.tintColor = FlatWhite()
        
    }
    
    
    //MARK: - Table View Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories Added yet"
        
        if let curentcolor = UIColor(hexString: categoryArray?[indexPath.row].nameOfColor ?? "1D9BF6") {
            cell.backgroundColor = curentcolor
            cell.textLabel?.textColor = ContrastColorOf(curentcolor, returnFlat: true)
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category: CategoryItem) {
        do {
            try realm.write({
                realm.add(category)
            })
        } catch {
            print("error saving data, \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems() {
        
        categoryArray = realm.objects(CategoryItem.self)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.categoryArray?[indexPath.row] {
            do {
                try self.realm.write({
                    self.realm.delete(item)
                })
            } catch {
                print("error deleting data, \(error)")
            }
        }
    }
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add category", style: .default) { action in
            if textField.text != "" {
                let newCategory = CategoryItem()
                newCategory.name = textField.text!
                newCategory.nameOfColor = UIColor.randomFlat().hexValue()
                self.save(category: newCategory)
            } else {
                return
            }
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
}

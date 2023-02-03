//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: CategoryItem? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.nameOfColor {
            
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist")}
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            
            if let navBarColor = UIColor(hexString: colorHex) {
                
                appearance.backgroundColor = navBarColor
                appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
                appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
                navBar.standardAppearance = appearance
                navBar.scrollEdgeAppearance = navBar.standardAppearance
                
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                
                searchBar.barTintColor = navBarColor
                
                
            }
            searchBar.searchTextField.backgroundColor = FlatWhite()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            if let color =  UIColor(hexString: selectedCategory!.nameOfColor)?.darken(byPercentage: CGFloat(Double(indexPath.row + 1) / Double(todoItems!.count))) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                cell.tintColor = ContrastColorOf(color, returnFlat: true)
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write({
                    item.done = !item.done
                })
            } catch {
                print("error saving data, \(error)")
            }
        } 
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            if textField.text != "" {
                
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write({
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                        })
                    } catch {
                        print("error saving data, \(error)")
                    }
                }
                self.tableView.reloadData()
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
    
    
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: false)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try self.realm.write({
                    self.realm.delete(item)
                })
            } catch {
                print("error deleting data, \(error)")
            }
        }
    }
    
}



//MARK: - UISearchBarDelegate

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
        
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            
        }
    }
}

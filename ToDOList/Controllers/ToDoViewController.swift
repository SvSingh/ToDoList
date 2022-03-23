//
//  ViewController.swift
//  ToDOList
//
//  Created by SV Singh on 2022-03-07.
//

import UIKit
import CoreData
import ChameleonFramework

import SwipeCellKit

extension ToDoViewController : SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.context.delete(self.ItemArray[indexPath.row])
            self.ItemArray.remove(at: indexPath.row)
            self.saveItems()
           // tableView.reloadData()
            
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        
        return options
    }
    
}

class ToDoViewController: UITableViewController,UISearchBarDelegate {
 
    
    var ItemArray = [Item]()
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    var color : UIColor?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: selectedCategory?.color ?? "1D9BF6")
        
         title = selectedCategory?.name
        searchBar.barTintColor = UIColor(hexString: selectedCategory?.color ?? "1D9BF6")
        
        navigationController?.navigationBar.tintColor = ContrastColorOf(searchBar.barTintColor!, returnFlat: true)
        
        //navigationController?.navigationBar.foregroundColor = ContrastColorOf(searchBar.barTintColor!, returnFlat: true)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text?.count == 0){
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
        
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
         
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        var predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
         
        
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
         
        
        loadItems(with: request,predicate : predicate)
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ItemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        let item = ItemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.backgroundColor = UIColor(hexString: self.selectedCategory?.color ?? "1D9BF6")?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(ItemArray.count))
        
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = ItemArray[indexPath.row]
        
       item.done.toggle()
       
        
        saveItems()
        
        self.tableView.reloadData()
        
        
    }
    
    
    
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New To Do Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            
            
            var newItem = Item(context : self.context)
            
            
            
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentrelation = self.selectedCategory
            
            self.ItemArray.append(newItem)
            
            self.saveItems()
            
            self.tableView.reloadData()
            
        }
        alert.addTextField { UITextField in
            UITextField.placeholder = "Create New Item"
            textField = UITextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        
    }
    
    
    func saveItems(){
        
        do {
            try? self.context.save()
        }catch {
            
        }
        
        
         
    }
    
    
    func loadItems (with : NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil){
        
        let request = with
        
        let CategoryPredicate = NSPredicate(format: "parentrelation.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [CategoryPredicate,additionalPredicate])
            
        }
        else {
            request.predicate = CategoryPredicate
        }
        
       
        do {
           ItemArray = try context.fetch(request)
            
        }catch {
            
        }
        
        tableView.reloadData()
        
    }
    
}





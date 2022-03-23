//
//  CategoryViewController.swift
//  ToDOList
//
//  Created by SV Singh on 2022-03-08.
//

import UIKit

import CoreData

import SwipeCellKit

import ChameleonFramework


extension CategoryViewController : SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.context.delete(self.CategoryArray[indexPath.row])
            self.CategoryArray.remove(at: indexPath.row)
            self.saveCategory()
           
            
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


class CategoryViewController: UITableViewController {
    
    
    
    
    var CategoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategory()
        
        tableView.rowHeight = 80

            
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = UIColor( hexString: "1D9BF6")
        
        
    }

    
    @IBAction func AddCategegotyButton(_ sender: UIBarButtonItem) {
        
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            
            
            var newCategory = Category(context : self.context)
            
            newCategory.name = textField.text!
            
            newCategory.color = UIColor.randomFlat().hexValue()
            
            self.CategoryArray.append(newCategory)
            
            self.saveCategory()
            self.tableView.reloadData()
            
        }
        alert.addTextField { UITextField in
            UITextField.placeholder = "Create New Item"
            textField = UITextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CategoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        
        
        let category = CategoryArray[indexPath.row]
        cell.backgroundColor = UIColor(hexString : category.color ?? "1D9BF6")
        
        cell.textLabel?.text = category.name
        
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
         
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       performSegue(withIdentifier: "goToItems", sender: self)
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = CategoryArray[indexPath.row]
        }
    }
    
    
    func saveCategory(){
        
        do {
            try? self.context.save()
        }catch {
            
        }
        
        
         
    }
    
    
    func loadCategory (with : NSFetchRequest<Category> = Category.fetchRequest()){
        
        let request = with
        do {
           CategoryArray = try context.fetch(request)
            
        }catch {
            
        }
        
        tableView.reloadData()
        
    }
    
    
    
    
}

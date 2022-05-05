//
//  ViewController.swift
//  Kaipa
//
//  Created by Ariel Waraney on 26/04/22.
//

import UIKit
import CoreData

class SelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddItemViewControllerProtocol  {

    @IBOutlet weak var categorySegmentControlOutlet: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    var wearItemCollection = [WearEntity]()
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Selection"
        //pop the search controller on nav bar
        navigationItem.searchController = searchController
        navigationItem.searchController?.searchBar.searchTextField.backgroundColor = UIColor.white
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction))
                navigationItem.rightBarButtonItem = add
        
        categorySegmentControlOutlet.selectedSegmentIndex = 0 // all
        print("col: \(wearItemCollection.count)")
    }
    
    @IBAction func segmentControlPressed(_ sender: Any) {
        switch categorySegmentControlOutlet.selectedSegmentIndex {
        case 0:
            //all wear fetch data
            print("show all")
            retrieveAllData()
        case 1:
            //top wear fetch data
            print("show top wears")
            retrieveFilterData(key: "Top Wear")
        case 2:
            //bottom wear fetch data
            print("show bottom wears")
            retrieveFilterData(key: "Bottom Wear")
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        retrieveAllData()
        print("col: \(wearItemCollection.count)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    @objc func addButtonAction() {
        performSegue(withIdentifier: "addItemSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addItemSegue" {
            let move = segue.destination as? AddItemViewController
            move?.delegate = self
        }
    }
    
    func refreshViews() {
        retrieveAllData()
        print("col: \(wearItemCollection.count)")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return wearItemCollection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "itemCellWithID", for: indexPath) as! ItemTableCell
        //convert to ui in item table cell based on the data based
        if let imageData = wearItemCollection[indexPath.section].image {
            itemCell.itemImage.image = UIImage(data: imageData as Data)
        }
        itemCell.itemName.text = wearItemCollection[indexPath.section].name
        itemCell.itemCategory.text = wearItemCollection[indexPath.section].category
        if wearItemCollection[indexPath.section].isFavoriteStatus == true {
            itemCell.itemFavorite.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            itemCell.itemFavorite.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        itemCell.itemTag.text = wearItemCollection[indexPath.section].tag
        
        
        return itemCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "DetailViewSB") as? DetailViewController {
            self.navigationController?.pushViewController(vc, animated: true)
            //convert data to UIImage
            if let imageData = wearItemCollection[indexPath.section].image {
               let theImage = UIImage(data: imageData as Data)
                vc.img = theImage!
            }
            vc.name = wearItemCollection[indexPath.section].name!
            vc.size = wearItemCollection[indexPath.section].size!
            vc.color = wearItemCollection[indexPath.section].color!
            vc.brand = wearItemCollection[indexPath.section].brand!
            vc.tag = wearItemCollection[indexPath.section].tag!
            let theFrq = Int(wearItemCollection[indexPath.section].frequency)
            vc.frequency = theFrq
            vc.date = wearItemCollection[indexPath.section].date!
            vc.category = wearItemCollection[indexPath.section].category!
            vc.favorite = wearItemCollection[indexPath.section].isFavoriteStatus
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Component Delete action
        let delete = UIContextualAction(style: .normal, title: "Delete") { [weak self] (action, view, completionHandler) in
            
            let deleteAlert = UIAlertController(title: "Delete Item?", message: "This step cannot be undone", preferredStyle: .alert)
            deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
                
                //call delete data function
                self?.deleteData(item: self!.wearItemCollection[indexPath.section].name!)
                completionHandler(true)
              }))

            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                self!.dismiss(animated: true, completion: nil)
              }))

            self!.present(deleteAlert, animated: true, completion: nil)
          
        }
        delete.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        return configuration
    }
    
    public func retrieveAllData(){
        //specified the data type of the output as array of wear entity
        let request: NSFetchRequest<WearEntity> = WearEntity.fetchRequest()
      
        //filtering
        let query = NSPredicate(format: "isSelectedStatus = %d", false)
        request.predicate = query
        
        do {
            wearItemCollection = try context!.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    public func retrieveFilterData(key: String){
        let request: NSFetchRequest<WearEntity> = WearEntity.fetchRequest()
        
        //filtering
        let queryOne = NSPredicate(format: "isSelectedStatus = %d", false)
        let queryTwo =  NSPredicate(format: "category CONTAINS '\(key)'")
        let queries = NSCompoundPredicate(andPredicateWithSubpredicates: [queryOne, queryTwo])
        request.predicate = queries
        
        do {
            wearItemCollection = try context!.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    public func deleteData(item: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let manageContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WearEntity")
        fetchRequest.predicate = NSPredicate(format: "name = %@", item)
        
        do {
            let objectFrom = try manageContext.fetch(fetchRequest)
            
            let objectToDelete = objectFrom[0] as! NSManagedObject
            manageContext.delete(objectToDelete)
            
            do {
                try manageContext.save()
            } catch {
                print(error)
            }

        } catch let error as NSError {
            print("Error due to : \(error.localizedDescription)")
        }
        
        retrieveAllData()
    }
}

final class StyleNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}



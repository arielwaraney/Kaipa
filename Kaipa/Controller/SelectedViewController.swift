//
//  SelectedViewController.swift
//  Kaipa
//
//  Created by Ariel Waraney on 27/04/22.
//

import UIKit
import CoreData

class SelectedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var categorySegmentControlOutlet: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var listLabelNotif: UILabel!
    
    var wearItemCollection = [WearEntity]()
    let searchController = UISearchController()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Selected"
        
        //pop the search controller on nav bar
        navigationItem.searchController = searchController
        navigationItem.searchController?.searchBar.searchTextField.backgroundColor = UIColor.white

        //retrieve button
        let retrieve = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(retrieveButtonAction))
        navigationItem.rightBarButtonItem = retrieve
        
        categorySegmentControlOutlet.selectedSegmentIndex = 0 //all
        print("col-2: \(wearItemCollection.count)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        retrieveSelectedAllData()
        print("col-2: \(wearItemCollection.count)")
    }
    
    @IBAction func segmentControlPressed(_ sender: Any) {
        switch categorySegmentControlOutlet.selectedSegmentIndex {
        case 0:
            //all wear fetch data
            print("show all")
            retrieveSelectedAllData()
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
    
    //MARK: - Core Data Database & Filter
    
    @objc func retrieveButtonAction() {
        if wearItemCollection.count != 0 {
            //show alert
            let retrieveAlert = UIAlertController(title: "Retrieve All Item?", message: "All top and bottom wears will be reset and retrieved to the selection list.", preferredStyle: .alert)
            retrieveAlert.addAction(UIAlertAction(title: "Retrieve All", style: .default, handler: { (action: UIAlertAction!) in
                
                //reset the data
                print ("reset data here")
                
                let request: NSFetchRequest<WearEntity> = WearEntity.fetchRequest()
                let query = NSPredicate(format: "isSelectedStatus = %d", true)
                request.predicate = query
                
                //update data
                do {
                    let object = try context!.fetch(request)
                    
                    for index in 0 ..< self.wearItemCollection.count {
                        let objectToUpdate = object[index] as NSManagedObject
                        objectToUpdate.setValue(false, forKey: "isSelectedStatus")
                        objectToUpdate.setValue(0, forKey: "frequency")
                        objectToUpdate.setValue(Date(), forKey: "date")
                        
                        do {
                            try context!.save()
                        } catch {
                            print(error)
                        }
                    }
                    
                    //refresh table view
                    self.retrieveSelectedAllData()
                } catch let error as NSError {
                    print(error)
                }
            }))
            
            retrieveAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
            }))
            
            self.present(retrieveAlert, animated: true, completion: nil)
        }
        
        
       
    }
    
    func retrieveSelectedAllData(){
        let request: NSFetchRequest<WearEntity> = WearEntity.fetchRequest()
        
        //filtering
        let query = NSPredicate(format: "isSelectedStatus = %d", true)
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
        let queryOne = NSPredicate(format: "isSelectedStatus = %d", true)
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
        
        retrieveSelectedAllData()
    }
    
    //MARK: - Table Views
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemCell = tableView.dequeueReusableCell(withIdentifier: "selectedItemCellWithID", for: indexPath) as! SelectedItemTableCell
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
        itemCell.itemFrequency.text = String(wearItemCollection[indexPath.section].frequency)
        itemCell.itemLastUsed.text = convertDateFormatToString(date: wearItemCollection[indexPath.section].date!)
        
        return itemCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return wearItemCollection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
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
    
    //MARK: -Additional Functions
    
    func convertDateFormatToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let resultString = dateFormatter.string(from: date)
        return resultString
    }
}

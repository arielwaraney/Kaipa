//
//  DetailViewController.swift
//  Kaipa
//
//  Created by Ariel Waraney on 28/04/22.
//

import Foundation
import UIKit
import CoreData

class DetailViewController: UIViewController {
        
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemSize: UILabel!
    @IBOutlet weak var itemColor: UILabel!
    @IBOutlet weak var itemBrand: UILabel!
    @IBOutlet weak var itemTag: UILabel!
    @IBOutlet weak var itemFrequency: UILabel!
    @IBOutlet weak var itemDate: UILabel!
    @IBOutlet weak var itemFavorite: UIButton!
    @IBOutlet weak var itemCategory: UILabel!
    @IBOutlet weak var buttonChoose: UIButton!
    
    var img = UIImage()
    var name = ""
    var size = ""
    var color = ""
    var brand = ""
    var tag = ""
    var frequency = 0
    var date = Date()
    var category = ""
    var favorite = false
    
    override func viewDidLoad(){
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        title = "Detail"

        //delete button navbar
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePressed))
        navigationItem.rightBarButtonItem = delete
        
        itemImage.layer.cornerRadius = 10.0
        itemImage.image = img
        if favorite == true {
            itemFavorite.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            itemFavorite.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        itemName.text = name
        itemCategory.text = category
        itemSize.text = size
        itemColor.text = color
        itemBrand.text = brand
        itemTag.text = tag
        itemFrequency.text = "\(frequency)"
        
        //showing date condition
        if frequency == 0 {
            itemDate.text = "-"
            buttonChoose.setTitle("Choose This Outfit", for: .normal)
        } else {
            itemDate.text = "\(convertDateFormatToString(date: date))"
            buttonChoose.setTitle("Choose This Outfit Again", for: .normal)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    func convertDateFormatToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let resultString = dateFormatter.string(from: date)
        return resultString
    }
    
    @objc func deletePressed(){
       
        let deleteAlert = UIAlertController(title: "Delete Item?", message: "This step cannot be undone", preferredStyle: .alert)
        deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
            
            //deleting data selected
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WearEntity")
            fetchRequest.predicate = NSPredicate(format: "name = %@", self.name)
             
            do {
                let objectFrom = try context!.fetch(fetchRequest)
                
                let objectToDelete = objectFrom[0] as! NSManagedObject
                context!.delete(objectToDelete)
                
                do {
                    try context!.save()
                } catch {
                    print(error)
                }

            } catch let error as NSError {
                print("Error due to : \(error.localizedDescription)")
            }
             
          }))

        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
          }))

        present(deleteAlert, animated: true, completion: nil)
    }
    
    @IBAction func favoritePressed(_ sender: Any) {
        //user pressing the favorite btn, change the ui
        if favorite == true {
            itemFavorite.setImage(UIImage(systemName: "heart"), for: .normal)
            favorite = false
        } else {
            itemFavorite.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            favorite = true
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WearEntity")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let object = try context!.fetch(fetchRequest)
            
            let objectToUpdate = object[0] as! NSManagedObject
            objectToUpdate.setValue(favorite, forKey: "isFavoriteStatus")
            do {
                try context!.save()
            } catch {
                print(error)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    
    @IBAction func choosedPressed(_ sender: Any) {
        //update frequency byadding 1 and update date to the current one
        let newFrequency = frequency + 1
        let newDate = Date()

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WearEntity")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        do {
            let object = try context!.fetch(fetchRequest)
            
            let objectToUpdate = object[0] as! NSManagedObject
            objectToUpdate.setValue(newFrequency, forKey: "frequency")
            objectToUpdate.setValue(newDate, forKey: "date")
            objectToUpdate.setValue(true, forKey: "isSelectedStatus")
            
            do {
                try context!.save()
                displayAlertScreen(title: "Item Selected ✅", msg: "Let's use this outfit for today ✨")
                
            } catch {
                print(error)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func displayAlertScreen(title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
}

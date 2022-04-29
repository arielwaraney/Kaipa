//
//  CollectionFormViewController.swift
//  Kaipa
//
//  Created by Ariel Waraney on 27/04/22.
//

import UIKit
import CoreData

//accessing the cointainer core data
let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext


protocol AddItemViewControllerProtocol: AnyObject {
    func refreshViews()
}

class AddItemViewController: UIViewController {
   
    var wearData: WearEntity!
    weak var delegate: AddItemViewControllerProtocol?
    
    //find the entity core data saved previously
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var colorTextField: UITextField!
    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var isFavoriteSwitch: UISwitch!
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var imageTaken: UIImageView!
    //buttons
    @IBOutlet weak var chooseImageGallery: UIButton!
    @IBOutlet weak var openCameraFramework: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var categoryPicker = UIPickerView()
    let categories = ["Top Wear", "Bottom Wear"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openCameraFramework.isEnabled = false
        
        //picker set up
        categoryTextField.inputView = categoryPicker
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        //hide the selector when tap outside
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideSelector)))
    }
    
    @objc private func hideSelector(){
        self.view.endEditing(true)
    }
    
    @IBAction func chooseImageBtnPressed(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true //square editing
        present(vc, animated: true)
    }
    
    @IBAction func chooseCameraBtnPressed(_ sender: Any) {
        //camera framework
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addBtnPressed(_ sender: Any) {
        
        if nameTextField.text == "" || sizeTextField.text == "" || colorTextField.text == "" || brandTextField.text == "" || tagTextField.text == "" || categoryTextField.text == "" || imageTaken.image == nil {
            displayAlertScreen(title: "Please fill all the data", msg: "One of the fields is blank. All Fields are required")
            return
        }
        else
        {
            //accessing the app delegate for core data container code in app delegate
            //guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            guard let entity = NSEntityDescription.entity(forEntityName: "WearEntity", in: context!) else { return }
            //insert the new item data from the text field
            let newWear = NSManagedObject(entity: entity, insertInto: context)
            //insert data
            let imageData: Data = convertUIImageToNSData(image: imageTaken.image!)
            newWear.setValue(imageData, forKey: "image")
            newWear.setValue(nameTextField.text, forKey: "name")
            newWear.setValue(sizeTextField.text, forKey: "size")
            newWear.setValue(colorTextField.text, forKey: "color")
            newWear.setValue(brandTextField.text, forKey: "brand")
            newWear.setValue(tagTextField.text, forKey: "tag")
            newWear.setValue(categoryTextField.text, forKey: "category")
            newWear.setValue(0, forKey: "frequency")
            newWear.setValue(Date(), forKey: "date")
            if isFavoriteSwitch.isOn {
                newWear.setValue(true, forKey: "isFavoriteStatus")
            } else {
                newWear.setValue(false, forKey: "isFavoriteStatus")
            }
            newWear.setValue(false, forKey: "isSelectedStatus")
            
            dismissButtonPressed()
            print("All Data Saved")
            
        }
    }
    
    func displayAlertScreen(title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func dismissButtonPressed() {
        dismiss(animated: true) {
            self.delegate?.refreshViews()
        }
    }
    
    func convertUIImageToNSData(image: UIImage) -> Data {
        return image.pngData()!
    }
    
}

extension AddItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //func 1
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //pull the photo
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            imageTaken.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension AddItemViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = categories[row]
        categoryTextField.resignFirstResponder()
    }
    
}


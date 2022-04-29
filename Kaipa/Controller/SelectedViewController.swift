//
//  SelectedViewController.swift
//  Kaipa
//
//  Created by Ariel Waraney on 27/04/22.
//

import UIKit

class SelectedViewController: UIViewController {
    
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Selected"
        
        //pop the search controller on nav bar
        navigationItem.searchController = searchController
        navigationItem.searchController?.searchBar.searchTextField.backgroundColor = UIColor.white

    }
}

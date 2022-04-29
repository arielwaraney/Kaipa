//
//  ItemTableViewOne.swift
//  Kaipa
//
//  Created by Ariel Waraney on 27/04/22.
//

import UIKit

var wearList = [WearItemModel]()

class ItemTableViewOne: UITableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wearList.count
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
}

//
//  SelectedItemTableCell.swift
//  Kaipa
//
//  Created by Ariel Waraney on 05/05/22.
//

import UIKit

class SelectedItemTableCell: UITableViewCell {
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemCategory: UILabel!
    @IBOutlet weak var itemFavorite: UIButton!
    @IBOutlet weak var itemFrequency: UILabel!
    @IBOutlet weak var itemLastUsed: UILabel!
    @IBOutlet weak var itemTag: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        //initialization
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //animation for the selected cell
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //set the values for top,left,bottom,right margins
        let margins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        contentView.frame = contentView.frame.inset(by: margins)
    }
}

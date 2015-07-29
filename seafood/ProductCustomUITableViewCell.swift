//
//  ProductCustomUITableViewCell.swift
//  seafood
//
//  Created by Wanbin Ouyang on 7/28/15.
//  Copyright (c) 2015 go2fish. All rights reserved.
//

import UIKit

class ProductCustomUITableViewCell: UITableViewCell {
    
    var productId: String!
    
    var productDescription: String!
    
    var productQuantity: Int!

    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var productMark: UILabel!
    
    @IBOutlet weak var productPriceLabel: UILabel!
    
    @IBOutlet weak var productUnitLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

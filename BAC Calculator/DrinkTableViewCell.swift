//
//  DrinkTableViewCell.swift
//  BAC Calculator
//
//  Created by Brandon Riehle on 2/25/16.
//  Copyright © 2016 Brandon Riehle. All rights reserved.
//

import UIKit

class DrinkTableViewCell: UITableViewCell
{
    // MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var flozLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

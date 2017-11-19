//
//  CreateMessageTableViewCell.swift
//  Dragging
//
//  Created by francis gallagher on 26/03/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit
import Parse

class CreateMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var object : PFObject?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImage.layer.cornerRadius = 25
    }
}

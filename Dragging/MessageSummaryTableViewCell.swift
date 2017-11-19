//
//  MessageSummaryTableViewCell.swift
//  Dragging
//
//  Created by francis gallagher on 26/03/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit
import Parse

class MessageSummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var conversationImage: UIImageView!
    
    var conversation : PFObject?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

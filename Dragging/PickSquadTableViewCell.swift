//
//  PickSquadTableViewCell.swift
//  Dragging
//
//  Created by francis gallagher on 22/03/17.
//  Copyright © 2017 Testing. All rights reserved.
//

import UIKit

class PickSquadTableViewCell: UITableViewCell {

    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

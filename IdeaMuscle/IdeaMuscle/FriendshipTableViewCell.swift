//
//  FriendshipTableViewCell.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 7/22/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import ParseUI

class FriendshipTableViewCell: UITableViewCell {
    
    var usernameLabel = UILabel()
    var profileButton = PFImageView()
    var followButton = UIButton()

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(usernameLabel)
        self.contentView.addSubview(profileButton)
        self.contentView.addSubview(followButton)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        
        self.profileButton.hidden = false
    }
    
}

//
//  TopicTableViewCell.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/18/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import ParseUI

class LeaderboardTableViewCell: UITableViewCell {
    
    var usernameLabel = UILabel()
    var numberOfUpvotes = UIButton()
    var profileButton = PFImageView()
    var upvotesLabel = UILabel()
    var rankLabel = UILabel()

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(usernameLabel)
        self.contentView.addSubview(numberOfUpvotes)
        self.contentView.addSubview(profileButton)
        self.contentView.addSubview(upvotesLabel)
        self.contentView.addSubview(rankLabel)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

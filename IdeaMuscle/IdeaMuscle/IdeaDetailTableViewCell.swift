//
//  IdeaDetailTableViewCell.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/23/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import ParseUI

class IdeaDetailTableViewCell: UITableViewCell {

    var usernameLabel = UILabel()
    var commentLabel = UILabel()
    var timeAgoStampLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(usernameLabel)
        self.contentView.addSubview(commentLabel)
        self.contentView.addSubview(timeAgoStampLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
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



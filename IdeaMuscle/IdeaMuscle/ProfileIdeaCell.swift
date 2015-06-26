//
//  TopicTableViewCell.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/18/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import ParseUI

class ProfileIdeaCell: UITableViewCell {
    
    
    var numberOfUpvotesButton = UIButton()
    var ideaLabel = UILabel()
    var topicLabel = UILabel()
    var timeStamp = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        self.contentView.addSubview(ideaLabel)
        self.contentView.addSubview(numberOfUpvotesButton)
        self.contentView.addSubview(topicLabel)
        self.contentView.addSubview(timeStamp)
        
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



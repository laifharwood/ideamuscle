//
//  TopicTableViewCell.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/18/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import ParseUI

class TopicTableViewCell: UITableViewCell {
    
    var usernameLabel = UILabel()
    var ideaTotalButton = UIButton()
    let ideaTitleLabel = UILabel()
    var topicLabel = UILabel()
    var profileButton = PFImageView()
    var shareButton = UIButton()
    var composeButton = UIButton()
    var timeStamp = UILabel()
    var numberOfUpvotesButton = UIButton()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(usernameLabel)
        self.contentView.addSubview(ideaTotalButton)
        self.contentView.addSubview(ideaTitleLabel)
        self.contentView.addSubview(topicLabel)
        self.contentView.addSubview(profileButton)
        self.contentView.addSubview(shareButton)
        self.contentView.addSubview(composeButton)
        self.contentView.addSubview(timeStamp)
        self.contentView.addSubview(numberOfUpvotesButton)
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        self.numberOfUpvotesButton.tintColor = nil
        self.numberOfUpvotesButton.setTitleColor(nil, forState: .Normal)
        self.numberOfUpvotesButton.setImage(nil, forState: .Normal)
        self.numberOfUpvotesButton.titleEdgeInsets = UIEdgeInsetsZero
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

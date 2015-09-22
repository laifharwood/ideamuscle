//
//  NotificationTableViewCell.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 7/28/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

//
//  TopicTableViewCell.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 6/18/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit


class NotificationTableViewCell: UITableViewCell {
    
    
    var messageLabel = UILabel()
    var hasReadView = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(messageLabel)
        self.contentView.addSubview(hasReadView)
        
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
    
    override func prepareForReuse() {
        
    }
    
}

//
//  MoreTableViewCell.swift
//  IdeaMuscle
//
//  Created by Laif Harwood on 7/28/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class MoreTableViewCell: UITableViewCell {
    
    var badgeLabel = UILabel()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(badgeLabel)
        
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


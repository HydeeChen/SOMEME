//
//  HotTableViewCell.swift
//  SOMEME
//
//  Created by Hydee Chen on 2023/11/21.
//

import UIKit

class HotTableViewCell: UITableViewCell {
    let demoLabel = UILabel()
    override func awakeFromNib() {
        super.awakeFromNib()
        demoLabel.frame.size = CGSize(width: 50, height: 50)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        demoLabel.frame.size = CGSize(width: 50, height: 50)

        // Configure the view for the selected state
    }
}

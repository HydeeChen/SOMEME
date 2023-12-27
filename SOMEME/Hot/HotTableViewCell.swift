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
        let fontUrl = Bundle.main.url(forResource: "Mamelon", withExtension: "otf")! as CFURL
        CTFontManagerRegisterFontsForURL(fontUrl, .process, nil)
        demoLabel.font = UIFont(name: "Mamelon", size: 18)
        demoLabel.frame.size = CGSize(width: 50, height: 50)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let fontUrl = Bundle.main.url(forResource: "Mamelon", withExtension: "otf")! as CFURL
        CTFontManagerRegisterFontsForURL(fontUrl, .process, nil)
        demoLabel.font = UIFont(name: "Mamelon", size: 18)
        demoLabel.frame.size = CGSize(width: 50, height: 50)
    }
}

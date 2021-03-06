//
//  FriendsTableViewCell.swift
//  SMSCount
//
//  Created by Eddie on 12/8/15.
//  Copyright © 2015 Wen. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {

    @IBOutlet var sticker: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var preTextLabel: UILabel!
    @IBOutlet var dayNumber: UILabel!
    @IBOutlet var status: UILabel!

    // 剩餘 or 自由
    @IBOutlet var textBeforeDays: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

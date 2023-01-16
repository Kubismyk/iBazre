 //
//  TableViewCell.swift
//  iBazre
//
//  Created by Levan Charuashvili on 04.01.23.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var ttest: UILabel!
    @IBOutlet weak var testImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

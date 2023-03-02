 //
//  TableViewCell.swift
//  iBazre
//
//  Created by Levan Charuashvili on 04.01.23.
//

import UIKit
import Kingfisher




class TableViewCell: UITableViewCell {

    @IBOutlet weak var ttest: UILabel!
    @IBOutlet weak var testImage: UIImageView!
    @IBOutlet weak var lastText: UILabel!
    @IBOutlet weak var date: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func config(with data:Conversation){
        self.lastText.text = data.latestMessage.message
        self.ttest.text = data.name
        self.date.text = data.latestMessage.date
        
        let path = "\(data.otherUserEmail)_profile_picture.png"
        StorageManager.shared.requestDownload(for: path) { [weak self] result in
            switch result{
            case .success(let url):
                DispatchQueue.main.async {
                    self?.testImage.kf.setImage(with: url)
                }
            case .failure(let error):
                print("failed to download url: \(error)")
            }
        }
    }
    
}

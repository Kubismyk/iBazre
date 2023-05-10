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
        testImage.layer.masksToBounds = false
        testImage.layer.borderColor = UIColor.black.cgColor
        testImage.layer.cornerRadius = testImage.frame.height/2
        testImage.clipsToBounds = true
        self.lastText.text = data.latestMessage.message
        self.ttest.text = data.name
        self.date.text = data.latestMessage.date
        //self.testImage.image = data.
        
        let path = "images/\(data.otherUserEmail)_profile_picture.png"
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




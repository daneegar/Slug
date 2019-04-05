//
//  ChatCell.swift
//  Talks
//
//  Created by Denis Garifyanov on 21/02/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
//    var message: Message?
    var name: String?
    var date: Date?
    var online: Bool = false
    var hasUnreadMessages: Bool = false
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastText: UILabel!
    @IBOutlet weak var lastDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func configProperies(withChatModel instance: User) {
        self.name = instance.name
//        if let id = instance.id {
//            self.message = RequestAndFetchingHandler.fetchLastMessage(byID: id)
//        }
//        self.date = self.message?.createTimeStamp
        self.online = instance.isOnline
//        if let knownState = self.message?.isUnreaded {
//            self.hasUnreadMessages = knownState
//        }
        self.configCellView()

    }
    
    func configCellView() {
        self.nameLabel.text = name
//        if let message = self.message {
//            self.lastText.text = message.text
//        } else {
//            self.lastText.text = "No messages yet"
//            self.lastText.font = UIFont.boldSystemFont(ofSize: 16.0)
//        }
        
        if self.hasUnreadMessages {
            self.lastText.font = UIFont.boldSystemFont(ofSize: 16.0)
        }
        
//        let datesHandler = DatesHandler()
//        if let date = self.date {
//            self.lastDateLabel.text = datesHandler.stringWithChoisedFromatter(withDate: date,
//                                                                              howManyDaysMeansIsRecent: 1)
//        }
        
        self.backgroundColor = self.online ? UIColor(rgb: 0xDBE5C6, alpha: 0.3) : UIColor.white
    }
    
}

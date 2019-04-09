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
    var lastMessage: Message?
    var hasUnreadedMessages: Bool = false
    
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
    func configProperies(withChatModel instance: Conversation, withLastMessage message: Message?) {
        self.name = instance.user?.name
        self.date = instance.dateOfLastMessage
        self.online = !instance.isOffline
        self.hasUnreadedMessages = instance.hasUnreadedMessages
        self.lastMessage = message
        self.configCellView()
    }
    
    func configCellView() {
        self.nameLabel.text = name
        if let message = self.lastMessage {
            self.lastText.text = message.text
            if self.hasUnreadedMessages {self.lastText.font = UIFont.boldSystemFont(ofSize: 16.0)}
        } else {
            self.lastText.text = "No messages yet"
            self.lastText.font = UIFont.boldSystemFont(ofSize: 16.0)
        }
        let datesHandler = DatesHandler()
        if let date = self.date {
            self.lastDateLabel.text = datesHandler.stringWithChoisedFromatter(withDate: date,
                                                                              howManyDaysMeansIsRecent: 1)
        } else {
            self.lastDateLabel.text = ""
        }
        
        self.backgroundColor = self.online ? UIColor(rgb: 0xDBE5C6, alpha: 0.3) : UIColor.white
    }
    
}

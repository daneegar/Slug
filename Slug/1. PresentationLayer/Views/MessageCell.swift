//
//  messageCell.swift
//  Talks
//
//  Created by Denis Garifyanov on 22/02/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var labelOfIncomingMessage: UILabel!
    @IBOutlet weak var labelOfOutGoingMessage: UILabel!
    @IBOutlet weak var widthOfIncomingMsg: NSLayoutConstraint!
    @IBOutlet weak var backgrounViewOfIncomingMsg: UIView!
    @IBOutlet weak var backgroundViewOfOutGoningMsg: UIView!
    
    var textToShow: String? = ""
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }

    func setupCell(whithText text: String?, andTypeOf type: MessageType) {
        switch type {
        case .inComingMessage:
            self.labelOfIncomingMessage.text = text
            self.backgrounViewOfIncomingMsg.layer.cornerRadius = 10
        case .outGoingMessage:
            self.labelOfOutGoingMessage.text = text
            self.backgroundViewOfOutGoningMsg.layer.cornerRadius = 10
        }
    }

}

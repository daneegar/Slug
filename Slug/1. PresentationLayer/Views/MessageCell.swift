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

    var textToShow: String? = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(whithText text: String?, andTypeOf type: MessageType) {
        switch type {
        case .inComingMessage:
            self.labelOfIncomingMessage.text = text
        case .outGoingMessage:
            self.labelOfOutGoingMessage.text = text
        }
    }

}

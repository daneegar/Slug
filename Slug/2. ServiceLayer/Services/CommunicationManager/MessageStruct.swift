//
//  MessageStruct.swift
//  Slug
//
//  Created by Denis Garifyanov on 08/04/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation

struct MessageStruct: Encodable, Decodable {
    
    var text: String?
    var messageID: String?
    var eventType: String?
    
    init(from message: Message, eventType: String){
        self.text = message.text
        self.messageID = message.id
        self.eventType = eventType
    }
    
    private enum CodingKeys: String, CodingKey {
        case text
        case messageID
        case iventType
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let text = self.text {
            try container.encode(text, forKey: CodingKeys.text)
        } else {
            try container.encode("emptyMessage", forKey: CodingKeys.text)
        }
        try container.encode(messageID, forKey: CodingKeys.messageID)
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: CodingKeys.text)
        self.messageID = try container.decode(String.self, forKey: CodingKeys.messageID)
    }
    
    func unwrap(complition: (String?, String?) -> Void) {
        complition(self.text, self.messageID)
    }
}

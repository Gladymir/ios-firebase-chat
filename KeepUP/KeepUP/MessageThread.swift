//
//  MessageThread.swift
//  KeepUP
//
//  Created by Gladymir Philippe on 10/5/20.
//  Copyright © 2020 Gladymir Philippe. All rights reserved.
//

import Foundation
import MessageKit
import Firebase

class MessageThread: Codable, Equatable {

    let identifier: String
    let title: String
    var messages: [MessageThread.Message]

    init(title: String, messages: [MessageThread.Message] = [], identifier: String = UUID().uuidString) {
        self.title = title
        self.messages = messages
        self.identifier = identifier
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let title = try container.decode(String.self, forKey: .title)
        let identifier = try container.decode(String.self, forKey: .identifier)
        let messagesDictionaries = try container.decodeIfPresent([String: Message].self, forKey: .messages)

        let messages = messagesDictionaries?.compactMap({ $0.value }) ?? []

        self.title = title
        self.identifier = identifier
        self.messages = messages
    }

    static func ==(lhs: MessageThread, rhs: MessageThread) -> Bool {
        return lhs.title == rhs.title &&
            lhs.identifier == rhs.identifier &&
            lhs.messages == rhs.messages
    }

    struct Message: Codable, Equatable, MessageType {
        enum CodingKeys: String, CodingKey {
            case displayName
            case senderID
            case text
            case timestamp
        }

        let text: String
        let displayName: String
        let senderID: String
        let timestamp: Date
        let messageId: String

        // MARK: - MessageType
        var sentDate: Date { return timestamp }
        var kind: MessageKind { return .text(text) }
        var sender: SenderType {
            return Sender(senderId: senderID, displayName: displayName)
        }

        init(text: String, sender: Sender, timestamp: Date = Date(), messageId: String = UUID().uuidString) {
            self.text = text
            self.displayName = sender.displayName
            self.senderID = sender.senderId
            self.timestamp = timestamp
            self.messageId = messageId
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let text = try container.decode(String.self, forKey: .text)
            let displayName = try container.decode(String.self, forKey: .displayName)
            let timestamp = try container.decode(Date.self, forKey: .timestamp)

            var senderID = try? container.decode(String.self, forKey: .senderID)

            if senderID == nil {
                senderID = UUID().uuidString
            }

            let sender = Sender(senderId: senderID!, displayName: displayName)

            self.init(text: text, sender: sender, timestamp: timestamp)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(displayName, forKey: .displayName)
            try container.encode(senderID, forKey: .senderID)
            try container.encode(timestamp, forKey: .timestamp)
            try container.encode(text, forKey: .text)
        }
    }
}


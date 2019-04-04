//
//  PeerToPeerHandler.swift
//  Talks
//
//  Created by Denis Garifyanov on 13/03/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol  CommunicatorDelegate: class {
    //discovering
    func didFoundUser(userID: String, userName: String?)
    func didLostUser(userID: String)
    
    //errors
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
    
    //messages
    //func didRecieveMessage(text: MessageStruct, fromUser: String, toUser: String)
}

protocol Communicator {
//    func sendMessage(string: MessageStruct, to userID: String,
//                     complitionHandler : ((_ success: Bool, _ error: Error?) -> Void)?)
    var delegate: CommunicatorDelegate? {get set}
    var online: Bool {get set}
}

class MultipeerCommunicator: NSObject, Communicator {

    private let serviceType = "tinkoff-chat"

    private let myPeerId: MCPeerID
    private var serviceAdvertiser: MCNearbyServiceAdvertiser
    private var serviceBrowser: MCNearbyServiceBrowser
    private let discoveryInfo: [String: String]

    private var listOfPeers: [MCPeerID] = []

    weak var delegate: CommunicatorDelegate?
    
    var online: Bool {
        didSet {
            if online {
                self.serviceBrowser.stopBrowsingForPeers()
                self.serviceAdvertiser.startAdvertisingPeer()
            } else {
                self.serviceAdvertiser.stopAdvertisingPeer()
                self.serviceBrowser.startBrowsingForPeers()
            }
        }
    }
//    func sendMessage(string: MessageStruct, to userID: String, complitionHandler: ((Bool, Error?) -> Void)?) {
//        let jsonObject = NSMutableDictionary()
//        jsonObject.setValue("TextMessage", forKey: "eventType")
//        jsonObject.setValue(self.generateMessageId(), forKey: "messageId")
//        jsonObject.setValue(string, forKey: "text")
//        do {
//        let jsonData =  try JSONEncoder().encode(string)
//            for peer in self.session.connectedPeers where peer.displayName == userID {
//                try self.session.send(jsonData, toPeers: [peer], with: .reliable)
//            }
//        } catch {
//            print(error)
//        }
//    }

    var session: MCSession

    init(_ peerIDdisplayName: String) {
        self.myPeerId = MCPeerID(displayName: peerIDdisplayName)
        self.discoveryInfo = ["userName": peerIDdisplayName]
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.myPeerId,
                                                           discoveryInfo: self.discoveryInfo,
                                                           serviceType: self.serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: self.myPeerId, serviceType: self.serviceType)
        self.session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        self.online = true

        super.init()

        self.session.delegate = self
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.startBrowsingForPeers()
    }

    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
    }

    func generateMessageId() -> String {
        return "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)"
            .data(using: .utf8)!.base64EncodedString()
    }
}

extension MultipeerCommunicator: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        print("was invited by\(peerID)")
        invitationHandler(true, self.session)
    }
}

extension MultipeerCommunicator: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }

    func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String: String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 30)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
}

extension MultipeerCommunicator: MCSessionDelegate {

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
//        let decoder = JSONDecoder()
//        do {
//            //let message = try decoder.decode(MessageStruct.self, from: data)
//            //self.delegate?.didRecieveMessage(text: message, fromUser: peerID.displayName, toUser: "")
//        } catch {print("date ComesLike Shit")}

    }

    func session(_ session: MCSession,
                 didReceive stream: InputStream,
                 withName streamName: String,
                 fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }

    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }

    func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 at localURL: URL?,
                 withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        //print(#function)
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            DispatchQueue.main.async {
                self.delegate?.didFoundUser(userID: peerID.displayName, userName: peerID.displayName)
            }
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")

        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
            DispatchQueue.main.async {
                self.delegate?.didLostUser(userID: peerID.displayName)

            }
        @unknown default:
            print ("Unknown state comming in session")
        }
    }

}

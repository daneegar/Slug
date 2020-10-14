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
    func didRecieve(message jsonData: Data, fromUser: String)
}

protocol Communicator {
    func send(aMessage jsonData: Data, toUserId userID: String, whitUserName userNname: String,
                     complitionHandler : ((_ success: Bool, _ error: Error?) -> Void)?)
    var delegate: CommunicatorDelegate? {get set}
    var ifTrueAdvertisingFalseBrowsing: Bool {get set}
}

class MultipeerCommunicator: NSObject, Communicator {

    private let serviceType = "tinkoff-chat"

    private let myPeerId: MCPeerID
    private var serviceAdvertiser: MCNearbyServiceAdvertiser
    private var serviceBrowser: MCNearbyServiceBrowser
    private let discoveryInfo: [String: String]

    weak var delegate: CommunicatorDelegate?
    
    var ifTrueAdvertisingFalseBrowsing: Bool {
        didSet {
            if ifTrueAdvertisingFalseBrowsing {
                self.serviceBrowser.stopBrowsingForPeers()
                self.serviceAdvertiser.startAdvertisingPeer()
            } else {
                self.serviceAdvertiser.stopAdvertisingPeer()
                self.serviceBrowser.startBrowsingForPeers()
            }
        }
    }
    
    func send(aMessage jsonData: Data,
              toUserId userID: String,
              whitUserName userNname: String,
              complitionHandler: ((Bool, Error?) -> Void)?) {
        
        let displayName = MultipeerCommunicator.encodePeer(withId: userID, andName: userNname)
        
        guard let key = sessions.keys.first(where: {$0.displayName == displayName }) else {
            complitionHandler?(false, nil)
            return
        }
        
        guard let session = sessions[key] else {
            complitionHandler?(false, nil)
            return
        }
        
        do {
            for peer in session.connectedPeers where peer.displayName == displayName {
                try session.send(jsonData, toPeers: [peer], with: .reliable)
                complitionHandler?(true, nil)
                return
            }
        } catch {
            print(error)
            complitionHandler?(false, error)
            return
        }
        complitionHandler?(false, nil)
        
    }

    //var session: MCSession
    
    var sessions: [MCPeerID: MCSession] = [:]

    init(_ peerID: String, _ displayName: String, _ delegate: CommunicatorDelegate, _ ifTrueAdvertisingFalseBrowsing: Bool) {
        let encodedPeerId = MultipeerCommunicator.encodePeer(withId: peerID, andName: displayName)
        self.myPeerId = MCPeerID(displayName: encodedPeerId)
        self.discoveryInfo = ["userName": displayName]
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.myPeerId,
                                                           discoveryInfo: self.discoveryInfo,
                                                           serviceType: self.serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: self.myPeerId, serviceType: self.serviceType)
        self.delegate = delegate
        self.ifTrueAdvertisingFalseBrowsing = ifTrueAdvertisingFalseBrowsing
        super.init()
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    static private func encodePeer(withId id: String, andName name: String) -> String {
        var codedPeerID: String = String()
        codedPeerID.append(id)
        codedPeerID.append("&")
        codedPeerID.append(name)
        return codedPeerID
    }
    
    private func decodePeer(displayName: String, complition: ((String, String)->Void))
    {
        let idAndName = displayName.split(separator: "&")
        if idAndName.count != 2 {
            print("decode of user display name finished With error \(idAndName.count)")
        } else {
            complition(String(idAndName.first!), String(idAndName.last!))
        }
    }

    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
    }

    func generateMessageId() -> String {
        return "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)"
            .data(using: .utf8)!.base64EncodedString()
    }
    
    func getSession(forPeer peerID: MCPeerID) -> MCSession {
        
        guard let sesssionForPeerId = sessions[peerID] else {
            let newSession = MCSession(peer: myPeerId,
                                       securityIdentity: nil,
                                       encryptionPreference: .required)
            newSession.delegate = self
            sessions[peerID] = newSession
            
            return newSession
            
        }
        
        return sesssionForPeerId
        
    }
    
}

extension MultipeerCommunicator: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        print("was invited by\(peerID)")
        
        invitationHandler(true, getSession(forPeer: peerID))
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
        browser.invitePeer(peerID, to: getSession(forPeer: peerID), withContext: nil, timeout: 30)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
}

extension MultipeerCommunicator: MCSessionDelegate {

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@",  "didReceiveData: \(data)")
        self.decodePeer(displayName: peerID.displayName) { (id, name) in
            self.delegate?.didRecieve(message: data, fromUser: id)
        }
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
            self.decodePeer(displayName: peerID.displayName) { (id, name) in
                print("Connected: \(name) with id: \(id)")
                self.delegate?.didFoundUser(userID: id, userName: name)
            }
        case MCSessionState.connecting:
            self.decodePeer(displayName: peerID.displayName) { (id, name) in
                self.delegate?.didLostUser(userID: id)
                print("Connecting: \(name) with id: \(id)")
            }
        case MCSessionState.notConnected:
            self.decodePeer(displayName: peerID.displayName) { (id, name) in
                print("Not Connected: \(name) with id: \(id)")
                self.delegate?.didLostUser(userID: id)
            }
            
        @unknown default:
            print ("Unknown state comming in session")
        }
    }

}

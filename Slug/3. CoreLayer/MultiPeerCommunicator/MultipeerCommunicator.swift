//
//  PeerToPeerHandler.swift
//  Talks
//
//  Created by Denis Garifyanov on 13/03/2019.
//  Copyright © 2019 Denis Garifyanov. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import AVFoundation

public protocol  CommunicatorDelegate: class {
    //discovering
    func didFoundUser(userID: String, userName: String?)
    func didLostUser(userID: String)
    
    //errors
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
    
    //messages
    func didRecieve(message jsonData: Data, fromUser: String)
}

public enum CommunicatorMode {
    
    case advertising
    case browsing
    case both
    
}

public protocol Communicator {
    
    func send(aMessage jsonData: Data,
              toUserId userID: String,
              whitUserName userNname: String,
              complitionHandler : ((_ success: Bool, _ error: Error?) -> Void)?)
    
    func set(mode: CommunicatorMode)
    
    var delegate: CommunicatorDelegate? { get set }
    
}

public extension MCPeerID {
    
    var asIdentifiablePeerID: MultipeerCommunicator.IdentifiablePeerID? {
        
        let idAndName = displayName.split(separator: "&")
        if idAndName.count != 2 {
            print("decode of user display name finished With error \(idAndName.count)")
        }
        
        guard let id = idAndName.first,
              let uuid = UUID(uuidString: String(id)),
              let name = idAndName.last else {
            return nil
        }
        
        return .init(displayName: String(name), uuid: uuid)
        
    }
    
}

public class MultipeerCommunicator: NSObject, Communicator {
    
    public class IdentifiablePeerID: MCPeerID {
        
        let uuid: UUID
        let decodedName: String
        
        
        init(displayName: String, uuid: UUID) {
            self.uuid = uuid
            self.decodedName = displayName
            super.init(displayName: Self.encodePeer(withId: uuid, andName: displayName))
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        static private func encodePeer(withId id: UUID, andName name: String) -> String {
            var codedPeerID: String = String()
            codedPeerID.append(id.uuidString)
            codedPeerID.append("&")
            codedPeerID.append(name)
            return codedPeerID
        }
        
        
        
    }
    
    public struct ServiceConfigurator {
        
        public typealias MCPeerIdConfigurator = () -> IdentifiablePeerID
        
        /// <#Description#>
        /// - Parameters:
        ///   - serviceType: should be setted in info.plist as value of Privacy - Local Network Usage Description key
        ///   - discoveryInfo: additional info
        ///   - id: unique id
        ///   - displayName: name of user
        ///   - mcPeerId: mc peer id
        public init(serviceType: String,
                    discoveryInfo: [String : String],
                    mcPeerId: IdentifiablePeerID) {
            
            self.serviceType = serviceType
            self.discoveryInfo = discoveryInfo
            self.mcPeerId = mcPeerId
            
        }
        
        let serviceType: String
        
        let discoveryInfo: [String: String]
        
        let mcPeerId: IdentifiablePeerID
        
        //TODO: - move to private extension
        
        func buildAdvertiser() -> MCNearbyServiceAdvertiser {
            
            return MCNearbyServiceAdvertiser(peer: mcPeerId,
                                             discoveryInfo: discoveryInfo,
                                             serviceType: serviceType)
            
        }
        
        func buildBrowser() -> MCNearbyServiceBrowser {
            
            return MCNearbyServiceBrowser(peer: mcPeerId,
                                          serviceType: self.serviceType)
            
        }
        
    }
    
    private let configurator: ServiceConfigurator
    
    private var serviceAdvertiser: MCNearbyServiceAdvertiser
    private var serviceBrowser: MCNearbyServiceBrowser

    public weak var delegate: CommunicatorDelegate?
    
    public func send(aMessage jsonData: Data,
              toUserId userID: String,
              whitUserName userName: String,
              complitionHandler: ((Bool, Error?) -> Void)?) {
        
        let synthesizableMCPeerID = IdentifiablePeerID(displayName: userName, uuid: UUID(uuidString: userID) ?? UUID())
        let displayName = synthesizableMCPeerID.displayName
        guard let session = getSession(encodedDisplayName: displayName) else {
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
    
    private var sessions: [MCPeerID: MCSession] = [:]

    public init(serviceConfigurator configurator: ServiceConfigurator,
                mode: CommunicatorMode) {
        
        self.configurator = configurator
        
        self.serviceAdvertiser = configurator.buildAdvertiser()
        self.serviceBrowser = configurator.buildBrowser()
        
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
        
        set(mode: mode)
        
    }
    
    public func set(mode: CommunicatorMode) {
        switch mode {
        case .advertising:
            self.serviceBrowser.stopBrowsingForPeers()
            self.serviceAdvertiser.startAdvertisingPeer()
        case .browsing:
            self.serviceAdvertiser.stopAdvertisingPeer()
            self.serviceBrowser.startBrowsingForPeers()
        case .both:
            self.serviceAdvertiser.startAdvertisingPeer()
            self.serviceBrowser.startBrowsingForPeers()
        }
    }

    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }

    private func generateMessageId() -> String {
        return "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)"
            .data(using: .utf8)!.base64EncodedString()
    }
    
    private func getSession(forPeer peerID: MCPeerID) -> MCSession {
        
        guard let sesssionForPeerId = sessions[peerID] else {
            
            let newSession = MCSession(peer: configurator.mcPeerId,
                                       securityIdentity: nil,
                                       encryptionPreference: .required)
            
            newSession.delegate = self
            sessions[peerID] = newSession
            
            return newSession
            
        }
        
        return sesssionForPeerId
        
    }
    
    private func getSession(encodedDisplayName displayName: String) -> MCSession? {
        
        guard
            let key = sessions.keys.first(where: {$0.displayName == displayName }),
            let session = sessions[key]
        else {
            return nil
        }
        
        return session
        
    }
    
}

extension MultipeerCommunicator: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        print("was invited by\(peerID)")
        
        invitationHandler(true, getSession(forPeer: peerID))
    }
    
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        
    }
}

extension MultipeerCommunicator: MCNearbyServiceBrowserDelegate {
    public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }

    public func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String: String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: getSession(forPeer: peerID), withContext: nil, timeout: 30)
    }

    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
}

extension MultipeerCommunicator: MCSessionDelegate {

    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@",  "didReceiveData: \(data)")
        
        guard let castedPeer = peerID.asIdentifiablePeerID else { return }
        
        self.delegate?.didRecieve(message: data, fromUser: castedPeer.uuid.uuidString)
        
    }

    public func session(_ session: MCSession,
                 didReceive stream: InputStream,
                 withName streamName: String,
                 fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }

    public func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }

    public func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 at localURL: URL?,
                 withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }

    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        //print(#function)
        
        guard let castedPeer = peerID.asIdentifiablePeerID else { return }
        
        switch state {
        case MCSessionState.connected:
            print("Connected: \(castedPeer.decodedName) with id: \(castedPeer.uuid)")
            self.delegate?.didFoundUser(userID: castedPeer.uuid.uuidString, userName: castedPeer.decodedName)
        case MCSessionState.connecting:
            print("Connecting: \(castedPeer.decodedName) with id: \(castedPeer.uuid)")
            self.delegate?.didLostUser(userID: castedPeer.uuid.uuidString)
        case MCSessionState.notConnected:
            print("Not Connected: \(castedPeer.decodedName) with id: \(castedPeer.uuid)")
            self.delegate?.didLostUser(userID: castedPeer.uuid.uuidString)
        @unknown default:
            print ("Unknown state comming in session")
        }
    }

}

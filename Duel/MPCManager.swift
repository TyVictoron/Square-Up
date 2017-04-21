

import UIKit
import MultipeerConnectivity

// delegate allowing for setup of the connections between devices
protocol MPCManagerDelegate {
    func foundPeer()
    
    func lostPeer()
    
    func invitationWasReceived(fromPeer: String)
    
    func connectedWithPeer(peerID: MCPeerID)
    
    func disconnect()
    
}

// this class is for the set up of the conectivity for players to conect to each other
class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    var delegate: MPCManagerDelegate?
    
    var session: MCSession!
    
    var peer: MCPeerID!
    
    var browser: MCNearbyServiceBrowser!
    
    var advertiser: MCNearbyServiceAdvertiser!
    
    var foundPeers = [MCPeerID]()
    
    var invitationHandler: ((Bool, MCSession)->Void)!
    
    var dead = false
    
    var shot = false
    
    var holstered = false
    
    var time = arc4random_uniform(7) + 3
    
    // set up data for other players to see
    override init() {
        super.init()
        
        peer = MCPeerID(displayName: UIDevice.current.name)
        
        session = MCSession(peer: peer)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "SquareUp")
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "SquareUp")
        advertiser.delegate = self
    }
    
    
    // MARK: MCNearbyServiceBrowserDelegate method implementation
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        foundPeers.append(peerID)
        
        delegate?.foundPeer()
    }
    
    
    
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        for (index, aPeer) in foundPeers.enumerated(){
            if aPeer == peerID {
                foundPeers.remove(at: index)
                break
            }
        }
        
        delegate?.lostPeer()
    }
    
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error.localizedDescription)
    }
    
    
    // MARK: MCNearbyServiceAdvertiserDelegate method implementation

    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        self.invitationHandler = invitationHandler
        
        delegate?.invitationWasReceived(fromPeer: peerID.displayName)
    }
    
    
    // MARK: MCSessionDelegate method implementation
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state{
        case MCSessionState.connected:
            print("Connected to session: \(session)")
            delegate?.connectedWithPeer(peerID: peerID)
            
        case MCSessionState.connecting:
            print("Connecting to session: \(session)")
            
        case MCSessionState.notConnected:
            print("No Longer connected to session: \(session)")
            delegate?.disconnect()
            
        default:
            print("Did not connect to session: \(session)")
        }
    }
    
    private func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        certificateHandler(true)
    }
    
    // holds the data for the current sesion that is being played such as the bullet and position and rotations
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("SOMETHING HAPPENED YAY!!!")
        let dictionary: [String: AnyObject] = ["data": data as AnyObject, "fromPeer": peerID]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receivedMPCDataNotification"), object: dictionary)
        let data = dictionary["data"]
        let text = NSString(data: data as! Data, encoding: String.Encoding.utf8.rawValue)!
        print(text)
        
        if text.contains("shot")
        {
            print("Dead")
            dead = true
        }else if (text.contains("Holstered")) {
            print("Holstered")
            holstered = true
        } else {
            print("You Shot First")
            shot = true
        }
        
    }
    
    // functions that do nothing but need to be in as to make the compiler not crash
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) { }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    
    // sends data to the other device via the sesion
    func sendData(dataToSend: String)
    {
         print("sending... : " + dataToSend)
        
        // This done broke VVVV
        //if session.connectedPeers.count > 0
        //{
            do
            {
                try session.send(dataToSend.data(using: .utf8)!, toPeers: session.connectedPeers, with: MCSessionSendDataMode.unreliable)
               print("sent")
            }
            catch
            {
                print("error sending")
            }
            
        //}
    }
}


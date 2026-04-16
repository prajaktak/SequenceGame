//
//  MultipeerSessionManager.swift
//  SequenceGame
//
//  Wraps MCSession, MCNearbyServiceAdvertiser, and MCNearbyServiceBrowser.
//  Acts as the low-level transport layer: sends/receives raw Data and publishes
//  connected peers. Higher-level coordinators (MultiplayerCoordinator on iPad,
//  MultiplayerClient on iPhone) sit on top of this class.
//

import Foundation
import MultipeerConnectivity

/// Low-level MultipeerConnectivity transport.
/// - Advertises or browses for the `sequence-game` service.
/// - Publishes `connectedPeers` and `receivedData` for observers.
final class MultipeerSessionManager: NSObject, ObservableObject {

    // MARK: - Constants

    static let serviceType = "sequence-game"

    // MARK: - Published State

    @Published private(set) var connectedPeers: [MCPeerID] = []
    @Published private(set) var receivedData: (data: Data, from: MCPeerID)?
    /// The most recently disconnected peer, set when a peer transitions to `.notConnected`.
    @Published private(set) var lastDisconnectedPeer: MCPeerID?

    // MARK: - Private Properties

    private let localPeerID: MCPeerID
    private let session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    // MARK: - Init

    init(displayName: String) {
        localPeerID = MCPeerID(displayName: displayName)
        // Use .optional — .required causes TLS handshake failures when a second
        // peer tries to connect while the first is already establishing a session.
        session = MCSession(
            peer: localPeerID,
            securityIdentity: nil,
            encryptionPreference: .optional
        )
        super.init()
        session.delegate = self
    }

    // MARK: - Advertising (Host / iPad)

    /// Start advertising so nearby iPhones can discover this device.
    func startAdvertising() {
        let advertiser = MCNearbyServiceAdvertiser(
            peer: localPeerID,
            discoveryInfo: nil,
            serviceType: Self.serviceType
        )
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        self.advertiser = advertiser
    }

    func stopAdvertising() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
    }

    // MARK: - Browsing (Client / iPhone)

    /// Start browsing for an iPad that is advertising the `sequence-game` service.
    func startBrowsing() {
        let browser = MCNearbyServiceBrowser(
            peer: localPeerID,
            serviceType: Self.serviceType
        )
        browser.delegate = self
        browser.startBrowsingForPeers()
        self.browser = browser
    }

    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
    }

    // MARK: - Sending Data

    /// Send `data` reliably to all connected peers.
    func send(_ data: Data) {
        guard !session.connectedPeers.isEmpty else { return }
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }

    /// Send `data` reliably to a specific peer.
    func send(_ data: Data, to peer: MCPeerID) {
        try? session.send(data, toPeers: [peer], with: .reliable)
    }

    // MARK: - Disconnect

    func disconnect() {
        stopAdvertising()
        stopBrowsing()
        session.disconnect()
    }

    // MARK: - Helpers

    var localPeerIDString: String { localPeerID.displayName }
}

// MARK: - MCSessionDelegate

extension MultipeerSessionManager: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
            if state == .notConnected {
                self.lastDisconnectedPeer = peerID
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.receivedData = (data, peerID)
        }
    }

    // Unused delegate methods — required by the protocol.

    func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {}

    func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {}

    func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MultipeerSessionManager: MCNearbyServiceAdvertiserDelegate {

    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        // Auto-accept all invitations — lobby view handles slot assignment.
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultipeerSessionManager: MCNearbyServiceBrowserDelegate {

    func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        // Automatically invite any discovered host.
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}

//
//  WireGuardView.swift
//  Demo
//
//  Created by Davide De Rosa on 12/16/23.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
//
//  https://github.com/keeshux
//
//  This file is part of TunnelKit.
//
//  TunnelKit is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  TunnelKit is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with TunnelKit.  If not, see <http://www.gnu.org/licenses/>.
//

import SwiftUI
import TunnelKitManager
import TunnelKitWireGuard

struct WireGuardView: View {
    let vpn: NetworkExtensionVPN

    let vpnStatus: VPNStatus

    @State private var clientPrivateKey = "yH+oJ710KOTJzVcK8ms4vCjJqzI8hsC4M5e9+47vSF4="
    
    @State private var presharedKey = "of7seczAv4SdKjjyEQ1SSE3SAIh3wZlWR56yf39ie8Q="

    @State private var clientAddress = "172.31.0.24/32"

    @State private var serverPublicKey = "aL5fOQWbgT4FHR9RVGdy9DOEvI+MOuheSt1e1ejIBGM="

    @State private var serverAddress = "18.130.30.10"

    @State private var serverPort = "63974"

    var body: some View {
        List {
            formView
            buttonView
        }
    }
}

private extension WireGuardView {
    var formView: some View {
        Section {
            TextField("Client private key", text: $clientPrivateKey)
            TextField("Client address", text: $clientAddress)
            TextField("Server public key", text: $serverPublicKey)
            TextField("Server address", text: $serverAddress)
            TextField("Server port", text: $serverPort)
        }
    }

    var buttonView: some View {
        Section {
            Button(vpnStatus.actionText(for: vpnStatus)) {
                switch vpnStatus {
                case .disconnected:
                    connect()

                case .connected, .connecting, .disconnecting:
                    disconnect()
                }
            }
        }
    }

    func connect() {
        guard let cfg = WireGuard.DemoConfiguration.make(params: .init(
            title: "TunnelKit.WireGuard",
            appGroup: appGroup,
            clientPrivateKey: clientPrivateKey,
            clientAddress: clientAddress,
            serverPublicKey: serverPublicKey,
            serverAddress: serverAddress,
            serverPort: serverPort,
            preSharedKey: presharedKey
        )) else {
            print("Configuration incomplete")
            return
        }

        Task {
            try await vpn.reconnect(
                TunnelIdentifier.wireGuard,
                configuration: cfg,
                extra: nil,
                after: .seconds(2)
            )
        }
    }

    func disconnect() {
        Task {
            await vpn.disconnect()
        }
    }
}

#Preview {
    WireGuardView(vpn: NetworkExtensionVPN(),
                  vpnStatus: .disconnected)
}

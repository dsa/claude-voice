//
//  ContentView.swift
//  ClaudeVoice
//
//  Created by Russ Dsa on 3/23/24.
//

import SwiftUI
import UIKit
import RiveRuntime

struct ContentView: View {
    @State private var state = ""
    @StateObject private var avatar = ClaudeAvatar()
    
    var body: some View {
        ZStack {
            Color(hex: "#F0EEE6").ignoresSafeArea()
            VStack {
                avatar.view().frame(width: 100, height: 100)
                Text(state).font(.custom("TiemposHeadline-Light", size: 16)).padding(.top, 20)
            }
        }.onAppear {
            connectToLiveKit()
        }
    }
    
    func connectToLiveKit() {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            DispatchQueue.main.async		 {
                switch state {
                case "Connecting":
                    state = "Connecting."
                case "Connecting.":
                    state = "Connecting.."
                case "Connecting..":
                    state = "Connecting..."
                default:
                    state = "Connecting"
                }
            }
        }
        RunLoop.current.add(timer, forMode: .common)
        
        NotificationCenter.default.addObserver(forName: .lkMeterLevel, object: nil, queue: .main) { notification in
            if let meterLevel = notification.object as? Int, meterLevel > 5, (state == "Listening" || state == "Start speaking") {
                updateState(state: "Listening", animationName: "tickle")
            }
        }
        
        NotificationCenter.default.addObserver(forName: .lkAgentListening, object: nil, queue: .main) { notification in
            updateState(state: "Start speaking", animationName: "waiting")
        }
        
        NotificationCenter.default.addObserver(forName: .lkAgentThinking, object: nil, queue: .main) { notification in
            updateState(state: "", animationName: "thinking")
        }
        
        NotificationCenter.default.addObserver(forName: .lkAgentSpeaking, object: nil, queue: .main) { notification in
            updateState(state: "", animationName: "writing")
        }
        
        Task {
            do {
                try await LiveKitManager.shared.connect()
            } catch let error {
                print("Failed to connect: \(error)")
            }

            timer.invalidate()
        }
    }
    
    @MainActor func updateState(state: String, animationName: String) {
        self.state = state
        avatar.play(animationName: animationName)
    }
}

#Preview {
    ContentView()
}

class ClaudeAvatar: RiveViewModel {
    init() {
        super.init(fileName: "avatar", animationName: "open")
    }
}

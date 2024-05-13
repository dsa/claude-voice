//
//  LiveKitManager.swift
//  ClaudeVoice
//
//  Created by Russ Dsa on 3/23/24.
//

import Foundation
import LiveKit
import Alamofire

class LiveKitManager {
    static let shared = LiveKitManager()
    let url = "wss://eribium.livekit.cloud"
    lazy var room = Room(delegate: self)
    private let processor = AudioBufferInterceptor()
    
    func connect() async throws {
        //request a token from a server
        let tokenUrl = "http://127.0.0.1:5000/token"
        
        // Make a GET request and decode the JSON response
        let response = try await AF.request(tokenUrl).serializingDecodable(TokenResponse.self).value
        
        //connect to a room
        try await room.connect(url: url, token: response.token)
        
        AudioManager.shared.capturePostProcessingDelegate = processor
        try await room.localParticipant.setMicrophone(enabled: true, publishOptions: AudioPublishOptions(dtx: false))
    }
    
    func disconnect() async {
        await room.disconnect()
    }
}


extension LiveKitManager: RoomDelegate {
    func room(_ room: Room, participant: Participant, didUpdateMetadata: String?) {
        if let rawMetadata = didUpdateMetadata, let datagram = rawMetadata.data(using: .utf8) {
            do {
                let metadata = try JSONDecoder().decode(AgentResponse.self, from: datagram)
                switch metadata.state {
                case "listening":
                    NotificationCenter.default.post(name: .lkAgentListening, object: nil)
                case "thinking":
                    NotificationCenter.default.post(name: .lkAgentThinking, object: nil)
                case "speaking":
                    NotificationCenter.default.post(name: .lkAgentSpeaking, object: nil)
                default:
                    NotificationCenter.default.post(name: .lkAgentIdle, object: nil)
                }
            } catch {
                print("Error decoding agent response: \(error)")
            }
        }
    }
}

class AudioBufferInterceptor: AudioCustomProcessingDelegate {

    func audioProcessingInitialize(sampleRate sampleRateHz: Int, channels: Int) {}
    func audioProcessingRelease() {}

    func audioProcessingProcess(audioBuffer: LiveKit.LKAudioBuffer) {
        guard let level = audioBuffer.toAVAudioPCMBuffer()?.audioLevels().combine() else {
            return
        }

        let meterChars: Int = 100
        let meterLevel = Int(Float(meterChars) * level.average)
        
        NotificationCenter.default.post(name: .lkMeterLevel, object: meterLevel)
    }
}

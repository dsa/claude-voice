//
//  NotificationsExtension.swift
//  ClaudeVoice
//
//  Created by Russ Dsa on 3/24/24.
//

import Foundation

extension Notification.Name {
    static let lkConnected = Notification.Name("lkConnected")
    static let lkMicEnabled = Notification.Name("lkMicEnabled")
    static let lkMicDisabled = Notification.Name("lkMicDisabled")
    static let lkMeterLevel = Notification.Name("lkMeterLevel")
    
    static let lkAgentIdle = Notification.Name("lkAgentIdle")
    static let lkAgentListening = Notification.Name("lkAgentListening")
    static let lkAgentThinking = Notification.Name("lkAgentThinking")
    static let lkAgentSpeaking = Notification.Name("lkAgentSpeaking")
}

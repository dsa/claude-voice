//
//  AgentResponse.swift
//  ClaudeVoice
//
//  Created by Russ Dsa on 3/23/24.
//

struct AgentResponse: Codable {
    let state: String
    
    private enum CodingKeys: String, CodingKey {
        case state = "agent_state"
    }
}

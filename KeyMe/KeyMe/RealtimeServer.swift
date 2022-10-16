//
//  RealtimeServer.swift
//  KeyMe
//
//  Created by Roman Koval on 2022-10-15.
//

import Foundation

// https://github.com/frzi/SwiftChatApp/blob/master/App/Shared/Views/ChatScreen.swift
class RealtimeServer {
    private var sampleRate: Int?
    private var frameSize: Float?
    
    private var webSocketTask: URLSessionWebSocketTask?

    func connect(sampleRate: Int, frameSize: Float) {
        guard webSocketTask == nil else {
            return
        }
        
        self.sampleRate = sampleRate
        self.frameSize = frameSize

        let url = URL(string: "ws://192.168.2.85:8001")!
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        
        send(data: "{ \"sampleRate\": \(sampleRate), \"frameSize\": \(frameSize) }".data(using: .utf8)!)
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }

    func send(data: Data) {
        webSocketTask?.send(.data(data), completionHandler: { error in
            if let error = error {
                print("Error sending message", error)
            }
        })
        
//        webSocketTask?.send(.string(jsonString)) { error in
//            if let error = error {
//                print("Error sending message", error)
//            }
//        }
    }
    
    deinit {
        disconnect()
    }
}

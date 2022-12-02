//
//  PlaybackServer.swift
//  KeyMe
//
//  Created by Roman Koval on 2022-12-01.
//

import Foundation

class PlaybackServer {
    private static let HOST = URL(string: "ws://192.168.1.155:8002")!
    
    static let shared = PlaybackServer()
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    private init() {
    }
    
    func disconnect() {
        guard let webSocketTask = webSocketTask else {
            return
        }

        webSocketTask.cancel(with: .normalClosure, reason: nil)
    }
    
    func connect() {
        if (webSocketTask != nil) {
            disconnect()
        }
        
        webSocketTask = URLSession.shared.webSocketTask(with: PlaybackServer.HOST)
        webSocketTask?.resume()
        
        print("connected to playback ws")
    }
    
    func send(code: UInt8, payload: String) {
        let payloadData = payload.data(using: .utf8)!
        
        var data = Data(capacity: payloadData.count + 1)
        data.append(code)
        data.append(payloadData)
                
        send(data: data)
    }
    
    func send(data: Data) {
        guard let webSocketTask = webSocketTask else {
            return
        }

        webSocketTask.send(.data(data), completionHandler: { error in
            if let error = error {
                print("Error sending message", error)
            }
        })
    }
}

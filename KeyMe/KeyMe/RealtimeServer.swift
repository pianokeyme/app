//
//  RealtimeServer.swift
//  KeyMe
//
//  Created by Roman Koval on 2022-10-15.
//

import Foundation

// https://github.com/frzi/SwiftChatApp/blob/master/App/Shared/Views/ChatScreen.swift
class RealtimeServer {
    static let shared = RealtimeServer()
    
    private var webSocketTask: URLSessionWebSocketTask?

    private init() {
    }
    
    func connect() {
        if (webSocketTask != nil) {
            disconnect()
        }

        let url = URL(string: "ws://192.168.1.155:8001")!
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        
        print("connected to ws")
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }
    
    func send(code: UInt8, payload: String) {
        let payloadData = payload.data(using: .utf8)!
        
        var data = Data(capacity: payloadData.count + 1)
        data.append(code)
        data.append(payloadData)
                
        send(data: data)
    }
    
    func send(code: UInt8, buf: UnsafeRawPointer, n: Int) {
        var data = Data(capacity: n + 1)
        data.append(code)
        data.append(buf.bindMemory(to: UInt8.self, capacity: n), count: n)
        
        send(data: data)
    }

    func send(data: Data) {
        webSocketTask?.send(.data(data), completionHandler: { error in
            if let error = error {
                print("Error sending message", error)
            }
        })
    }
    
    deinit {
        disconnect()
    }
}

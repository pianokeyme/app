//
//  AudioRecorder.swift
//  KeyMe
//
//  Created by Youssef Elfaramawy on 2022-11-10.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

class AudioRecorder {
    let server = RealtimeServer()
    var audioEngine = AVAudioEngine()
        
    func handleFile(url: URL) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(atPath: url.path)
                print("Removed file")
            } catch let error {
                print("Error on removing data file: \(error)")
            }
        }
        let contents = Data()
        fileManager.createFile(atPath: url.path, contents: contents)
        print("Created File")
    }
    
    func getCacheDirectoryPath() -> URL {
      let arrayPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
      let cacheDirectoryPath = arrayPaths[0]
      return cacheDirectoryPath
    }
    
    func setAudioSessionToRecord() {
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func checkMicPermission() -> Bool {

        var permissionCheck: Bool = false

        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            permissionCheck = true
        case .denied:
            permissionCheck = false
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    permissionCheck = true
                } else {
                    permissionCheck = false
                }
            })
        default:
            break
        }

        return permissionCheck
    }
    
    func getAudio() {
        if (checkMicPermission()) {
            let inputNode = audioEngine.inputNode
            
            let outputPath = getCacheDirectoryPath().appendingPathComponent("data.txt")
            print("Writing to \(outputPath)")
            
            handleFile(url: outputPath)
            
            print(AVAudioSession.sharedInstance().sampleRate)
                    
            // onBus: 0 -> mono input
            // bufferSize -> not guaranteed
            // format: nil -> no translation
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0), block: {
                (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
                
                let audioBuffer = buffer.audioBufferList.pointee.mBuffers
                let data = Data(bytes: audioBuffer.mData!, count: Int(audioBuffer.mDataByteSize))
                
                self.server.send(data: data)
            
            })
            
            audioEngine.prepare()
            do {
                setAudioSessionToRecord()
                try audioEngine.start()
            } catch let error as NSError {
                print("Got an error starting audioEngine: \(error.domain), \(error)")
            }
        }
    }
    
    func stopAudio() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }
}
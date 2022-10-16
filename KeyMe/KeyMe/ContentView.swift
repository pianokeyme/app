//
//  ContentView.swift
//  KeyMe
//
//  Created by Roman Koval on 2022-09-19.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State var isPlaying = false
    let server = RealtimeServer()

    var body: some View {
        Button(action: {
            NSLog("Button click")
            isPlaying.toggle()
            isPlaying ? getAudio() : stopAudio()
        }) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(Color(red: 143/255, green: 0, blue: 26/255))
                .padding(20)
                .overlay(
                   Circle().stroke(Color(red: 143/255, green: 0, blue: 26/255), lineWidth: 4))
        }.onAppear(perform: connect)
    }
    
    private func connect() {
        server.connect(sampleRate: Int(AVAudioSession.sharedInstance().sampleRate), frameSize: 0.1)
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

                let actualSampleCount = Int(buffer.frameLength)
                var i = 0
                var samplesAsDoubles: [Double] = []
                            
                while (i < actualSampleCount) {
                    let theSample = Double((buffer.floatChannelData?.pointee[i])!)
                    samplesAsDoubles.append(theSample)
                    //NSLog("sample: %f", theSample)
                    i += 1
                }
                
                let audioBuffer = buffer.audioBufferList.pointee.mBuffers
                let data = Data(bytes: audioBuffer.mData!, count: Int(audioBuffer.mDataByteSize))
                                
                server.send(data: data)
                
    //            let sampleData = samplesAsDoubles.map { String(format: "%f", $0) }.joined(separator: "\n") + "\n"
    //
    //            do {
    //                if let handle = try? FileHandle(forWritingTo: outputPath) {
    //                    handle.seekToEndOfFile() // moving pointer to the end
    //                    handle.write(sampleData.data(using: .utf8)!) // adding content
    //                    handle.closeFile() // closing the file
    //                }
    //            } //catch let error {
                    //print("Error on writing strings to file: \(error)")
                //}
            })
            
            //try? AVAudioSession.sharedInstance().setPreferredSampleRate(16000.0)
            //print(AVAudioSession.sharedInstance().preferredSampleRate)
            
            // change sampling rate of input node
            //let newAudioFormat = AVAudioFormat.init(commonFormat: .pcmFormatFloat32, sampleRate: 16000.0, channels: 1, interleaved: true)
            //audioEngine.connect(inputNode, to: mixer, format: inputNode.inputFormat(forBus: 0))
            //mixer.volume = 0
            //audioEngine.connect(mixer, to: audioEngine.outputNode, format: newAudioFormat)
            
            audioEngine.prepare()
            do {
                setAudioSessionToRecord()
                try audioEngine.start()
            } catch let error as NSError {
                print("Got an error starting audioEngine: \(error.domain), \(error)")
            }
        }
    }
}

func setAudioSessionToRecord() {
    try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
    try? AVAudioSession.sharedInstance().setActive(true)
}

//func setAudioSessionToPlayBack() {
//    try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//}

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

//var audioRecorder = AVAudioRecorder()

//func recordAudio() {
//    if (checkMicPermission()) {
//        let audioFilename = getCacheDirectoryPath().appendingPathComponent("recording.wav")
//
//        let recordSettings: [String : Any] = [
//            AVFormatIDKey: Int(kAudioFormatLinearPCM),
//            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
//            AVEncoderBitRateKey: 192000,
//            AVNumberOfChannelsKey: 1,
//            AVSampleRateKey: 44100.0
//        ]
//
//        let session = AVAudioSession.sharedInstance()
//
//        do {
//            try session.setCategory(.playAndRecord, mode: .default)
//            try session.setActive(true)
//            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: recordSettings)
//            //audioRecorder.delegate = self
//            audioRecorder.isMeteringEnabled = true
//            audioRecorder.prepareToRecord()
//            audioRecorder.record()
//        } catch {
//            print("Error")
//            stopRecording()
//        }
//    }
//}

//func stopRecording() {
//    audioRecorder.stop()
//    setAudioSessionToPlayBack()
//}

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

var audioEngine = AVAudioEngine()

func stopAudio() {
    audioEngine.inputNode.removeTap(onBus: 0)
    audioEngine.stop()
    //setAudioSessionToPlayBack()
}

func getCacheDirectoryPath() -> URL {
  let arrayPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
  let cacheDirectoryPath = arrayPaths[0]
  return cacheDirectoryPath
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

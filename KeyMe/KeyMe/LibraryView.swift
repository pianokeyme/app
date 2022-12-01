//
//  LibraryView.swift
//  KeyMe
//
//  Created by Youssef Elfaramawy on 2022-11-24.
//

import SwiftUI
import AVFoundation

@available(iOS 16.0, *)
struct LibraryView: View {
    @State var isRecording = false
    @State var isPlayback = false

    let audioRecorder: AudioRecorder
    let server: RealtimeServer
    
    init() {
        server = RealtimeServer()
        audioRecorder = AudioRecorder(server: server)
    }
    
    var body: some View {
        VStack {
            RecordingsList()
            .safeAreaInset(edge: .bottom) {
                bottomBar
            }
            .refreshable {
                ApiService.shared.getAllRecordings()
            }
        }
        .navigationTitle("Library")
        .onAppear {
            ApiService.shared.getAllRecordings()
        }
    }
    
    var bottomBar: some View {
        Button(action: {
            NSLog("Button click")
            isRecording.toggle()
            isRecording ? audioRecorder.getAudio() : audioRecorder.stopAudio()
        })
        {
            Image(systemName: isRecording ? "stop.circle" : "record.circle")
                .font(.system(size: 90, weight: .bold))
                .foregroundColor(Color(red: 143/255, green: 0, blue: 26/255))
                .padding(20)
        }
        .onAppear(perform: connect)
    }
    
    private func connect() {
        server.connect()
    }
}

@available(iOS 16.0, *)
struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}

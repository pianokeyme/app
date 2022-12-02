//
//  RecordingsList.swift
//  KeyMe
//
//  Created by Youssef Elfaramawy on 2022-11-10.
//

import SwiftUI
import AVFoundation

var audioPlayer: AVPlayer!

@available(iOS 16.0, *)
struct RecordingsList: View {
    @State private var showSheet = false
    
    let audioRecorder: AudioRecorder
    
    @StateObject var apiService = ApiService.shared
    
    init() {
        self.audioRecorder = AudioRecorder()
    }

    var body: some View {
        List {
            ForEach(apiService.recordings, id: \.id) { recording in
                RecordingRow(recording: recording)
                    .onTapGesture {
                        PlaybackServer.shared.connect()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            PlaybackServer.shared.send(code: 100, payload: "{ \"recordingId\": \(recording.id) }")
                            
                            audioRecorder.setAudioSessionToRecord()
                            
                            let url = URL(string: recording.audio_url)!
                            
                            audioPlayer = AVPlayer(url: url)
                            //print("About to play...")
                            audioPlayer.volume = 1.0
                            //audioPlayer.play()
                            //print("...and we're playing!")
                        }
                        
                        showSheet.toggle()
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            ApiService.shared.removeRecording(recording)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(PlainListStyle())
        .sheet(isPresented: $showSheet) {
            RecordBottomSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
                .onDisappear {
                    PlaybackServer.shared.send(code: 103, payload: "{}")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        PlaybackServer.shared.disconnect()
                    }
                }
        }
    }
}

struct RecordBottomSheet: View {
    @State var isPlaying: Bool = false
    @State var selectedRate = "1.0"
    
    var playbackRates = ["0.25", "0.5", "0.75", "1.0", "1.25", "1.5", "1.75", "2.0"]
    
    func play() {
        let rate = Float(selectedRate)!
        PlaybackServer.shared.send(code: 101, payload: "{ \"rate\": \(rate) }")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            audioPlayer.playImmediately(atRate: rate)
        }
    }
    
    func pause() {
        PlaybackServer.shared.send(code: 102, payload: "{}")
        audioPlayer.pause()
    }
    
    var body: some View {
        Button(action: {
            NSLog("Button click")
            isPlaying.toggle()
            
            if (isPlaying) {
                play()
            } else {
                pause()
            }
        })
        {
            if isPlaying {
                Image(systemName: "pause.fill")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(Color(red: 143/255, green: 0, blue: 26/255))
                    .padding(20)
                    .overlay(
                        Circle().stroke(Color(red: 143/255, green: 0, blue: 26/255), lineWidth: 4))
            } else {
                Image(systemName: "play.fill")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(Color(red: 143/255, green: 0, blue: 26/255))
                    .padding(20)
                    .overlay(
                        Circle().stroke(Color(red: 143/255, green: 0, blue: 26/255), lineWidth: 4))
            }
        }
        if (!isPlaying) {
            Picker("Playback Rate", selection: $selectedRate) {
                ForEach(playbackRates, id: \.self) {
                    Text($0)
                }
            }
            .onChange(of: selectedRate, perform: { _ in
                audioPlayer.rate = Float(selectedRate)!
                audioPlayer.pause()
            })
            .pickerStyle(.wheel)
        } else {
            Picker("Playback Rate", selection: $selectedRate) {
                Text(selectedRate).tag(0)
            }
            .pickerStyle(.wheel)
        }
    }
}

struct RecordingRow: View {
    let recording: Recording
    let name: String
    
    init(recording: Recording) {
        self.recording = recording
        
        var name = recording.name
        
        if (name.isEmpty) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            let date = formatter.date(from: recording.created_at)!
            name = date.formatted(
                Date.FormatStyle()
                    .month(.abbreviated)
                    .day(.defaultDigits)
                    .weekday(.abbreviated)
                    .hour()
                    .minute()
            )
        }
        
        self.name = name
    }
    
    var body: some View {
        HStack {
            Text(name)
            Spacer()
        }
    }
}

@available(iOS 16.0, *)
struct RecordingsList_Previews: PreviewProvider {
    static let recordings: [Recording] = [
        Recording(audio_id: 1, audio_url: "https://keyme-dev.s3.ca-central-1.amazonaws.com/EwtLGtEgD6QPBMY94pxrLx/audio.mp3", audio_version: 1, created_at: "2022-11-30T23:02:42.305818-05:00", created_by: 1, id: 1, is_preprocessed: false, name: ""),
        Recording(audio_id: 1, audio_url: "https://keyme-dev.s3.ca-central-1.amazonaws.com/EwtLGtEgD6QPBMY94pxrLx/audio.mp3", audio_version: 1, created_at: "2022-11-30T23:02:42.305818-05:00", created_by: 1, id: 2, is_preprocessed: true, name: "Rondo Alla Turca")
    ]
        
    static var previews: some View {
        RecordingsList()
    }
}

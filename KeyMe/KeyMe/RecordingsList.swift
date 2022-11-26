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
    
    let audioRecorder = AudioRecorder()
    
    var recordings = [Recording(fileURL: URL(string: "https://www2.cs.uic.edu/~i101/SoundFiles/CantinaBand3.wav")!, createdAt: Date()), Recording(fileURL: URL(string: "https://www2.cs.uic.edu/~i101/SoundFiles/Fanfare60.wav")!, createdAt: Date())]

    var body: some View {
        List {
            ForEach(recordings, id: \.createdAt) { recording in
                RecordingRow(audioURL: recording.fileURL)
                    .onTapGesture {
                        audioRecorder.setAudioSessionToRecord()
                        
                        let url = recording.fileURL

                        audioPlayer = AVPlayer(url: url)
                        print("About to play...")
                        audioPlayer.volume = 1.0
                        audioPlayer.play()
                        print("...and we're playing!")
                        showSheet.toggle()
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(PlainListStyle())
        .sheet(isPresented: $showSheet) {
            RecordBottomSheet(isRecord: true)
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
        }
    }
}

struct RecordBottomSheet: View {
    @State var isPlaying: Bool
    let audioRecorder = AudioRecorder()
    
    init(isRecord: Bool) {
        self.isPlaying = isRecord
    }
    
    var body: some View {
        Button(action: {
            NSLog("Button click")
            isPlaying.toggle()
            isPlaying ? audioPlayer.play() : audioPlayer.pause()
        })
        {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(Color(red: 143/255, green: 0, blue: 26/255))
                .padding(20)
                .overlay(
                    Circle().stroke(Color(red: 143/255, green: 0, blue: 26/255), lineWidth: 4))
        }
    }
}

struct RecordingRow: View {
    
    var audioURL: URL
    
    var body: some View {
        HStack {
            Text("\(audioURL.lastPathComponent)")
            Spacer()
        }
    }
}

struct Recording {
    let fileURL: URL
    let createdAt: Date
}

struct Composition: Codable, Hashable, Identifiable {
    var id: Int
    var name: String
    var audio_id: Int
    var analyzed_id: Int
    var created_by: Int
    var created_at: Date
}

@available(iOS 16.0, *)
struct RecordingsList_Previews: PreviewProvider {
    static var previews: some View {
        RecordingsList()
    }
}

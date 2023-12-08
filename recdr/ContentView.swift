import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentlyPlaying: URL?
    @State private var playbackVolume: Float = 1.0
    
    var body: some View {
        VStack {
            Text("Recorder")
                .padding()

            Button(action: {
                if audioRecorder.isRecording {
                    audioRecorder.stopRecording()
                } else {
                    audioRecorder.record()
                }
            }) {
                Text(audioRecorder.isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .background(audioRecorder.isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Slider(value: $playbackVolume, in: 0...1)
                .onChange(of: playbackVolume) { newVolume in
                    audioPlayer?.volume = newVolume
                }

            List {
                ForEach(audioRecorder.recordingsList, id: \.self) { recording in
                    HStack {
                        Text(recording.lastPathComponent)
                        Spacer()
                        if isPlaying && currentlyPlaying == recording {
                            Button("Stop") {
                                audioPlayer?.pause()
                                isPlaying = false
                            }
                        }
                    }
                    .onTapGesture {
                        if currentlyPlaying == recording {
                            stopPlayback()
                        } else {
                            playRecording(recording)
                        }
                    }
                }.onDelete(perform: deleteRecording)
            }
        }
        .onAppear {
            AudioSession.shared.requestRecordPermission { granted in
                if granted {
                    print("Permission granted")
                } else {
                    print("Permission denied")
                    // todo handle permission denied
                }
            }
        }
        .padding()
    }
    
    func playRecording(_ url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            isPlaying = true
            currentlyPlaying = url
        } catch {
            print("Playback failed: \(error)")
        }
    }
    
    
    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
        currentlyPlaying = nil
    }

    
    func deleteRecording(at offsets: IndexSet) {
        for index in offsets {
             let recording = audioRecorder.recordingsList[index]
             do {
                 try FileManager.default.removeItem(at: recording)
                 audioRecorder.recordingsList.remove(at: index)
             } catch {
                 print("Error deleting recording: \(error)")
             }
         }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

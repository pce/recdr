import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var audioProcessor = AudioProcessor()

    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentlyPlaying: URL?
    @State private var playbackVolume: Float = 1.0

    init() {
        _audioProcessor = StateObject(wrappedValue: AudioProcessor())
        audioProcessor.onRecordingSaved = { [weak audioRecorder] in
            audioRecorder?.updateRecordingsList()
        }
    }
    
    var body: some View {
        NavigationView {
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

                RecordingListView(
                              audioRecorder: audioRecorder,
                              playRecording: playRecording,
                              stopPlayback: stopPlayback,
                              deleteRecording: deleteRecording,
                              isPlaying: isPlaying,
                              currentlyPlaying: currentlyPlaying
                          )
            }
            .navigationBarTitle("Recordings")
        }
        .onAppear {
            AudioSession.shared.requestRecordPermission { granted in
                if granted {
                    print("Permission granted")
                } else {
                    print("Permission denied")
                    // TODO: Handle permission denied
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
            isPlaying = false
            currentlyPlaying = nil
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

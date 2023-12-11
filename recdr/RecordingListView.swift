import SwiftUI

struct RecordingListView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    var playRecording: (URL) -> Void
    var stopPlayback: () -> Void
    var deleteRecording: (IndexSet) -> Void
    var isPlaying: Bool
    var currentlyPlaying: URL?

    var body: some View {
        List {
            ForEach(audioRecorder.recordingsList, id: \.self) { recording in
                HStack {
                    if isPlaying && currentlyPlaying == recording {
                        Button("Stop", action: stopPlayback)
                    } else {
                        Button("Play") {
                            playRecording(recording)
                        }
                    }
                    NavigationLink(destination: AudioView(audioURL: recording)) {
                        Text("Edit \(recording.lastPathComponent)")
                    }
                }
            }.onDelete(perform: deleteRecording)
        }
        .gesture(
            DragGesture(minimumDistance: 50, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.height < 0 && abs(value.translation.width) < abs(value.translation.height) {
                        // Swipe Up - Ignore
                    } else if value.translation.height > 0 && abs(value.translation.width) < abs(value.translation.height) {
                        // Swipe Down - Refresh
                        audioRecorder.fetchRecordings()  // Make sure fetchRecordings is accessible
                    }
                }
        )
    }
}

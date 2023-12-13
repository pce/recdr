import SwiftUI

struct RecordingListView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var showShareSheet = false
    @State private var itemToShare: URL?
    var playRecording: (URL) -> Void
    var stopPlayback: () -> Void
    var deleteRecording: (IndexSet) -> Void
    var isPlaying: Bool
    var currentlyPlaying: URL?
    
    var body: some View {
        List {
            ForEach(audioRecorder.recordingsList, id: \.self) { recording in
                HStack {
                    VStack(alignment: .leading) {
                        Text(recording.lastPathComponent)
                            .onTapGesture {
//                                if isPlaying && currentlyPlaying == recording {
//                                    stopPlayback()
//                                } else {
                                    playRecording(recording)
//                                }
                            }
                    }
                    Spacer()
                    
                    Button(action: {
                        itemToShare = recording
                        showShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: AudioView(audioURL: recording)) {
                        Text("Edit")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }.onDelete(perform: deleteRecording)
        }
        .sheet(isPresented: $showShareSheet, content: {
            if let itemToShare = itemToShare {
                ActivityViewController(activityItems: [itemToShare])
            }
        })
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

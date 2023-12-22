import SwiftUI

struct RecordingListView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var showShareSheet = false
    @State private var itemToShare: URL?
    @State private var selectedRecording: URL?
    @State private var isNavigationLinkActive = false
    
    var playRecording: (URL) -> Void
    var stopPlayback: () -> Void
    var deleteRecording: (IndexSet) -> Void
    var isPlaying: Bool
    var currentlyPlaying: URL?
    
    var body: some View {
        List {
            ForEach(audioRecorder.recordingsList, id: \.self) { recording in
                VStack {
                    
                    HStack {
                        
                        NavigationLink(destination: AudioView(audioURL: recording)) {
                            Text("\(recording.lastPathComponent)")
                        }
                        
                    }.swipeActions(edge: .leading, allowsFullSwipe: true) {
                        if isPlaying && currentlyPlaying == recording {
                            Button {
                                // Stop playback action
                                stopPlayback()
                            } label: {
                                Label("Stop", systemImage: "stop.fill")
                            }
                            .tint(.red)
                        } else {
                            Button {
                                // Play recording action
                                playRecording(recording)
                            } label: {
                                Label("Play", systemImage: "play.circle")
                            }
                            .tint(.green)
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            // Share recording action
                            itemToShare = recording
                            showShareSheet = true
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .tint(.blue)
                        
                        Button(role: .destructive) {
                            // Delete recording action
                            if let indexSet = audioRecorder.recordingsList.firstIndex(of: recording) {
                                deleteRecording(IndexSet(integer: indexSet))
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    
                }
            }
            .onDelete(perform: deleteRecording)
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
                        audioRecorder.fetchRecordings()
                    }
                }
        )
    }
}

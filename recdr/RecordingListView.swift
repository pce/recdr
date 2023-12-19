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
                                                
                        Button(action: {
                            if isPlaying && currentlyPlaying == recording {
                                stopPlayback()
                            } else {
                                playRecording(recording)
                            }
                        }) {
                            Image(systemName: isPlaying && currentlyPlaying == recording ? "stop.fill" : "play.fill")
                        }
                        
                        Button(action: {
                            itemToShare = recording
                            showShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        
                    }
                    
                    HStack {
                        
                        Text(recording.lastPathComponent)
                        
                        Spacer()
                        
                        Button(action: {
                            self.selectedRecording = recording
                            self.isNavigationLinkActive = true
                        }) {
                            Image(systemName: "waveform.circle.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                }
                .background(
                    NavigationLink(destination: AudioView(audioURL: recording), isActive: $isNavigationLinkActive) {
                        EmptyView()
                    }
                        .hidden()
                )
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

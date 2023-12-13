import SwiftUI

struct NavigationDestinationLink: Identifiable, Hashable {
    let id: UUID = UUID()
    let url: URL
    
    // Implementing the hash function
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    // Implementing the equality operator
    static func ==(lhs: NavigationDestinationLink, rhs: NavigationDestinationLink) -> Bool {
        lhs.id == rhs.id
    }
}
struct RecordingListView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var showShareSheet = false
    @State private var itemToShare: URL?
    @State private var selectedRecording: NavigationDestinationLink?
    @State private var isNavigationLinkActive = false
    
    
    var playRecording: (URL) -> Void
    var stopPlayback: () -> Void
    var deleteRecording: (IndexSet) -> Void
    var isPlaying: Bool
    var currentlyPlaying: URL?
    
    var body: some View {
        List {
            ForEach(audioRecorder.recordingsList, id: \.self) { recording in
                HStack {
                    Spacer()
                    Button(action: {
                        if isPlaying && currentlyPlaying == recording {
                            stopPlayback()
                        } else {
                            playRecording(recording)
                        }
                    }) {
                        Image(systemName: isPlaying && currentlyPlaying == recording ? "stop.fill" : "play.fill")
                    }
                    Spacer()
                    
                    Text(recording.lastPathComponent)
                        .onTapGesture {
                            self.selectedRecording = NavigationDestinationLink(url: recording)
                            self.isNavigationLinkActive = true
                        }
                    
                    Button(action: {
                        itemToShare = recording
                        showShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    
                    Image(systemName: "waveform.circle.fill")
                        .onTapGesture {
                            self.selectedRecording = NavigationDestinationLink(url: recording)
                            self.isNavigationLinkActive = true
                        }
                    
                    // Workarround with invisible NavigationLink
                    NavigationLink(
                        destination: AudioView(audioURL: recording),
                        isActive: $isNavigationLinkActive
                    ) {
                        EmptyView()
                    }
                    .frame(width: 0, height: 0)
                    .hidden()
                    
                }
            }.onDelete(perform: deleteRecording)
        }
        .navigationDestination(for: NavigationDestinationLink.self) { link in
            AudioView(audioURL: link.url)
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

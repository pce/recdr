import SwiftUI

struct AudioView: View {
    @StateObject private var audioProcessor = AudioProcessor()
    @State private var isPlaying = false
    var audioURL: URL
    
    var body: some View {
        VStack {
            Button(isPlaying ? "Stop" : "Play") {
                if isPlaying {
                    audioProcessor.player?.stop()
                } else {
                    audioProcessor.play()
                }
                isPlaying.toggle()
            }

            Button("Import Audio") {
                // Implement file import logic
                // Update audioProcessor with the imported file
            }

            // Sliders for reverb and delay
            Slider(value: Binding(get: {
                audioProcessor.reverb?.dryWetMix ?? 0.5
            }, set: { (newVal) in
                audioProcessor.reverb?.dryWetMix = newVal
            }), in: 0...1, step: 0.1)
            .padding()

            Slider(value: Binding(get: {
                audioProcessor.delay?.time ?? 1.0
            }, set: { (newVal) in
                audioProcessor.delay?.time = newVal
            }), in: 0...5, step: 0.1)
            .padding()
            
            .onAppear {
                audioProcessor.importAudio(url: audioURL)
            }
        }
    }
}

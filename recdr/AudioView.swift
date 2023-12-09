import SwiftUI
import AVFoundation

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

            Text("Reverb Controls")
                .font(.headline)
                .padding()


            Picker("Reverb Preset", selection: $audioProcessor.selectedReverbPreset) {
                ForEach(AVAudioUnitReverbPreset.allCases, id: \.self) { preset in
                    Text(preset.name).tag(preset)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            HStack {
                Text("Dry/Wet Mix")
                Slider(value: Binding(get: {
                    audioProcessor.reverb?.dryWetMix ?? 0.5
                }, set: { newVal in
                    audioProcessor.reverb?.dryWetMix = newVal
                }), in: 0...1, step: 0.1)
            }
            .padding()

            // Add more sliders for other reverb parameters as needed

            Text("Delay Controls")
                .font(.headline)
                .padding()

            HStack {
                Text("Time")
                Slider(value: Binding(get: {
                    audioProcessor.delay?.time ?? 1.0
                }, set: { newVal in
                    audioProcessor.delay?.time = newVal
                }), in: 0...5, step: 0.1)
            }
            .padding()
            HStack {
                Text("Feedback")
                Slider(value: Binding(get: {
                    audioProcessor.delay?.feedback ?? 50.0
                }, set: { newVal in
                    audioProcessor.delay?.feedback = newVal
                }), in: -100...100, step: 1.0)
            }
            .padding()
            HStack {
                Text("lowPassCutoff")
                Slider(value: Binding(get: {
                    audioProcessor.delay?.lowPassCutoff ?? 15000.0
                }, set: { newVal in
                    audioProcessor.delay?.lowPassCutoff = newVal
                }), in: 10...22050, step: 1.0)
            }
            .padding()
            Button("Start Recording") {
                audioProcessor.startRecording()
            }

            Button("Stop and Export") {
                audioProcessor.stopRecordingAndSave()
            }


        }
        .onAppear {
            audioProcessor.importAudio(url: audioURL)
        }
    }
}

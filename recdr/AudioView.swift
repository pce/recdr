import SwiftUI
import AVFoundation

struct AudioView: View {
    @StateObject private var audioProcessor = AudioProcessor()
    @State private var isPlaying = false
    // collapsible
    @State private var isTimePitchExpanded = false
    @State private var isCompressorExpanded = false
    @State private var isLimiterExpanded = false
    @State private var panValue: AUValue = 0.0  //  -1 (left) to 1 (right)
    
    @State private var waveformCursorPosition: CGFloat = 0.0
    
    //    @State private var is3DSoundExpanded = false
    //    @State private var is3DSoundEnabled = false
    @State private var xParameter: String = "Pan"
    @State private var yParameter: String = "Filter"
    @State private var xyPadPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    
    let parameterOptions = ["Pan", "Filter", "Pitch"]

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
            
            
            if audioProcessor.isRecording {
                Button("Stop Recording") {
                    audioProcessor.stopRecordingAndSave()
                }
            } else {
                Button("Start Recording") {
                    audioProcessor.startRecording()
                }
                
            }

            HStack {
                WaveformView(audioURL: audioURL, cursorPosition: $waveformCursorPosition)
                       .frame(height: 100) 
            }
            
            ScrollView {
                VStack {
                    
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
                    
                    
                    // Slider with label and value
//                    VStack(alignment: .leading) {
//                        Text("Dry/Wet Mix")
//                            .font(.headline)
//                            .padding([.top, .leading])
//
//                        HStack {
//                            Slider(value: Binding(get: {
//                                audioProcessor.reverb?.dryWetMix ?? 0.5
//                            }, set: { newVal in
//                                audioProcessor.reverb?.dryWetMix = newVal
//                            }), in: 0...1, step: 0.1)
//
//                            Text("\(audioProcessor.reverb?.dryWetMix ?? 0.5, specifier: "%.2f")")
//                                .frame(width: 50, alignment: .trailing)
//                        }
//                        .padding([.leading, .trailing])
//                    }

                    
                    Text("Delay Controls")
                        .font(.headline)
                        .padding()
                    HStack {
                        Text("Time")
                        Slider(value: Binding(get: {
                            audioProcessor.delay?.time ?? 1.0
                        }, set: { newVal in
                            audioProcessor.delay?.time = newVal
                        }), in: 0...2, step: 0.01)
                    }
                    .padding()
                    HStack {
                        Text("Feedback")
                        Slider(value: Binding(get: {
                            audioProcessor.delay?.feedback ?? 0.0
                        }, set: { newVal in
                            audioProcessor.delay?.feedback = newVal
                        }), in: -100...100, step: 1.0)
                    }
                    .padding()
                    HStack {
                        Text("lowPassCutoff")
                        Slider(value: Binding(get: {
                            audioProcessor.delay?.lowPassCutoff ?? 80
                        }, set: { newVal in
                            audioProcessor.delay?.lowPassCutoff = newVal
                        }), in: 10...200, step: 0.5)
                    }
                    .padding()

                    DisclosureGroup("Time Pitch", isExpanded: $isTimePitchExpanded) {
                        HStack {
                            Text("Pitch")
                            Slider(value: Binding(get: {
                                audioProcessor.timePitch?.pitch ?? 0.0
                            }, set: { newVal in
                                audioProcessor.timePitch?.pitch = newVal
                            }), in: -2400...2400, step: 1.0)
                        }
                        .padding()
                        HStack {
                            Text("Pitch Rate")
                            Slider(value: Binding(get: {
                                audioProcessor.timePitch?.rate ?? 1.0
                            }, set: { newVal in
                                audioProcessor.timePitch?.rate = newVal
                            }), in: 0.03125...32.0, step: 0.1)
                        }
                    }
                    
                    .padding()

                    DisclosureGroup("Compressor Controls", isExpanded: $isCompressorExpanded) {

                        HStack {
                            Text("Attack Time")
                            Slider(value: Binding(get: {
                                audioProcessor.compressor?.attackTime ?? 0.001
                            }, set: { newVal in
                                audioProcessor.compressor?.attackTime = newVal
                            }), in: 0.0001...0.2)
                        }
                        .padding()
                        
                        HStack {
                            Text("Release Time")
                            Slider(value: Binding(get: {
                                audioProcessor.compressor?.releaseTime ?? 0.05
                            }, set: { newVal in
                                audioProcessor.compressor?.releaseTime = newVal
                            }), in: 0.01...3)
                        }
                        .padding()
                        
                        HStack {
                            Text("Threshold")
                            Slider(value: Binding(get: {
                                audioProcessor.compressor?.threshold ?? -20
                            }, set: { newVal in
                                audioProcessor.compressor?.threshold = newVal
                            }), in: -40...20)
                        }
                        .padding()
                        
                        HStack {
                            Text("Head Room")
                            Slider(value: Binding(get: {
                                audioProcessor.compressor?.headRoom ?? 5
                            }, set: { newVal in
                                audioProcessor.compressor?.headRoom = newVal
                            }), in: 0.1...40)
                        }
                        .padding()
                        
                        HStack {
                            Text("Master Gain")
                            Slider(value: Binding(get: {
                                audioProcessor.compressor?.masterGain ?? 0
                            }, set: { newVal in
                                audioProcessor.compressor?.masterGain = newVal
                            }), in: -40...40)
                        }
                        .padding()
                        
                        // Read-only properties
                        Text("Read-Only Compressor Info")
                            .font(.headline)
                            .padding()
                        
                        Group {
                            Text("Compression Amount: \(audioProcessor.compressor?.compressionAmount ?? 0, specifier: "%.2f") dB")
                            Text("Input Amplitude: \(audioProcessor.compressor?.inputAmplitude ?? 0, specifier: "%.2f") dB")
                            Text("Output Amplitude: \(audioProcessor.compressor?.outputAmplitude ?? 0, specifier: "%.2f") dB")
                        }
                    }
                    .padding()
                    DisclosureGroup("Limiter Controls", isExpanded: $isLimiterExpanded) {
                        
                        HStack {
                            Text("Limiter Attack Time")
                            Slider(value: Binding(get: {
                                audioProcessor.limiter?.attackTime ?? 0.012
                            }, set: { newVal in
                                audioProcessor.limiter?.attackTime = newVal
                            }), in: 0.001...0.03)
                        }
                        .padding()
                        
                        HStack {
                            Text("Limiter Decay Time")
                            Slider(value: Binding(get: {
                                audioProcessor.limiter?.decayTime ?? 0.024
                            }, set: { newVal in
                                audioProcessor.limiter?.decayTime = newVal
                            }), in: 0.001...0.06)
                        }
                        .padding()
                        
                        HStack {
                            Text("Limiter Gain")
                            Slider(value: Binding(get: {
                                audioProcessor.limiter?.preGain ?? 0.0
                            }, set: { newVal in
                                audioProcessor.limiter?.preGain = newVal
                            }), in: 0...1)
                        }
                    }
                    .padding()
                    //                    DisclosureGroup("3D Sound Controls", isExpanded: $is3DSoundExpanded) {
                    //                         Toggle("Enable 3D Sound", isOn: $is3DSoundEnabled)
                    //
                    //                         if is3DSoundEnabled {
                    //                            // XY Pad?
                    //                         }
                    //                     }
                    //                     .padding()
                    
                    VStack {
                        Picker("X Axis", selection: $xParameter) {
                            ForEach(parameterOptions, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Picker("Y Axis", selection: $yParameter) {
                            ForEach(parameterOptions, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        XYPadView(position: $xyPadPosition)
                            .frame(width: 300, height: 300)
                            .padding()
                            .onChange(of: xyPadPosition) { newPosition in
                                updateAudioParameters(xParam: xParameter, yParam: yParameter, position: newPosition)
                            }
                    }
                }
            }
            
        }
        .onAppear {
            audioProcessor.importAudio(url: audioURL)
        }
    }
    
    func updateAudioParameters(xParam: String, yParam: String, position: CGPoint) {
        let xValue = Float(position.x)
        let yValue = Float(position.y)
        
        switch xParam {
        case "Pan":
            let panValue = (xValue * 2) - 1 // Convert from 0...1 to -1...1
            audioProcessor.pan = panValue
        case "Filter":
            // 10 to 200 (Default: 80)
            let filterValue = (xValue * 190) + 10
            audioProcessor.delay?.lowPassCutoff = filterValue
        case "Pitch":
            let pitchValue = (xValue * 4800) - 2400 // Convert from 0...1 to -2400...2400
            audioProcessor.timePitch?.pitch = pitchValue
        default:
            break
        }
        
        switch yParam {
        case "Pan":
            let panValue = (yValue * 2) - 1 // Convert from 0...1 to -1...1
            audioProcessor.pan = panValue
        case "Filter":
            // 10 to 200 (Default: 80)
            let filterValue = (yValue * 190) + 10
            audioProcessor.delay?.lowPassCutoff = filterValue
        case "Pitch":
            let pitchValue = (yValue * 4800) - 2400 // Convert from 0...1 to -2400...2400
            audioProcessor.timePitch?.pitch = pitchValue
        default:
            break
        }
    }
}

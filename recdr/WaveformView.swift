//
//  WaveformView.swift
//  recdr
//
//  Created by Patrick on 13.12.23.
//

import SwiftUI
import AVFoundation


struct WaveformView: View {
    var audioURL: URL
    @State private var waveformSamples: [Float] = []
    
    @Binding var cursorPosition: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                // Draw waveform here using context
                let widthPerSample = size.width / CGFloat(waveformSamples.count)
                
                for (index, sample) in waveformSamples.enumerated() {
                    let x = CGFloat(index) * widthPerSample
                    let amplitude = CGFloat(sample) // Normalize this value to your view's height
                    let rect = CGRect(x: x, y: (size.height - amplitude) / 2, width: widthPerSample, height: amplitude)
                    context.fill(Path(rect), with: .color(.gray))
                }
                
                // Draw cursor
                let cursorX = cursorPosition * size.width
                context.stroke(
                    Path(CGRect(x: cursorX, y: 0, width: 1, height: size.height)),
                    with: .color(.red)
                )
            }
        }
        .onAppear {
            if let samples = loadAudioSamples(from: audioURL) {
                self.waveformSamples = samples
            }        }
    }

    func processBuffer(_ buffer: AVAudioPCMBuffer) -> [Float] {
        guard let channelData = buffer.floatChannelData else {
            return []
        }
        // Assuming mono audio (single channel)
        let channelDataInFloats = UnsafeBufferPointer(start: channelData[0], count: Int(buffer.frameLength))
        
        // Downsample or average the data if necessary
        let downsampledData = downsample(channelDataInFloats, to: 1024) // Example downsampling to 1024 points
        
        return downsampledData
    }
    
    func downsample(_ data: UnsafeBufferPointer<Float>, to numberOfPoints: Int) -> [Float] {
        // Implement the logic to downsample the data        
        let length = data.count
        let binSize = length / numberOfPoints
        var downsampledData = [Float]()
        
        for i in stride(from: 0, to: length, by: binSize) {
            let binSamples = data[i..<min(i + binSize, length)]
            let averageAmplitude = binSamples.reduce(0, +) / Float(binSize)
            downsampledData.append(averageAmplitude)
        }
        
        return downsampledData
    }
    
    func loadAudioSamples(from url: URL) -> [Float]? {
        do {
            // Load the audio file
            let file = try AVAudioFile(forReading: url)

            // Safely unwrap the AVAudioFormat
            guard let format = AVAudioFormat(standardFormatWithSampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount) else {
                print("Error: Failed to create AVAudioFormat")
                return nil
            }
            // Create a PCM buffer
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length)) else {
                return nil
            }

            // Read the entire file into the buffer
            try file.read(into: buffer)

            // Process the buffer to get the samples
            return processBuffer(buffer)
        } catch {
            print("Error loading audio file: \(error)")
            return nil
        }
    }
    
}

struct WaveformView_Previews: PreviewProvider {
    static var previews: some View {
        WaveformView(
            audioURL: URL(fileURLWithPath: "/Users/patrick/Library/Developer/CoreSimulator/Devices/12C4F90B-DA5C-45A9-BE6C-258F14E31EB5/data/Containers/Data/Application/796816CE-0677-4A05-B677-13EA37AD7B6B/Documents/pitchPanXY20231213-155450.wav"),
            cursorPosition: .constant(0.5) // Dummy binding for preview
        )
    }
}



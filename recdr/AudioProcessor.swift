import AudioKit
import AVFoundation


class AudioProcessor: ObservableObject {
    let engine = AudioEngine()
    var player: AudioPlayer?
    var mixer: Mixer?
    var reverb: Reverb?
    var delay: Delay?
    var recorder: NodeRecorder?
    
    @Published var selectedReverbPreset: AVAudioUnitReverbPreset = .smallRoom {
        didSet {
            reverb?.loadFactoryPreset(selectedReverbPreset)
        }
    }
    
    init() {
        setupAudioChain()
        startEngine()
        setupRecorder()
    }

    private func setupAudioChain() {
        player = AudioPlayer()
        guard let player = player else {
            print("Player is not initialized")
            return
        }
        reverb = Reverb(player)
        guard let reverb = reverb else {
            print("Reverb is not initialized")
            return
        }
        delay = Delay(reverb)
        guard let delay = delay else {
            print("Delay is not initialized")
            return
        }

        // Ensure mixer is properly initialized
        mixer = Mixer(delay)

        // Connect the mixer to the engine's output
        if let mixer = mixer {
            engine.output = mixer
        } else {
            print("Failed to initialize Mixer")
        }
    }

    private func setupRecorder() {
        guard let mixer = mixer else {
            print("Mixer is not initialized")
            return
        }
        
        do {
            recorder = try NodeRecorder(node: mixer)
        } catch {
            print("Could not initialize recorder: \(error)")
        }
    }

    private func startEngine() {
        do {
            try engine.start()
        } catch {
            print("AudioKit did not start: \(error)")
        }
    }

    func importAudio(url: URL) {
        do {
//            let file = try AVAudioFile(forReading: url)
            try player?.load(url: url)
        } catch {
            print("Error reading audio file: \(error)")
        }
    }


    func play() {
        player?.play()
    }
    
    func startRecording() {
        print("Starting recording")
        do {
            try recorder?.record()
        } catch {
            print("Error starting recording: \(error)")
        }
    }

    func stopRecordingAndSave() {
        print("Stop recording")
        recorder?.stop()

        guard let recordedFileURL = recorder?.audioFile?.url else {
            print("Recorded file URL is nil")
            return
        }

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let exportURL = documentsPath.appendingPathComponent("ExportedFile.wav")

        do {
            // Read the recorded audio data
            let recordedFile = try AVAudioFile(forReading: recordedFileURL)

            // Define the WAV file format with high-quality settings
            guard let wavFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2) else {
                print("Failed to create WAV format")
                return
            }

            // Create a buffer to hold the audio data
            guard let buffer = AVAudioPCMBuffer(pcmFormat: recordedFile.processingFormat, frameCapacity: AVAudioFrameCount(recordedFile.length)) else {
                print("Failed to create audio buffer")
                return
            }

            // Read the audio data into the buffer
            try recordedFile.read(into: buffer)

            // Create a new file for writing in WAV format
            let outputFile = try AVAudioFile(forWriting: exportURL, settings: wavFormat.settings)

            // Write the buffer to the new file
            try outputFile.write(from: buffer)

            print("Exported to: \(exportURL)")
        } catch {
            print("Export failed: \(error)")
        }
    }

}



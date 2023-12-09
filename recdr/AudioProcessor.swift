import AudioKit
import AVFoundation

class AudioProcessor : ObservableObject {
    let engine = AudioEngine()
    var player: AudioKit.AudioPlayer?
    var mixer: Mixer?
    var reverb: AudioKit.Reverb?
    var delay: Delay?
    var recorder: AudioKit.NodeRecorder?
    var recordedFile: AVAudioFile?
    
    @Published var selectedReverbPreset: AVAudioUnitReverbPreset = .smallRoom {
        didSet {
            reverb?.loadFactoryPreset(selectedReverbPreset)
        }
    }
    
    init() {
        setupAudioChain()
        setupRecorder()
    }

    private func setupRecorder() {
        guard let mixer = mixer else {
            print("Mixer is not initialized")
            return
        }

        do {
            recorder = try AudioKit.NodeRecorder(node: mixer)
        } catch {
            print("Could not initialize recorder: \(error)")
        }
    }

    func importAudio(url: URL) {
        do {
            let file = try AVAudioFile(forReading: url)
            player = AudioKit.AudioPlayer(file: file)
            setupAudioChain()
        } catch {
            print("Error reading audio file: \(error)")
        }
    }

    private func setupAudioChain() {
        guard let player = player else { return }

        reverb = AudioKit.Reverb(player)
        if let reverbNode = reverb {
            delay = Delay(reverbNode)
        }
        
        // Configure effects
        reverb?.dryWetMix = 0.5
        delay?.time = 1.0
        
        if let delayNode = delay {
            mixer = Mixer(delayNode)
        }

        engine.output = mixer
        
        do {
            try engine.start()
        } catch {
            print("AudioKit did not start! \(error)")
        }
    }

    func play() {
        player?.play()
    }
    
    func startRecording() {
        do {
            try recorder?.record()
        } catch {
            print("Error starting recording: \(error)")
        }
    }
    
    

    func stopRecordingAndSave() {
        recorder?.stop()

        // Assuming recorder creates an AVAudioFile
        if let recordedFileURL = recorder?.audioFile?.url {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let exportURL = documentsPath.appendingPathComponent("ExportedFile.m4a")

            do {
                try FileManager.default.copyItem(at: recordedFileURL, to: exportURL)
                print("Exported to: \(exportURL)")
            } catch {
                print("Export failed: \(error)")
            }
        }
    }

//    func stopRecordingAndExport() {
//        recorder?.stop()
//
//        if let file = recorder?.audioFile {
//            do {
//                // Export the file
//                let exportURL = // Define the URL where you want to save the file
//                try file.exportAsynchronously(name: "ExportedFile.m4a",
//                                              baseDir: .documents,
//                                              exportFormat: .m4a) { exportedFile, error in
//                    guard error == nil else {
//                        print("Export failed: \(error!)")
//                        return
//                    }
//                    print("Exported to: \(exportedFile!)")
//                }
//            } catch {
//                print("Export failed: \(error)")
//            }
//        }
}



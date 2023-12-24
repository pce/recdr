import Foundation
import AVFoundation

class AudioRecorder: ObservableObject {
    var audioRecorder: AVAudioRecorder?
    @Published var isRecording = false
    @Published var recordingsList: [URL] = []

    var audioEngine: AVAudioEngine?
    var audioPlayerNode: AVAudioPlayerNode?
    

    func updateRecordingsList() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            recordingsList = urls.filter { $0.pathExtension == "wav" }
        } catch {
            print("Failed to fetch recordings: \(error)")
        }
    }

    func startMonitoring() {
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        guard let audioEngine = audioEngine, let audioPlayerNode = audioPlayerNode else { return }

        audioEngine.attach(audioPlayerNode)

        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)

        audioEngine.connect(inputNode, to: audioPlayerNode, format: inputFormat)
        audioEngine.connect(audioPlayerNode, to: audioEngine.outputNode, format: inputFormat)

        audioPlayerNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { buffer, _ in
            self.audioPlayerNode?.scheduleBuffer(buffer)
        }

        do {
            try audioEngine.start()
            audioPlayerNode.play()
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }
    
    init() {
        fetchRecordings()
    }
    
    func fetchRecordings() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            recordingsList = urls.filter { $0.pathExtension == "wav" }
        } catch {
            print("Error fetching recordings: \(error)")
        }
    }
    
    public func record() {
        // let audioFileName = "\(UUID().uuidString).wav"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd-HHmmss"
        let dateString = dateFormatter.string(from: Date())
        let audioFileName = "\(dateString).wav"

        let audioFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(audioFileName)

        // debug
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        print("Documents Directory: \(documentsDirectory)")
        
        let audioSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1, // TODO make configurable, default: mono
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilePath, settings: audioSettings)
            try audioRecorder?.record()
            isRecording = true
        } catch {
            print("Error setting up audio recorder: \(error)")
        }
    }
    
    public func stopRecording() {
        print("Stop audio recorder")
        audioRecorder?.stop()
        isRecording = false
        if let url = audioRecorder?.url {
            recordingsList.append(url)
        }
    }

}

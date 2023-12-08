//
//  AudioSession.swift
//  recdr
//
//  Created by Patrick on 07.12.23.
//

// import Foundation
import AVFoundation

class AudioSession {
    static let shared = AudioSession()
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        print("Set up audio session")
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }
    
    func requestRecordPermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            completion(granted)
        }
    }
}

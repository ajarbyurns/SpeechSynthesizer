//
//  Models.swift
//  SpeechSynthesis
//
//  Created by Barry Juans on 20/03/25.
//

import Foundation
import AVFoundation
import Speech

struct Language {
    var id: String
    var code: String
}

class SpeechRecognizer: ObservableObject {
    
    @Published var recognizedText: String = ""
    @Published var startedListening: Bool = false {
        didSet {
            if startedListening {
                startListening()
            } else {
                stopListening()
            }
        }
    }
    var audioEngine: AVAudioEngine?
    var speechRecognizer: SFSpeechRecognizer?
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    
    init() {
        setupSpeechRecognition()
    }
        
    func setupSpeechRecognition() {
        audioEngine = AVAudioEngine()
        speechRecognizer = SFSpeechRecognizer()
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async { [weak self] in
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied, .restricted, .notDetermined:
                    self?.recognizedText = "Speech recognition not authorized"
                @unknown default:
                    self?.recognizedText = "Unknown authorization status"
                }
            }
        }
    }
    
    func startListening() {
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true
        
        guard let audioEngine, let recognitionRequest else {
            return
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        
        speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result {
                Task {
                    self.recognizedText = result.bestTranscription.formattedString
                }
            }
        }
    }
    
    func stopListening() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
    }
}

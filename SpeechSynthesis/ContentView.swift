//
//  ContentView.swift
//  SpeechSynthesis
//
//  Created by Barry Juans on 20/03/25.
//

import SwiftUI
import AVFoundation
import Speech

struct ContentView: View {
    var body: some View {
            TabView {
                FirstTab()
                    .tabItem {
                        Label("Text to Speech", systemImage: "text.bubble")
                    }
                SecondTab()
                    .tabItem {
                        Label("Speech to Text", systemImage: "music.note")
                    }
            }
            .onAppear() {
                UITabBar.appearance().backgroundColor = .lightGray
            }
        }
}

struct FirstTab: View {
    
    @State private var text: String = ""
    @State private var language: Language = Language(id: "English", code: "en-US")
    @FocusState private var isFocused: Bool
    let synthesizer = AVSpeechSynthesizer()
    let languages: [Language] = [
        Language(id: "English", code: "en-US"),
        Language(id: "Indonesian", code: "id")
    ]
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Menu {
                    ForEach(languages, id: \.id) { option in
                        Button(option.id, action: { language = option })
                    }
                } label: {
                    Text(language.id)
                        .foregroundStyle(Color.blue)
                }
                Spacer()
                Text("Enter Your Message")
                Spacer()
                Button {
                    text = ""
                } label: {
                    Text("Clear")
                        .foregroundStyle(Color.blue)
                }
            }
            .padding(.horizontal)
            TextEditor(text: $text)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.black, lineWidth: 2)
                }
                .padding()
                .focused($isFocused)
            Spacer()
            Button(action: {
                let utterance = AVSpeechUtterance(string: text)
                utterance.voice = AVSpeechSynthesisVoice(language: language.code)
                synthesizer.speak(utterance)
            }) {
                Image(systemName: "play.circle")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(.blue)
                    .padding(EdgeInsets(top: 5, leading: 0, bottom: 10, trailing: 0))
            }
        }
        .background(Color.white)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        isFocused = false
                    }
                }
            }
        }
    }
}

struct SecondTab: View {
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    struct AnimatingButton: View {
        @Binding var isRecording: Bool
        @State var isAnimating: Bool = false
        
        var foreverAnimation: Animation {
            Animation.linear(duration: 2.0)
                .repeatForever(autoreverses: false)
        }
        
        var body: some View {
            Button(action: {
                isRecording.toggle()
            }) {
                if isRecording {
                    Image(systemName: "stop.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(.red)
                        .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0.0))
                        .animation(self.isAnimating ? foreverAnimation : .default, value: isAnimating)
                        .onAppear { self.isAnimating = true }
                        .onDisappear { self.isAnimating = false }
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 10, trailing: 0))
                } else {
                    Image(systemName: "record.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(.red)
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 10, trailing: 0))
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Press the button to Start Recording")
                Spacer()
                Button {
                    speechRecognizer.recognizedText = ""
                } label: {
                    Text("Clear")
                        .foregroundStyle(Color.blue)
                }
            }
            .padding(.horizontal)
            TextEditor(text: $speechRecognizer.recognizedText)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.black, lineWidth: 2)
                }
                .padding()
                .disabled(true)
            Spacer()
            AnimatingButton(isRecording: $speechRecognizer.startedListening)
        }
        .background(Color.white)
    }
}


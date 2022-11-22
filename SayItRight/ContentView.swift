//
//  ContentView.swift
//  SayItRight
//
//  Created by Boaz Saragossi on 22/03/2022.
//

import SwiftUI
import AVFoundation

struct ContentView: View {

    var wordBank: [String] = []
    static let speeakTime = 4.0
    
    @State var wordToSay = ""
    @State var soundOn = true
    @State var score = 0
    @State var whatYouSaid = " "
    @State var resultColor: Color = .black
    @State var whenToSpeakColor: Color = .gray
    @State var whenToSpeakSize: CGFloat = 15
    @State var speakTimer = Timer.publish(every: 3, tolerance: speeakTime, on: .main, in: .common).autoconnect()
    @State var wrongAttemptsCounter: Int
    @ObservedObject var speaker = Speaker()
    
    
    init(words: [String]) {
        wordBank = words
        wordToSay = wordBank.randomElement() ?? ""
        wrongAttemptsCounter = 3
        //sayWord()
    }
    
    
    func nextRound(isNewWord: Bool) {

        resultColor = .black
        whatYouSaid = " "
        
        if (isNewWord) {
            wordToSay = wordBank.randomElement() ?? ""
            if (soundOn) {
                score = score + 1
            } else {
                score = score + 2
            }
        } else {
            wrongAttemptsCounter = wrongAttemptsCounter - 1
            if (wrongAttemptsCounter == 0) {
                wrongAttemptsCounter = 3
                score = 0
                wordToSay = wordBank.randomElement() ?? ""
            }
        }

        sayWord()
    }
    
    func sayWord() {
        speaker.speak(wordToSay,soundOn)
        speakTimer = Timer.publish(every: 3, tolerance: ContentView.speeakTime, on: .main, in: .common).autoconnect()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            whenToSpeakColor = .black
            whenToSpeakSize = 20
        }
    }
    
    func isCorrectAnswer() -> Bool {
        whatYouSaid = speaker.stopListening()
        return whatYouSaid == wordToSay
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    soundOn.toggle()
                }) {
                    Image(soundOn ? "Sound" : "NoSound")
                        .resizable()
                        .frame(width: 50.0, height: 50.0)
                        .padding(.leading, 20)
                        .padding(.top, 20)
                }
                Spacer()
            }
            Spacer()
            VStack {
                Image(wordToSay)
//                    .padding()
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10 * whenToSpeakSize, height: 10 * whenToSpeakSize)
                Text(wordToSay)
                    .foregroundColor(whenToSpeakColor)
                    .font(.system(size: whenToSpeakSize)).bold()
                Text(whatYouSaid).foregroundColor(resultColor)
            }.onReceive(speakTimer) { input in
                whenToSpeakColor = .gray
                whenToSpeakSize = 15
                speakTimer.upstream.connect().cancel()
                let success = isCorrectAnswer()
                resultColor = success ? .green : .red
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    nextRound(isNewWord: success)
                }
            }
            Text("\(score)")
                .foregroundColor(resultColor)
                .font(.system(size: 50)).bold()
    //            .padding(.trailing, 20)
    //            .padding(.top, 20)
            Spacer()
        }.background(.white)
          .onAppear {sayWord()}
          .onDisappear{speakTimer.upstream.connect().cancel()}
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

class Speaker: NSObject, ObservableObject {
    private var synth = AVSpeechSynthesizer()
    var speechRecognizer = SpeechRecognizer()
    @Published var status = ""

    override init() {
        super.init()
        self.synth.delegate = self
//        synth.usesApplicationAudioSession = false

    }
    
//    func onSpeakingStatusChanged (callback: @escaping (String) -> Void) {
//        onSpeakingStatusChangedCallback = callback
//    }

    func speak(_ string: String, _ soundOn: Bool) {
        if (soundOn) {
            
            let utterance = AVSpeechUtterance(string: string)
            utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Tessa-compact")
            status = "speaking"
            synth.speak(utterance)

        } else {
            self.startListening()
        }
    }
    
    func startListening() {
//        speechRecognizer.reset()
        speechRecognizer.transcribe()
    }
    
    func stopListening() -> String {
        speechRecognizer.stopTranscribing()
        let word = speechRecognizer.transcript
        return word
    }
}

extension Speaker: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        status = "listening"
        self.startListening()
    }
}

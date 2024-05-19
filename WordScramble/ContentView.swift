//
//  ContentView.swift
//  WordScramble
//
//  Created by Om Preetham Bandi on 5/19/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = "Word Scramble"
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter a new word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)

                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit() {
                addNewWord()
            }
            .onAppear(perform: {
                startGame()
            })
            .alert(errorTitle, isPresented: $showingError) { } message: {
                Text(errorMessage)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New Game", action: startGame)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Text("Score: \(score)")
                }
            }
        }
    }
    
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                
                score = 0
                usedWords.removeAll()
                
                return
            }
        }
        fatalError("Could not found start.txt from the bundle")
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !answer.isEmpty else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isShorter(word: answer) else {
            wordError(title: "Too short", message: "Type a word more than 3 letters")
            return
        }
        
        guard isRootWord(word: answer) else {
            wordError(title: "Word is same as rootword", message: "You typed the exact \(rootWord) word")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        calculateScore(for: answer)
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
        
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isRootWord(word: String) -> Bool {
        !(word == rootWord)
    }
    
    func isShorter(word: String) -> Bool {
        !(word.count < 4)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func calculateScore(for word: String) {
        score += word.count
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

#Preview {
    ContentView()
}

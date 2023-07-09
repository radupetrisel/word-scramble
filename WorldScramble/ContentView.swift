//
//  ContentView.swift
//  WorldScramble
//
//  Created by Radu Petrisel on 09.07.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var currentWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $currentWord)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
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
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("Ok") { }
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Restart", action: startGame)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Score: \(score)")
                }
            }
        }
    }
    
    private func addNewWord() {
        let newWord = currentWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard isWordLongerThan3(word: newWord) else {
            showError(title: "Word is too short", message: "Please use words at least 3 letters long!")
            score -= newWord.count
            return
        }
        
        guard isNotRootWord(word: newWord) else {
            showError(title: "That's the original word", message: "Please use a different word!")
            score -= newWord.count
            return
        }
        
        guard isOriginal(word: newWord) else {
            showError(title: "You've already used that", message: "Please use a new word!")
            score -= newWord.count
            return
        }
        
        guard isPossible(word: newWord) else {
            showError(title: "That's not possible", message: "You need to use letters only from '\(rootWord)'!")
            score -= newWord.count
            return
        }
        
        guard isReal(word: newWord) else {
            showError(title: "That word is made up", message: "You must use real words from the English language!")
            score -= newWord.count
            return
        }
        
        withAnimation {
            usedWords.insert(newWord, at: 0)
            score += newWord.count
        }
        
        currentWord = ""
    }
    
    private func startGame() {
        if let startUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startUrl) {
                let words = startWords.components(separatedBy: "\n")
                rootWord = words.randomElement() ?? "silkworm"
                usedWords = []
                currentWord = ""
                score = 0
                return
            }
        }
        
        fatalError("Could not load start.txt from Bundle.")
    }
    
    private func isWordLongerThan3(word: String) -> Bool { word.count >= 3 }
    
    private func isNotRootWord(word: String) -> Bool { word != rootWord }
    
    private func isOriginal(word: String) -> Bool { !usedWords.contains(word) }
    
    private func isPossible(word: String) -> Bool {
        var temp = rootWord
        
        for letter in word {
            if let index = temp.firstIndex(of: letter) {
                temp.remove(at: index)
            } else {
                return false
            }
        }
        
        return true
    }
    
    private func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        
        let misspells = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspells.location == NSNotFound
    }
    
    private func showError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

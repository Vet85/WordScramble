//
//  ContentView.swift
//  WordScramble
//
//  Created by Vitaliy Novichenko on 11.09.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var newWord = ""
    @State private var rootWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var lettersCount = [Int]()
    @State private var sum = 0
    
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        TextField("Enter your word", text: $newWord)
                            .autocapitalization(.none)
                    }
                    VStack(alignment: .center) {
                        Text("Score")
                        HStack {
                            Text("Word count: \(usedWords.count)").font(.subheadline)
                            Spacer()
                            Text("Letters count: \(sum)").font(.subheadline)
                        }.padding()
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    . background(Color.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Section {
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }
                    }
                }
                .navigationTitle(rootWord).font(.title)
                .onSubmit(addNewWord)
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError) {
                    Button("OK", role: .cancel) {    }
                } message: {
                    Text(errorMessage)
                }
                .toolbar {
                    Button("New Word", action: startGame)
                }
                Text("Thank you for your interest")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .background(Color.gray)
                    
            }
            }
        
        }
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 2 && answer != rootWord else {
            wordError(title: "Не верно", message: "Слово должно быть не меньше 3х букв и не должно быть начальным словом")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Слово уже использовалось", message: "Будь более оригинальным")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Не возможное слово", message: "Ты не можешь составить такое слово из \(rootWord)")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Нет такого слова в Английском языке", message: "Подумай получше!!!")
            return
        }
        lettersCount.append(answer.count)
        sum += answer.count
        // Extra validation to come
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    func startGame() {
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "Hello, world"
                return
            }
        }
        fatalError("Could not load start.txt from bundle")
    }
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
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
        let misspeledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspeledRange.location == NSNotFound
    }
    func wordError(title: String, message: String) {
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

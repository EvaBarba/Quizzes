//
//  ScoresModel.swift
//  Quiz
//
//  ScoresModel.swift

import Foundation

class ScoresModel: ObservableObject {
    
    //Conjuntos de enteros, privada para que no se modifique desde fuera
    @Published private(set) var acertadas : Set<Int> = []
    @Published private(set) var record : Set<Int> = []

    //Para sacarlo de las preferencias de usuario
    init() {
        record = Set(UserDefaults.standard.array(forKey: "record") as? [Int] ?? [])
    }
    
    func add(answer: String, quizItem: QuizItem) {
        
        if answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == quizItem.answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
            acertadas.insert(quizItem.id)
            record.insert(quizItem.id)
            
            //Guarda valor en pref. de usuario
            UserDefaults.standard.set(Array(record), forKey: "record")
        }
        
    }
}

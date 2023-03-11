//
//  QuizItem.swift
//  Quiz con SwiftUI
//
//  Created by Santiago Pavón Gómez on 18/10/22.
//

//  QuizItem.swift

import Foundation

struct QuizItem: Codable, Identifiable {
    let id: Int
    let question: String
    let answer: String
    let author: Author?             //? --> puede tener autor o no
    let attachment: Attachment?     //La foto
    var favourite: Bool             //var pq se modifica el valor
    
    struct Author: Codable {
        let isAdmin: Bool?
        let username: String?
        let accountTypeId: Int?
        let profileId: Decimal?
        let profileName: String?
        let photo: Attachment?
    }
    
    struct Attachment: Codable {
        let filename: String?
        let mime: String?
        let url: URL?
    }
}

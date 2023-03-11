//
//  QuizRow.swift
//  Quiz
//


import SwiftUI

struct QuizRow: View {
    
    var quizItem : QuizItem
    
    var body: some View {
        
        HStack{
            MyAsyncImage(url:  quizItem.attachment?.url)
                .scaledToFill()
                .frame(width: 80, height: 80)       //Tamaño
                .clipShape(Circle())                //Forma
                .overlay(Circle().stroke(Color.black, lineWidth: 3)) //Borde
                .shadow(radius: 13)                 //Sombra
            
            MyAsyncImage(url:  quizItem.author?.photo?.url)
                .scaledToFill()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 1))
                .shadow(radius: 13)
            
            
            VStack {
                
                Text(quizItem.question)
                    .fontWeight(.heavy)
                Text(quizItem.author?.username ?? "Anónimo")
                    .font(.callout)
            }
            
            Image(quizItem.favourite ? "estrella_amarilla" : "estrella_gris")
                .resizable()
                .frame(width: 25, height: 25)
            
        }
    }
}

struct QuizRow_Previews: PreviewProvider {
    
    static var qm: QuizzesModel = {
        var qm = QuizzesModel()
        qm.load()
        return qm
    }()
    
    static var previews: some View {
        VStack{
            QuizRow(quizItem: qm.quizzes[0])
            QuizRow(quizItem: qm.quizzes[1])
        }
    }
}

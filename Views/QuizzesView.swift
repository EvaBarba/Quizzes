//  ContentView.swift
//  Quiz

import SwiftUI

struct QuizzesView: View {
    
    @EnvironmentObject var quizzesModel: QuizzesModel
    @EnvironmentObject var scoreModel: ScoresModel
    
    @State var showAll = true
    
    var body: some View {
        
        NavigationStack {
            List {
                Toggle("Ver Todos", isOn: $showAll)   //MEJORA 4.2-3: Filtrar acertadas
                ForEach(quizzesModel.quizzes) { quizItem  in
                    if showAll || !scoreModel.acertadas.contains(quizItem.id){
                        NavigationLink {    //La pantalla o vista que muestra
                            QuizPlayView(quizItem: quizItem)
                        } label: {  //Etiqueta (donde hace click), cada elemento
                            QuizRow(quizItem: quizItem)
                        }
                    }
                }
            }

            .listStyle(.plain)              //Para que no salga un borde en la lista
            .navigationTitle("P4 Quizzes")  //Titulo pantalla

            //MEJORA 4.2-4: Record persistente
            .navigationBarItems(leading: Text("Record = \(scoreModel.record.count)"),
                                trailing:
                                    Button(action: {quizzesModel.download2()},
                                           label: { Label("Descargar",
                                                          systemImage: "square.and.arrow.down")})
            )

            //PRACTICA 4.1 (load)
            //.onAppear { quizzesModel.load() }

            //PRACTICA 4.2 (download)

                //Para el download 1 y 2 ==>
                //.onAppear {
                //    if quizzesModel.quizzes.count == 0 {
                //        quizzesModel.download2()
                //    }
            
                //Para el download3 ==>
            .task {
                if quizzesModel.quizzes.count == 0 {
                    await quizzesModel.download3()
                    
                }
                
            }
        }
    }
}


//PREVISUALIZACIÓN
struct ContentView_Previews: PreviewProvider {
    
    static var qm: QuizzesModel = {
        var qm = QuizzesModel()
        qm.load()
        return qm
    }()
    
    static var previews: some View {
        QuizzesView()
            .environmentObject(qm)
    }
}

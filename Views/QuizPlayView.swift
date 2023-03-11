//  QuizPlayView.swift
//  Quiz


import SwiftUI

struct QuizPlayView: View {
    
    var quizItem : QuizItem
    
    //Para si el dispositivo está en vertical u horizontal
    @Environment(\.horizontalSizeClass) var hsc
    
    @State var answer: String = ""
    @EnvironmentObject var scoresModel: ScoresModel
    @EnvironmentObject var quizzesModel: QuizzesModel

    //Alerta para answer bien o mal
    @State var showAlert = false


    var body: some View {
        VStack {
            if hsc ==  .compact {   //Si es horizontal
                
                VStack {
                    titulo
                    respuesta
                    attachment
                    footer
                }
                
            } else {                //Si es vertical
                
                HStack {
                    titulo
                }
                
                HStack {
                    HStack{
                        VStack {
                            respuesta
                            footer
                        }
                        attachment
                    }
                }
            }
        }
        .navigationTitle("Jugando")
    }
    

    // PARA LA MEJORA 4.2 (Girar y escalar imagen)
    @State var angulo = 0.0
    @State var escala = 1.0
    

    // TITULO -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    private var titulo: some View {
        HStack {
            Text(quizItem.question)
                .fontWeight(.heavy)
                .font(.largeTitle)
            
        }
    }
    
    // RESPUESTA -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    private var respuesta: some View {
        VStack {
            TextField("Meta  su respuesta:", text: $answer)
                .onSubmit { //Para que funcione al darle al Enter a parte de al botón
                    if answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == quizItem.answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
                        scoresModel.add(answer: answer, quizItem: quizItem)
                    }
                    showAlert = true
                }
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)   //Margen solo en horizontal
            
            Button("Comprobar") {
                if answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == quizItem.answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
                    scoresModel.add(answer: answer, quizItem: quizItem)
                }
                showAlert = true
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Resultado"),
                  message: Text(answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == quizItem.answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ? "Bien" : "Mal"),
                  dismissButton: .default(Text("ok")))
        }
    }
    
    //LA IMAGEN - La descarga de forma asíncrona de la URL -------------------------------------------------------------------------------------------------------------------------------------------------------
    private var attachment: some View {
        GeometryReader {geom in
            MyAsyncImage(url:  quizItem.attachment?.url)
                .scaledToFill()
                .frame(width: geom.size.width, height: geom.size.height)    //Tamaño
                .clipShape(RoundedRectangle(cornerRadius: 20))              //Forma
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black, lineWidth: 3))
                .shadow(radius: 15)                                         //sombra
                
                //MEJORA 4.2-2: Gestos y animación
                .rotationEffect(Angle(degrees: angulo))
                .scaleEffect(escala)

                .onTapGesture {
                    answer = quizItem.answer
                    withAnimation(.spring(response: 1,  dampingFraction: 0.3, blendDuration: 0.75))
                    {
                        angulo += 360
                        escala = 0
                    }
                    
                    withAnimation(.easeInOut(duration: 0.75).delay(0.75)){
                        angulo += -360
                        escala = 1
                    }
                }
        }
        .padding()  //Margen
    }
    
    //PIE DE PAGINA: Score + nombreAutor + fotoAutor + EstrellaFav -----------------------------------------------------------------------------------------------------------------------------------------------
    private var footer: some View {
        HStack{
            
            Text("Puntos = \(scoresModel.acertadas.count)")
                .foregroundColor(.green)
            
            Text(quizItem.author?.username ?? "Anónimo")
                .font(.callout)
            
            MyAsyncImage(url:  quizItem.author?.photo?.url)
                .scaledToFill()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black, lineWidth: 1))
                .shadow(radius: 13)

                //MEJORA 4.2-1: Menú contextual
                .contextMenu{
                    Button("Limpiar"){
                        answer = ""
                    }
                    Button("Rellenar") {
                        answer = quizItem.answer
                    }
                }
            
            
            //MEJORA 4.2-3: Filtro acertados (En quizzesModel endpoint+func)
            Button {
                quizzesModel.toggleFav(quizItemId: quizItem.id)
            } label: {
                Image(quizItem.favourite ? "estrella_amarilla" : "estrella_gris")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            
        }        
    }
    
    
    struct QuizPlayView_Previews: PreviewProvider {
        
        static var qm: QuizzesModel = {
            var qm = QuizzesModel()
            qm.load()
            return qm
        }()
        
        static var previews: some View {
            QuizPlayView(quizItem: qm.quizzes[0])
        }
    }
}

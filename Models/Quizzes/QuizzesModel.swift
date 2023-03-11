//  QuizzesModel.swift
//  Quiz con SwiftUI

//  QuizzesModel.swift

import Foundation

class QuizzesModel: ObservableObject {
    
    private let urlbase = "https://core.dit.upm.es"             //URL base
    private let quizzesPath = "api/quizzes/random10wa?token"    //Ruta para obtener 10 quizzes random
    private let token = "bbc5b7a83383b99e7afb"                  //Nuestro token
    
    private let favPath = "api/users/tokenOwner/favourites"
    
    // Los datos:
    //Array de quizzes, [QuizItem] es el tipo y () es que está vacío.
    @Published private(set) var quizzes = [QuizItem]()
    
    @Published var errorMsg: String?
    
    
    
    //PRACTICA 4.1: Método load para cargar los datos de un fichero json que le doy
    func load() {
        
        guard let jsonURL = Bundle.main.url(forResource: "quizzes", withExtension: "json") else {
            print("Internal error: No encuentro p1_quizzes.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: jsonURL)    //Buffer Bytes
            let decoder = JSONDecoder()                 //Decodifica JSON
            
                // DEPURACIÓN
                // if let str = String(data: data, encoding: String.Encoding.utf8) {
                //    print("Quizzes ==>", str)
                // }
            
            let quizzes = try decoder.decode([QuizItem].self, from: data)
            
            print("Quizzes cargados")
            
        } catch {
            print("Algo chungo ha pasado: \(error)")
        }
    }
    
    
    //PRACTICA 4.2
    
    //ENDPOINTS (devuelve url) --------------------------------------------------
    func endpoint() -> URL? {
        let surl = "\(urlbase)/\(quizzesPath)=\(token)"
        
        guard let url = URL(string: surl) else {
            print("Internal error 1")
            return nil
        }
        return url
    }
    
    func endpointFav(quizId: Int) -> URL? {
        let surl = "\(urlbase)/\(favPath)/\(quizId)?token=\(token)"
        guard let url = URL(string: surl ) else {
            print("Internal error 1")
            return nil
        }
        print(url)
        return url
    }
    
    
    //DOWNLOADS-------------------------------------------------------------
    func download1() {
        
        guard let url = endpoint() else { return }
        
        //Cola para enviar de forma asincrona (para que no bloquee)
        DispatchQueue.global().async {
            
            do {
                
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                
                let quizzes = try decoder.decode([QuizItem].self, from: data)
                
                self.quizzes = quizzes
                
                //Protegemos lo que tiene que ver con el usuario
                DispatchQueue.main.async {
                    self.quizzes = quizzes
                    print("Quizzes cargados")
                }

                
            } catch {
                print("Algo chungo ha pasado: \(error)")
            }
        }

    }
    
    // DOWN2----------------------------
    func download2() {
        
        guard let url = endpoint() else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data else {
                print("Fallo la descarga")
                return
            }
            
            
            if let quizzes = try? JSONDecoder().decode([QuizItem].self, from: data) {
                
                DispatchQueue.main.async {
                    self.quizzes = quizzes
                    print("Quizzes cargados")
                }
            
            } else {
                print("Fallo datos json corrupto")
            }
        }
        .resume()
    }
    
    // DOWN3 (con fun asincrona)----------------
    func download3() async {
        
        guard let url = endpoint() else { return }
        
        if let (data, _ ) = try? await URLSession.shared.data(from: url),
           let quizzes = try? JSONDecoder().decode([QuizItem].self, from: data) {
            DispatchQueue.main.async {
                self.quizzes = quizzes
                print("Quizzes cargados")
            }
            
        } else {
            print("Fallo terrible")
            self.errorMsg = "Fallo terrible"
        }
    }
    
    
    
    // MARCAR FAVORITOS ---------------------------------------------------------------------
    func toggleFav(quizItemId: Int) {
        
        guard let index = (quizzes.firstIndex {qi in qi.id == quizItemId}) else {
            print("No encontrado")
            return
        }
        
        guard let url = endpointFav(quizId: quizItemId) else { return }
        
        var req = URLRequest(url: url)  //Peticion de url
        req.httpMethod = quizzes[index].favourite ? "DELETE" : "PUT"
        
        
        URLSession.shared.uploadTask(with: req, from: Data()) { _, response, error in
            
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                print("Fallo FAV 1")
                return
            }
            DispatchQueue.main.async {
                self.quizzes[index].favourite.toggle()  //cambia el boolean al contrario
            }
        }
        .resume()
    }
}

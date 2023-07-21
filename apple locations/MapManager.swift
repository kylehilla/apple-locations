//
//  MapManager.swift
//  apple locations
//
//  Created by Kyle Hilla on 12/30/22.
//

import Foundation

class MapManager {
    
    var locationArray = [LocationData]()
    static let shared = MapManager()
   
    // Sample code for local json file parsing
//    func readLocalFile(name: String) -> Data? {
//        do {
//            if let bundlePath = Bundle.main.path(forResource: "location", ofType: "json"),
//                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
//
//                return jsonData
//            }
//
//        } catch {
//            print(error)
//        }
//
//        return nil
//    }
    
    func loadJson(fromURLString urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        if let url = URL(string: urlString) {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                
                if let error = error {
                    completion(.failure(error))
                }
                
                if let data = data {
                    completion(.success(data))
                }
            }
            
            urlSession.resume()
        }
    }

    func parse(jsonData: Data) {
        do {
            let decodedData = try JSONDecoder().decode([LocationData].self, from: jsonData)
            
            locationArray = decodedData
            
        } catch {
            print(error)
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}

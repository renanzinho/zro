//
//  APIFacade.swift
//  zro
//
//  Created by rfl3 on 29/09/20.
//  Copyright © 2020 renacio. All rights reserved.
//

import Foundation
import Alamofire

class APIFacade {

    public static var shared = APIFacade()

    let main = "https://mesa-news-api.herokuapp.com"
    var token: String?

    func signin(email: String, password: String, completion: @escaping (Alamofire.DataResponse<Any, Alamofire.AFError>) -> Void) {

        let parameters: [String: Any] = ["email": email,
                                         "password": password]

        let headers: HTTPHeaders = ["Content-Type": "application/json"]

        AF.request("\(self.main)/v1/client/auth/signin",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers).responseJSON { response in
                completion(response)
        }

    }

    func signup(email: String, password: String, name: String, birthdate: String? = "", completion: @escaping (Alamofire.DataResponse<Any, Alamofire.AFError>) -> Void) {

        var parameters: [String: Any] = ["email": email,
                                         "password": password,
                                         "name": name]

        if birthdate != "" {
            parameters["birthdate"] = birthdate
        }

        let headers: HTTPHeaders = ["Content-Type": "application/json"]

        AF.request("\(self.main)/v1/client/auth/signup",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers).responseJSON { response in
                completion(response)
        }

    }

    func requestImage(_ url: String, completion: @escaping (Alamofire.DataResponse<Data, Alamofire.AFError>) -> Void) {

        AF.request(url,
                   method: .get).responseData { response in
                    completion(response)
        }

    }

    func requestNews(_ page: Int = 1, date: String = "", completion: @escaping(Alamofire.DataResponse<Data, Alamofire.AFError>) -> Void) {

        var parameters: [String: Any] = ["token": self.token!,
                                         "current_page": page]

        if date != "" {
            parameters["published_at"] =  date
        }

        let headers: HTTPHeaders = ["Content-Type": "application/json",
                                    "Authorization": "Bearer \(self.token!)"]

        AF.request("\(self.main)/v1/client/news",
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers).responseData { response in
                completion(response)
        }

    }

}

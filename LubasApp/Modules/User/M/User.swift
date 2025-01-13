//
//  User.swift
//  LubasApp
//
//  Created by Pidong Ling on 2024/10/22.
//

struct User: Codable{
    
    let id: Int
    let name: String
    let email: String
    
    func fetchUserInfo(dataReback: @escaping (Any?)->()){
        let params = ["":""]
        APIService.getUsers(params: params) { result in
            
            switch result {
            case .success(let userResp):
                
                dataReback(userResp)
                
                debugPrint("x")
            case .failure(let error):
                debugPrint("x")
                
                dataReback(nil)

            }
        }
    }
    
}

//
//  StytchServerFlowManager.swift
//  StytchSDK
//
//  Created by Edgar Kroman on 2020-11-25.
//

import Foundation

class StytchMagicLinkServerFlowManager {
    
    var userResponse: UserModel?
    
    var email: String = ""
    
    func sendMagicLink(to email: String,
                       createUserAsPending: Bool,
                       publicToken: String,
                       handler: @escaping (StytchError?)->() ) {
        sendLoginOrSignUp(email: email,
                          createUserAsPending: createUserAsPending,
                          publicToken: publicToken,
                          handler: handler)
    }
    
    private func loginHandler(response: (BaseResponseModel<UserModel>), handler: @escaping (StytchError?)->() ) {
        
        if let model = response.data {
            self.userResponse = model
            
            handler(nil)
        } else {
            
            handler(self.convertError(type: response.error.errorType))
        }
        
    }
    
    private func sendLoginOrSignUp(email: String,
                                   createUserAsPending: Bool,
                                   publicToken: String,
                                   handler: @escaping (StytchError?)->() ) {
        
        let linkModel = PostLoginSignModel(email: email,
                                           createUserAsPending: createUserAsPending, publicToken: publicToken)
        
        StytchMagicLinkApi.shared.loginOrSignUp(model: linkModel) { (response) in
            self.email = email
            self.loginHandler(response: response, handler: handler)
        }
    }
    
    func authenticateMagicLink(with token: String, handler: @escaping (MagicLinkModel?, StytchError?)->()) {
        
        StytchMagicLinkApi.shared.authenticateMagicLink(token: token) { (response) in
            if let model = response.data {
                handler(model, nil)
            } else {
                handler(nil, self.convertError(type: response.error.errorType))
            }
        }
    }
    
    private func convertError(type: ErrorType) -> StytchError {
        switch type {
        case .unknown:
            return StytchError.connection
        case .emailNotFound:
            return StytchError.unknown // Should be handled when sending magic link
        case .duplicateEmail:
            return StytchError.unknown // Should be handled when creating user
        case .unableToAuthMagicLink:
            return StytchError.invalidMagicToken
        case .unauthorizedCredentials:
            return StytchError.invalidConfiguration
        case .internalServerError:
            return StytchError.unknown
        }
    }
}


import Foundation

class StytchMagicLinkApi {
        
        static private(set) var shared: StytchMagicLinkApi = StytchMagicLinkApi()
        
        static func initialize(projectID: String) {
            let api = StytchMagicLinkApi()
            api.projectID = projectID
            StytchMagicLinkApi.shared = api
        }
        
        private var host: String {
            switch Stytch.shared.magicLink.environment {
            case .test:
                return "https://test.stytch.com\(StytchConstants.SERVER_VERSION)"
            case .live:
                return "https://api.stytch.com\(StytchConstants.SERVER_VERSION)"
            }
            
        }
        
        private let authKey = "Authorization"
        private var projectID = ""
        
        private init() {}
        
        func createUser(model: PostCreateUserModel, handler: @escaping (BaseResponseModel<UserModel>) -> ()) {
            let request = BaseRequest<PostCreateUserModel, UserModel>
                .init(URL(string: host + "/users")!, method: .POST, object: model)
            
            request.send(handler: handler)
        }
        
        func sendMagicLink(model: PostMagicLinkModel, handler: @escaping (BaseResponseModel<MagicLinkModel>) -> ()) {
            let request = BaseRequest<PostMagicLinkModel, MagicLinkModel>
                .init(URL(string: host + "/magic_links/send_by_email")!, method: .POST, object: model)
            
            request.send(handler: handler)
        }
        
        func loginOrSignUp(model: PostLoginSignModel, handler: @escaping (BaseResponseModel<UserModel>) -> ()) {
            
            let request = BaseRequest<PostLoginSignModel, UserModel>
                .init(URL(string: host + "/sdk/magic_links/email/login_or_create")!, method: .POST, object: model)
            
            request.send(handler: handler)
        }
        
        func authenticateMagicLink(token: String, handler: @escaping (BaseResponseModel<MagicLinkModel>) -> ()) {
            let request = BaseRequest<EmptyModel, MagicLinkModel>
                .init(URL(string: host + "/magic_links/\(token)/authenticate")!, method: .POST, object: EmptyModel())
            
            request.send(handler: handler)
        }
    }

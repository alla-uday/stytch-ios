//
//  PostLoginInviteModel.swift
//  Stytch
//
//  Created by Edgar Kroman on 2020-12-07.
//

import Foundation

class PostLoginInviteModel: Codable {
    var email: String?
    var login_magic_link_url: String = StytchMagicLink.shared.loginMagicLink
    var invite_magic_link_url: String = StytchMagicLink.shared.inviteMagicLink
    var login_expiration_minutes: Int = 60
    var invite_expiration_minutes: Int = 60 * 24 * 7
//    var attrubutes = AttributesModel()
    
    init(email: String) {
        self.email = email
    }
}
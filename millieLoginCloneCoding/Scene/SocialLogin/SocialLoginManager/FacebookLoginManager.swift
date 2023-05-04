//
//  FacebookLoginManager.swift
//  millieLoginCloneCoding
//
//  Created by hana on 2023/04/27.
//

import Foundation
import FacebookLogin

class FacebookLoginManager: NSObject, SocialLoginManagerProtocol {
    private var viewController: UIViewController?
    private var delegate: LoginManagerDelegate?
    private var socialLoginVM: SocialLoginProtocol? = SocialLogin()
    private var socialJoinVM: SocialJoinProtocol? = SocialJoin()
    
    ///로그인 요청마다 생성되는 임의의 문자열
    private var currentNonce: String?
        
    func setSocialLoginPresentationAnchorView(_ viewController: UIViewController?, _ delegate: LoginManagerDelegate?) {
        self.viewController = viewController
        self.delegate = delegate
    }
    
    func requestLogin(){
        let loginbutton = FBLoginButton()
        
        loginbutton.delegate = self
        loginbutton.loginTracking = .limited
        
        currentNonce = Cryptography.randomNonceString()
        guard let currentNonce = currentNonce else {return}
        loginbutton.nonce = Cryptography.sha256(currentNonce)
        
        loginbutton.sendActions(for: .touchUpInside)
    }
}


extension FacebookLoginManager: LoginButtonDelegate{
    func loginButtonWillLogin(_ loginButton: FBLoginButton) -> Bool {
//
//        if let nonce = nonceTextField?.text, !nonce.isEmpty {
//            loginButton.nonce = nonce
//        }

        return true
    }
    
    @MainActor
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        
        Task{
            do{
                if let error = error {
                  throw error
                }
                guard let currentNonce = currentNonce else{
                    throw LoginError.discrepancyData(key: "nonce")
                }
                
                guard let idToken = AuthenticationToken.current?.tokenString else {return}
                guard let userID = Profile.current?.userID else {return}

                if viewController is LoginViewController{
                    try await socialLoginVM?.facebookLogin(userID: userID, idToken: idToken, nonce: currentNonce)
                }
                if viewController is JoinViewController{
                    try await socialJoinVM?.facebookLogin(userID: userID, idToken: idToken, nonce: currentNonce)
                }
                delegate?.loginSuccess()
            }
            catch{
                viewController?.presentAlertMessage(message: error.localizedDescription)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
    }
}

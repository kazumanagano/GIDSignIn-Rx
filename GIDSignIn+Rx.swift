
//  Created by Kazuma Nagano on 2018/09/11.
//  Copyright © 2018年 永野 一馬. All rights reserved.
//

import GoogleSignIn
import RxSwift
import RxCocoa

class RxGIDSignInDelegateProxy: DelegateProxy<GIDSignIn, GIDSignInDelegate>,GIDSignInDelegate  {
    public weak private(set) var gidSignIn: GIDSignIn?
    var signInSubject = PublishSubject<GIDGoogleUser>()
    var disconnectSubject = PublishSubject<GIDGoogleUser>()
    
    init(gidSignIn: ParentObject) {
        self.gidSignIn = gidSignIn
        super.init(parentObject: gidSignIn, delegateProxy: RxGIDSignInDelegateProxy.self)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let u = user {
            signInSubject.on(.next(u))
        } else if let e = error {
            signInSubject.on(.error(e))
        }
        _forwardToDelegate?.sign(signIn, didSignInFor:user, withError: error)
    }
    
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let u = user {
            self.disconnectSubject.on(.next(u))
        } else if let e = error {
            self.disconnectSubject.on(.error(e))
        }
        self._forwardToDelegate?.sign(signIn, didDisconnectWith: user, withError: error)
    }
    
    deinit {
        signInSubject.on(.completed)
        disconnectSubject.on(.completed)
    }
}

extension RxGIDSignInDelegateProxy :DelegateProxyType {
    static func registerKnownImplementations() {
        register { RxGIDSignInDelegateProxy(gidSignIn: $0) }
    }
    
    static func currentDelegate(for object: GIDSignIn) -> GIDSignInDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: GIDSignInDelegate?, to object: GIDSignIn) {
        object.delegate = delegate
    }
}

extension Reactive where Base: GIDSignIn {
    public var delegate: DelegateProxy<GIDSignIn, GIDSignInDelegate> {
        return self.gidSignInDelegate
    }
    
    var signIn: Observable<GIDGoogleUser> {
        let proxy = self.gidSignInDelegate
        proxy.signInSubject = PublishSubject<GIDGoogleUser>()
        return proxy.signInSubject
            .asObservable()
            .do(onSubscribed: {
                proxy.gidSignIn?.signIn()
            })
            .take(1)
            .asObservable()
    }
    
    var signInSilent: Observable<GIDGoogleUser> {
        let proxy = self.gidSignInDelegate
        proxy.signInSubject = PublishSubject<GIDGoogleUser>()
        return proxy.signInSubject
            .asObservable()
            .do(onSubscribed: {
                proxy.gidSignIn?.signInSilently()
            })
            .take(1)
            .asObservable()
    }
    
    var signOut: Observable<GIDGoogleUser> {
        let proxy = self.gidSignInDelegate
        proxy.signInSubject = PublishSubject<GIDGoogleUser>()
        return proxy.disconnectSubject
            .asObservable()
            .do(onSubscribed: {
                proxy.gidSignIn?.signOut()
            })
            .take(1)
            .asObservable()
    }
    
    private var gidSignInDelegate: RxGIDSignInDelegateProxy {
        return RxGIDSignInDelegateProxy.proxy(for: base)
    }
}

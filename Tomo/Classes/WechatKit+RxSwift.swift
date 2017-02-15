//
//  WechatKit+RxSwift.swift
//  Tomo
//
//  Created by starboychina on 2017/02/15.
//  Copyright © 2017 e-business. All rights reserved.
//

import RxSwift
import WechatKit

extension WechatManager {
    /// create an Observable of WechatKit.CheckAuth
    ///
    /// - Returns: <#return value description#>
    func rxCheckAuth() -> Observable<[String : Any]> {
        return Observable<[String : Any]>.create { observer in
            let disposable = Disposables.create()
            self.checkAuth {
                self.observerTask(disposable: disposable, observer: observer, response: $0)
            }
            return disposable
        }
    }

    /// create an Observable of WechatKit.getUserInfo
    ///
    /// - Returns: <#return value description#>
    func rxGetUserInfo() -> Observable<[String : Any]> {
        return Observable<[String : Any]>.create { observer in
            let disposable = Disposables.create()
            self.getUserInfo {
                self.observerTask(disposable: disposable, observer: observer, response: $0)
            }

            return disposable
        }
    }

    /// Implementation of the resulting observable sequence's `subscribe` method
    ///
    /// - Parameters:
    ///   - disposable: <#disposable description#>
    ///   - observer: <#observer description#>
    ///   - response: <#response description#>
    private func observerTask(disposable: Disposable,
                              observer: AnyObserver<[String : Any]>,
                              response: WechatKit.Result<[String : Any], Int32>) {
        guard let parameters = response.value else {
            let err = NSError(domain: "errorDomain", code: Int(response.error!), userInfo: nil)
            observer.onError(err)
            disposable.dispose()
            return
        }

        observer.onNext(parameters)
        observer.onCompleted()
        disposable.dispose()
    }
}

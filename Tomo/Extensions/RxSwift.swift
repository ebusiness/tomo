//
//  RxSwift.swift
//  Tomo
//
//  Created by starboychina on 2017/02/16.
//  Copyright © 2017 e-business. All rights reserved.
//

import RxSwift

extension ObservableType {
    /**
     Subscribes an element handler, an error handler to an observable sequence.
     
     - parameter onNext: Action to invoke for each element in the observable sequence.
     - parameter onError: Action to invoke upon errored termination of the observable sequence.
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
    @discardableResult
    public func subscribe(onNext: ((Self.E) -> Void)? = nil, onError: ((Error) -> Void)? = nil) -> Disposable {
        #if DEBUG
            return self.subscribe(onNext: onNext, onError: onError, onCompleted: {
                print("onCompleted")
            }, onDisposed: {
                print("onCompleted")
            })
        #else
            return self.subscribe(onNext: onNext, onError: onError)
        #endif
    }
}

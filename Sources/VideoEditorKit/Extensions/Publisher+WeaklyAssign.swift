//
//  Publisher+WeaklyAssign.swift
//  
//
//  Created by Titouan Van Belle on 29.10.20.
//

import Combine

extension Publisher where Self.Failure == Never {
    func assign<Root: AnyObject>(
        to keyPath: WritableKeyPath<Root, Self.Output>, weakly object: Root) -> AnyCancellable {
        sink { [weak object] (output) in
            object?[keyPath: keyPath] = output
        }
    }
}

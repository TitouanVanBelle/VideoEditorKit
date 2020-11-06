//
//  Lens.swift
//  
//
//  Created by Titouan Van Belle on 06.11.20.
//

import Foundation

public struct Lens <Whole,Part> {
    public let from: (Whole) -> Part
    public let to: (Part, Whole) -> Whole

    public init(from: @escaping (Whole) -> Part, to: @escaping (Part, Whole) -> Whole) {
        self.from = from
        self.to = to
    }
}

public func compose<A,B,C>(_ lhs: Lens<A, B>,_ rhs: Lens<B,C>) -> Lens<A, C> {
    Lens<A, C>(
        from: { a in rhs.from(lhs.from(a)) },
        to: { (c, a) in lhs.to(rhs.to(c, lhs.from(a)),a)}
    )
}

public func * <A, B, C>(_ lhs: Lens<A, B>,_ rhs: Lens<B,C>) -> Lens<A, C> {
    compose(lhs, rhs)
}

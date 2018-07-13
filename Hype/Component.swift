//
//  Component.swift
//  Hype
//
//  Created by Christopher Constable on 7/1/18.
//  Copyright © 2018 Chris Constable. All rights reserved.
//

import Foundation

public typealias Component<T> = (T) -> Node

public func container(_ node: Node) -> Component<Node> {
    return { child in
        switch node {
        case let .element(name, classes, attributes, _):
            return .element(name: name,
                            classes: classes,
                            attributes: attributes,
                            children: child)
        default:
            return .empty
        }
    }
}

public func listComponent<T>(_ f: @escaping Component<T>) -> Component<[T]> {
    return { list in
        return list
            .map(f)
            .reduce(.empty, +)
    }
}

// MARK: Monoid

public func +<A>(_ lhs: @escaping Component<A>, _ rhs: @escaping Component<A>) -> Component<A> {
    return { state in .siblings(nodes: [lhs(state), rhs(state)]) }
}

public func empty() -> Component<()> {
    return { _ in return .empty }
}

// MARK: Monofunctor

public func map<A>(_ c: @escaping Component<A>) -> (@escaping (Node) -> Node) -> Component<A> {
    return { f in
        return { f(c($0)) }
    }
}

// MARK: Contravariant functor

public func contramap<A, B>(_ c: @escaping Component<A>) -> (@escaping (B) -> A) -> Component<B> {
    return { f in
        return { c(f($0)) }
    }
}

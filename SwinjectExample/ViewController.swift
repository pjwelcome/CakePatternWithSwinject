//
//  ViewController.swift
//  SwinjectExample
//
//  Created by pjapple on 2018/04/14.
//  Copyright © 2018 Multimeleon. All rights reserved.
//

import UIKit
import Swinject

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

public protocol Resolvable {
    func resolve<T>(_ dependency: T.Type) -> T
    func reset()
}

public protocol Registrable {
    func register<T>(depedency: T.Type, implemenation: @escaping () -> T, objectScope: ObjectScope)
}

public protocol Resolving {
    static func resolve<T>(_ dependency: T.Type) -> T
    static func reset()
}

class Resolver {
    private static var container: Resolvable = DepedencyContainer.instance
}

extension Resolver : Resolving {
    
    public static func resolve<T>(_ dependency: T.Type) -> T {
        return container.resolve(dependency)
    }
    public static func reset() {
        container.reset()
    }
}

class DepedencyContainer {
    
    private let container = Container()
    public static let instance = DepedencyContainer()
}

extension DepedencyContainer : Registrable {
    
    public func register<T>(depedency: T.Type, implemenation: @escaping () -> T, objectScope: ObjectScope = .graph) {
        container.register(depedency, factory: { _ in implemenation() }).inObjectScope(objectScope)
    }
}

extension DepedencyContainer : Resolvable {
    
    public func resolve<T>(_ dependency: T.Type) -> T {
        guard let implementation = container.resolve(dependency) else {
            fatalError("Nothing to Resolve")
        }
        return implementation
    }
    
    public func reset() {
        container.removeAll()
    }
}

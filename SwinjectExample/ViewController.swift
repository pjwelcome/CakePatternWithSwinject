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
        let container = DepedencyContainer.instance
        container.register(depedency: ProductsRepository.self, implemenation: {
            ProductsRepositoryImplementation()
        })
        _ = ProductViewModel()
    }
}

struct ProductViewModel: ProductsRepositoryInjectable {
    
    init() {
        self.products.fetchProducts().forEach {
            print("This \($0.name) costs R\($0.price)")
        }
    }
}

struct Product {
    var name: String
    var price : Double
}

protocol ProductsRepository {
    
    func fetchProducts() -> [Product]
}

protocol ProductsRepositoryInjectable {
    var products : ProductsRepository {get}
}

struct ProductsRepositoryImplementation : ProductsRepository {
    func fetchProducts() -> [Product] {
        
        return [Product(name: "Adidas Sneakers", price: 500.0), Product(name: "Nike Sneakers", price: 1000.0)]
    }
}

extension ProductsRepositoryInjectable {
    
    var products : ProductsRepository {
        return Resolver.resolve(dependency: ProductsRepository.self)
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
    static func resolve<T>( dependency: T.Type) -> T
    static func reset()
}

class Resolver {
    private static var container: Resolvable = DepedencyContainer.instance
}

extension Resolver : Resolving {
    
    public static func resolve<T>(dependency: T.Type) -> T {
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

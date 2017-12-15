//
//  Filter.swift
//  The Wave
//
//  Created by Andrew Robinson on 12/15/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import Foundation
import Firebase
import GeoFire

typealias ProductAddedBlock = (_ product: Product?) -> Void
typealias ProductRemovedBlock = (_ product: Product?) -> Void

enum FilterType {
    case location(Int) // in miles
    case model
}

class Filter {
    var type = FilterType.model
    var model = JeepModel.all

    var modelQuery: DatabaseQuery?
    var locationQuery: GFCircleQuery?

    func grabProducts(forReference reference: DatabaseReference, productAdded: @escaping ProductAddedBlock, productRemoved: @escaping ProductRemovedBlock) {
        switch type {
        case .model:
            modelSearch(forReference: reference, productAdded: productAdded, productRemoved: productRemoved)
        case .location(_):
            locationSearch(productAdded: productAdded, productRemoved: productRemoved)
        }
    }

    // MARK: - Model Search

    private func modelSearch(forReference reference: DatabaseReference, productAdded: @escaping ProductAddedBlock, productRemoved: @escaping ProductRemovedBlock) {

        modelQuery = reference.queryOrdered(byChild: "soldModel").queryStarting(atValue: "SELLING").queryEnding(atValue: "SELLING\u{f8ff}").queryLimited(toLast: 200)
        if model != .all {
            modelQuery = reference.queryOrdered(byChild: "soldModel")
                .queryStarting(atValue: "SELLING" + model.name)
                .queryEnding(atValue: "SELLING" + model.name)
                .queryLimited(toLast: 200)
        }

        modelQuery!.observe(.childAdded, with: { snapshot in
            if let productDict = snapshot.value as? [String: AnyObject] {
                if let product = Product.createProduct(with: productDict, with: snapshot.key) {
                    productAdded(product)
                }
            }

            productAdded(nil)
        })

        modelQuery!.observe(.childRemoved, with: { snapshot in
            if let productDict = snapshot.value as? [String: AnyObject] {
                if let product = Product.createProduct(with: productDict, with: snapshot.key) {
                    productRemoved(product)
                }
            }

            productRemoved(nil)
        })
    }

    // MARK: - Location search

    private func locationSearch(productAdded: @escaping ProductAddedBlock, productRemoved: @escaping ProductRemovedBlock) {
        switch type {
        case .location(let distance):
            if let last = Location.manager.lastLocation {

                let reference = Database.database().reference().child("product-locations")
                let geo = GeoFire(firebaseRef: reference)
                locationQuery = geo?.query(at: last, withRadius: Double(distance.toMeters() / 1000))
                locationQuery?.observe(.keyEntered, with: { key, location in
                    if let key = key, let _ = location {
                        self.findProductForKey(key: key, block: { product in
                            if let product = product {
                                productAdded(product)
                            } else {
                                productAdded(nil)
                            }
                        })
                    } else {
                        productAdded(nil)
                    }
                })

                locationQuery?.observe(.keyExited, with: { key, location in
                    if let key = key, let _ = location {
                        self.findProductForKey(key: key, block: { product in
                            if let product = product {
                                productRemoved(product)
                            } else {
                                productRemoved(nil)
                            }
                        })
                    } else {
                        productRemoved(nil)
                    }
                })
            }
        default:
            break
        }
    }

    private func findProductForKey(key: String, block: @escaping ((Product?) -> ())) {
        let ref = Database.database().reference().child("products").child(key)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let productDict = snapshot.value as? [String: AnyObject] {
                if let product = Product.createProduct(with: productDict, with: snapshot.key) {
                    block(product)
                }
            }

            block(nil)
        })
    }
}

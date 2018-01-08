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
import SwiftKeychainWrapper

typealias ProductAddedBlock = (_ product: Product?) -> Void
typealias ProductRemovedBlock = (_ product: Product?) -> Void

protocol FilterDelegate {
    func filterResetQueries()
}

enum FilterType {
    case location // in miles
    case model
}

class Filter: LocationDelegate {
    var type = FilterType.model
    var model: JeepModel {
        didSet {
            KeychainWrapper.standard.set(model.name, forKey: UserInfoKeys.UserSelectedJeep)
        }
    }

    let minimumRadius = 0
    let maximumRadius = 250
    var radius: Int {
        didSet {
            KeychainWrapper.standard.set(radius, forKey: UserInfoKeys.UserSelectedRadius)
        }
    }

    var delegate: FilterDelegate?

    private var modelQuery: DatabaseQuery?
    private var locationQuery: GFCircleQuery?

    private var savedAddBlock: ProductAddedBlock?
    private var savedRemoveBlock: ProductRemovedBlock?
    private var lastSavedLocation: CLLocation?
    private var locationCheckTimer: Timer?

    init() {
        let selectedJeepDescription = KeychainWrapper.standard.string(forKey: UserInfoKeys.UserSelectedJeep) ?? ""
        model = JeepModel.enumFromString(string: selectedJeepDescription)

        // Default to 100 mile radius, this will prompt a location search.
        radius = KeychainWrapper.standard.integer(forKey: UserInfoKeys.UserSelectedRadius) ?? 100
    }

    func grabProducts(forReference reference: DatabaseReference, productAdded: @escaping ProductAddedBlock, productRemoved: @escaping ProductRemovedBlock) {
        switch type {
        case .model:
            if Location.manager.hasStartedLocationServices {
                Location.manager.stopGathering()
            }

            modelSearch(forReference: reference, productAdded: productAdded, productRemoved: productRemoved)
        case .location:
            if Auth.auth().currentUser == nil {
                modelSearch(forReference: reference, productAdded: productAdded, productRemoved: productRemoved)
                return
            }

            if !Location.manager.hasStartedLocationServices {
                Location.manager.startGatheringAndRequestPermission()
                Location.manager.add(asDelegate: self)
                lastSavedLocation = Location.manager.lastLocation
            }

            if !Location.manager.hasLocationAccess {
                modelSearch(forReference: reference, productAdded: productAdded, productRemoved: productRemoved)
            }

            savedAddBlock = productAdded
            savedRemoveBlock = productRemoved

            if let timer = locationCheckTimer {
                timer.invalidate()
                lastSavedLocation = nil
            }

            locationCheckTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true, block: { timer in
                if let loc = Location.manager.lastLocation,
                    self.lastSavedLocation?.coordinate.latitude != loc.coordinate.latitude,
                    self.lastSavedLocation?.coordinate.longitude != loc.coordinate.longitude {
                    self.lastSavedLocation = loc
                    if let add = self.savedAddBlock, let remove = self.savedRemoveBlock {
                        self.locationSearch(productAdded: add, productRemoved: remove)
                    }
                }
            })
            locationCheckTimer?.fire()
        }
    }

    // MARK: - Model Search

    private func modelSearch(forReference reference: DatabaseReference, productAdded: @escaping ProductAddedBlock, productRemoved: @escaping ProductRemovedBlock) {
        modelQuery?.removeAllObservers()
        locationQuery?.removeAllObservers()
        delegate?.filterResetQueries()

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
        locationQuery?.removeAllObservers()
        modelQuery?.removeAllObservers()
        delegate?.filterResetQueries()

        if let last = Location.manager.lastLocation {

            let reference = Database.database().reference().child("product-locations")
            let geo = GeoFire(firebaseRef: reference)
            locationQuery = geo?.query(at: last, withRadius: Double(radius.toMeters() / 1000))
            locationQuery?.observe(.keyEntered, with: { key, location in
                if let key = key, let _ = location {
                    self.findProductForKey(key: key, block: { product in
                        if let product = product {
                            if self.model == .all {
                                productAdded(product)
                            } else if self.model == product.jeepModel {
                                productAdded(product)
                            } else {
                                productAdded(nil)
                            }
                        } else {
                            productAdded(nil)
                        }
                    })
                } else {
                    productAdded(nil)
                }
            })

            locationQuery?.observe(.keyExited, with: { key, location in
                if let key = key {
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

    // MARK: - Location delegate

    func didUpdate(with location: CLLocation) {
        if lastSavedLocation == nil {
            locationCheckTimer?.fire()
        }
    }

}

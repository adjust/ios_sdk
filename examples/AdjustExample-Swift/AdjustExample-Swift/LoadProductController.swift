//
//  LoadProductController.swift
//  AdjustExample-Swift
//
//  Created by Ricardo Carvalho on 05/08/2020.
//  Copyright © 2020 adjust GmbH. All rights reserved.
//

import UIKit
import StoreKit

struct ProductParameters: Codable {
    let adNetworkId: String
    let adNetworkVersion: String
    let campaignId  : String
    let id: String
    let nonce: String
    let signature: String
    let sourceAppId: String
    let timestamp: String
}

protocol ProductLoadable {
    func loadProduct(from source: UIViewController)
}

@available(iOS 14.0, *)
class LoadProductController: NSObject, ProductLoadable {
    
    let version = "2.0"
    let store = SKStoreProductViewController()
    
    func loadProduct(from source: UIViewController) {
        
        guard var URL = URL(string: "http://10.8.2.155:8000/get-ad-impression") else {return}
        let URLParams = [
            "skadnetwork_version": version,
            "source_app_id": "com.adjust.examples",
        ]
        
        URL = URL.appendingQueryParameters(URLParams)
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        
        let semaphore = DispatchSemaphore(value: 0)
        var product: ProductParameters!
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            product = try! JSONDecoder().decode(ProductParameters.self, from: data!)
            
            semaphore.signal()
        })
        task.resume()
        
        semaphore.wait()
        
        let parameters: [String: Any] = [SKStoreProductParameterITunesItemIdentifier: NSNumber(integerLiteral: Int(product.id)!),
                                          SKStoreProductParameterAdNetworkIdentifier: product.adNetworkId,
                                  SKStoreProductParameterAdNetworkCampaignIdentifier: NSNumber(integerLiteral: Int(product.campaignId)!),
                                           SKStoreProductParameterAdNetworkTimestamp: NSNumber(value: Int(product.timestamp)!),
                                               SKStoreProductParameterAdNetworkNonce: NSUUID(uuidString: product.nonce),
                            SKStoreProductParameterAdNetworkSourceAppStoreIdentifier: product.sourceAppId,
                                             SKStoreProductParameterAdNetworkVersion: version,
                                SKStoreProductParameterAdNetworkAttributionSignature: product.signature]
        
        
        store.loadProduct(withParameters: parameters) { (result, error) in
            if let error = error {
                print("Error on loading = \(error)")
            } else {
                print("Loaded with success")
                source.present(self.store, animated: true, completion: nil)
            }
        }
        
    }
    
}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
     */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
}

extension URL {
    /**
     Creates a new URL by adding the given query parameters.
     @param parametersDictionary The query parameter dictionary to add.
     @return A new URL.
     */
    func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString)!
    }
}



//
//  Extensions.swift
//  VideoPlayerStoryboard
//
//  Created by Eugene Lu on 2022-09-22.
//

import Foundation
import UIKit

extension URLSession {
    // Function to bridge iOS 15 async data(from url: URL) function for use in iOS 13/14. Taken from https://thisdevbrain.com/how-to-use-async-await-with-ios-13/
    @available(iOS, deprecated: 15.0, message: "This extension is no longer necessary for iOS 15.0+. Use API built into SDK")
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }
                
                continuation.resume(returning: (data, response))
            }
            
            task.resume()
        }
    }
}

extension UIViewController {
    /// Shows a basic alert in the `UIViewController` with a default OK action.
    /// - Parameters:
    ///     - alertTitle: The title shown in the alert.
    ///     - alertMessage: The message shown in the alert.
    func showAlert(alertTitle: String, alertMessage: String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))

        self.present(alert, animated: true, completion: nil)
    }
}

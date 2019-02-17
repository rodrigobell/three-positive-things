//
//  ReviewHandler.swift
//  symbo
//
//  Created by Rodrigo Bell on 2/3/19.
//  Copyright © 2019 Rodrigo Bell. All rights reserved.
//

import UIKit
import StoreKit

class ReviewHandler {
    let launchCountUserDefaultsKey = "noOfLaunches"
    
    func showReviewView(atLaunchCounts: [Int]) {
        let launchCount = UserDefaults.standard.integer(forKey: launchCountUserDefaultsKey)
        UserDefaults.standard.set((launchCount + 1), forKey: launchCountUserDefaultsKey)

        if atLaunchCounts.contains(launchCount) {
            SKStoreReviewController.requestReview()
        }
    }
}

import UIKit
import StoreKit
import Firebase

class ReviewHandler {
  let launchCountUserDefaultsKey = "noOfLaunches"
  
  func showReviewView(atLaunchCounts: [Int]) {
    let launchCount = UserDefaults.standard.integer(forKey: launchCountUserDefaultsKey)
    UserDefaults.standard.set((launchCount + 1), forKey: launchCountUserDefaultsKey)
    
    if atLaunchCounts.contains(launchCount) {
      Analytics.logEvent("review_popup_shown", parameters: nil)
      SKStoreReviewController.requestReview()
    }
  }
}

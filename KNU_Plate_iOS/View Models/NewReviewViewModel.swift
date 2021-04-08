import Foundation
import UIKit

class NewReviewViewModel {
    
    var newReview = NewReview()
    
    // Variable Initialization
    
    var rating: Int {
        didSet {
            newReview.rating = rating
        }
    }
    
//
//    var userSelectedImagesInJPEG: Data {
//        didSet {
//
//        }
//    }
    
    var userSelectedImages: [UIImage] {
        
        willSet {
            userSelectedImages.removeAll()
        }
        
        didSet {
            /// 받은 UIImage 를 JPEGData 로 저장하고,
            /// userSelectedImagesInJPEG 에 저장 후
            /// NewReview 모델에 저장
        }
    }
    
    
    var menu: [Menu] //{
//        didSet {
//            newReview.menu.append(contentsOf: menu)
//        }
//    }
    
    var review: String {
        didSet {
            newReview.review = review
        }
    }
    
    
    public init() {
        
        self.rating = 3
        self.review = ""
        self.userSelectedImages = [UIImage]()
        self.menu = [Menu]()
        
    }
    
    func addNewMenu() {
        
        let newMenu = Menu()
        self.menu.append(newMenu)
    }
    
    
}

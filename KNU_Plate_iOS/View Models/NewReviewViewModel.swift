import Foundation
import UIKit

class NewReviewViewModel {
    
    var newReview = NewReview()
    
    //MARK: - Object Properties
    
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
    
    
    var menus: [Menu] //{
//        didSet {
//            newReview.menu.append(contentsOf: menu)
//        }
        
        
    //}
    
    var review: String {
        didSet {
            newReview.review = review
        }
    }
    
    //MARK: - Init
    
    public init() {
        
        self.rating = 3
        self.review = ""
        self.userSelectedImages = [UIImage]()
        self.menus = [Menu]()
        
    }
    
    //MARK: - Object Methods
    
    func addNewMenu(name: String) {
        
        let newMenu = Menu()
        newMenu.menuName = name
        self.menus.append(newMenu)

    }
    
    func validateUserInputs() throws {
        
        /// 메뉴 개수가 0개이면 Error
        if self.menus.count == 0 { throw NewReviewInputError.insufficientMenuError }
        
        /// 리뷰 글자수가 5 미만이면 Error
        if self.review.count < 5 { throw NewReviewInputError.insufficientReviewError }
        
        /// 입력한 메뉴 중 메뉴명이 비어있는게 하나라도 있으면 Error
        for eachMenu in self.menus {
            
            guard eachMenu.menuName.count > 0 else {
                throw NewReviewInputError.blankMenuNameError
            }
        }
        
    }
    
    
}


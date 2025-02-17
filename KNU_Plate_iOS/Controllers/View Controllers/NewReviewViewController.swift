import UIKit
import Alamofire

class NewReviewViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var starRating: RatingController!
    @IBOutlet weak var reviewImageCollectionView: UICollectionView!
    @IBOutlet weak var menuInputTextField: UITextField!
    @IBOutlet weak var menuInputTableView: UITableView!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!

    private let viewModel: NewReviewViewModel = NewReviewViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
   

    }
    
    func testSignup() {

        let username = "alexding"
        let displayName = "alexding"
        let password = "123456789"
        let email = "alexding@knu.ac.kr"

        let newRegisterModel = RegisterInfoModel(username: username, displayName: displayName, password: password, email: email)

        UserManager.shared.signUp(with: newRegisterModel)
    }
    
    @objc func pressedAddMenuButton() {
        
        //MARK: - TODO : Error 처리를 VC 에서 하는게 맞는가? View Model 에서 하는거 고려해보기
        
        if viewModel.menus.count >= 5 {
            menuInputTextField.text?.removeAll()
            let alert = AlertManager.createAlertMessage(("메뉴는 최대 5개 입력 가능"), "메뉴는 최대 5개까지만 입력이 가능합니다.")
            self.present(alert, animated: true)
            return
        }
        
        if let nameOfMenu = menuInputTextField.text {

            if nameOfMenu.count == 0 {
                
                let alert = AlertManager.createAlertMessage("드신 메뉴를 입력해주세요.", "빈 칸으로 놔두는건 안 돼요~")
                self.present(alert, animated: true)
                return
            }
            
            viewModel.addNewMenu(name: nameOfMenu)
            
            menuInputTableView.reloadData()
            self.viewWillLayoutSubviews()
            menuInputTextField.text?.removeAll()
            
            
            
        }
    }
    
    
    // 완료 버튼 눌렀을 시 실행
    @IBAction func pressedFinishButton(_ sender: UIBarButtonItem) {
        
        self.view.endEditing(true)
    
        do {

            //TODO: - 마지막으로 업로드하기 전에 확인 질문 띄우기?
            //TODO: - "완료" 버튼 누르고 시간이 좀 많이 걸린다 싶으면 activity indicator (loading 표시) 하나 넣는거 고려
            
            try viewModel.validateUserInputs()
            viewModel.rating = starRating.starsRating
            
            
            
            print("입력 모두 정상")
            print(viewModel.rating)
            print(viewModel.menus[0].menuName)
            print(viewModel.review)
            print(starRating.starsRating)
            /// user input이 정상이라면 본격 업로드
            
       
            
            
            
        } catch NewReviewInputError.insufficientMenuError {
            
            let alert = AlertManager.createAlertMessage("입력 오류", with: NewReviewInputError.insufficientMenuError.errorDescription)
            self.present(alert, animated: true)

        } catch NewReviewInputError.insufficientReviewError {
            
            let alert = AlertManager.createAlertMessage("입력 오류", with: NewReviewInputError.insufficientReviewError.errorDescription )
            self.present(alert, animated: true)
            

        } catch NewReviewInputError.blankMenuNameError {
            
            let alert = AlertManager.createAlertMessage("입력 오류", with: NewReviewInputError.blankMenuNameError.errorDescription)
            self.present(alert, animated: true)
        }
        catch {
            print("Unexpected Error occured in pressedFinishButton")
        }

        /// API related methods needed here (upload)
        /// viewModel 내에서 NetworkManager.shared.uploadNewReview( ) 이런 식으로 해야 할듯
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource -> 사용자가 업로드 할 사진을 위한 Collection View

extension NewReviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.viewModel.userSelectedImages.count + 1     /// Add Button 이 항상 있어야하므로 + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let addImageButtonCellIdentifier = Constants.CellIdentifier.addFoodImageCell
        let newFoodImageCellIdentifier = Constants.CellIdentifier.newUserPickedFoodImageCell
        
        /// 첫 번째 Cell 은 항상 Add Button
        if indexPath.item == 0 {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: addImageButtonCellIdentifier, for: indexPath) as? AddImageButtonCollectionViewCell else {
                fatalError("Failed to dequeue cell for AddImageButtonCollectionViewCell")
            }
            cell.delegate = self
            return cell
        }
        
        /// 그 외의 셀은 사용자가 고른 사진으로 구성된  Cell
        else {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newFoodImageCellIdentifier, for: indexPath) as? UserPickedFoodImageCollectionViewCell else {
                fatalError("Failed to dequeue cell for UserPickedFoodImageCollectionViewCell")
            }
            
            cell.delegate = self
            cell.indexPath = indexPath.item
            
            /// 사용자가 앨범에서 고른 사진이 있는 경우
            if viewModel.userSelectedImages.count > 0 {
                cell.userPickedImageView.image = viewModel.userSelectedImages[indexPath.item - 1]
            }
            return cell
        }
    }
}

//MARK: - AddImageDelegate

extension NewReviewViewController: AddImageDelegate {
    
    func didPickImagesToUpload(images: [UIImage]) {
        
        viewModel.userSelectedImages = images
        reviewImageCollectionView.reloadData()
    }
}

//MARK: - UserPickedFoodImageCellDelegate

extension NewReviewViewController: UserPickedFoodImageCellDelegate {

    func didPressDeleteImageButton(at index: Int) {

        viewModel.userSelectedImages.remove(at: index - 1)
        reviewImageCollectionView.reloadData()
        viewWillLayoutSubviews()
    }
}

//MARK: - NewMenuTableViewCellDelegate

extension NewReviewViewController: NewMenuTableViewCellDelegate {
   
    // 이미 추가한 메뉴의 이름을 변경했을 때 실행되는 함수
    func didChangeMenuName(at index: Int, _ newMenuName: String) {
       viewModel.menus[index].menuName = newMenuName
    }
    
    func didPressDeleteMenuButton(at index: Int) {
    
        viewModel.menus.remove(at: index)
        menuInputTableView.reloadData()
        viewWillLayoutSubviews()
    }
    
    func didPressEitherGoodOrBadButton(at index: Int, menu isGood: Bool) {
        viewModel.menus[index].isGood = isGood
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource -> 메뉴 입력을 위한 TableView

extension NewReviewViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.newMenuTableViewCell, for: indexPath) as? NewMenuTableViewCell else {
            fatalError("Failed to dequeue cell for NewMenuTableViewCell")
        }
        
        if self.viewModel.menus.count != 0 {
            
            let menuInfo = viewModel.menus[indexPath.row]
            
            cell.delegate = self
            cell.menuNameTextField.text = menuInfo.menuName
            cell.indexPath = indexPath.row
        }
        return cell
    }
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        self.tableViewHeight?.constant = self.menuInputTableView.contentSize.height
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width:self.view.bounds.width, height: view.frame.height)
    }

}

//MARK: - UIPickerViewDataSource & UIPickerViewDelegate

extension NewReviewViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        //TODO: - viewModel.existingMenu.count 뭐 이런식으로 해야할듯
        /// 가장 마지막 row 는 "직접 입력" 이어야 함 -> dismiss picker view and keyboard pop up
        
        return 5
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "Hello"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        menuInputTextField.text = "Hello"
        print("didSelectRow activated")
    }
    
    
}


//MARK: - UITextFieldDelegate -> For menuInputTextField

extension NewReviewViewController: UITextFieldDelegate {
    
    
}

//MARK: - UITextViewDelegate -> For reviewTextView

extension NewReviewViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
    
        if textView.text.isEmpty {
            textView.text = "방문하셨던 맛집에 대한 솔직한 리뷰를 남겨주세요!"
            textView.textColor = UIColor.lightGray
            return
        }
        viewModel.review = textView.text
    }
}

//MARK: - UI Configuration

extension NewReviewViewController {
    
    func initialize() {
        
        initializeTextField()
        initializeCollectionView()
        initializeTableView()
        initializeTextView()
    }
    
    func initializeTableView() {
        
        menuInputTableView.delegate = self
        menuInputTableView.dataSource = self
        
        let menuNib = UINib(nibName: Constants.XIB.newMenuTableViewCell, bundle: nil)
        let cellIdentifier = Constants.CellIdentifier.newMenuTableViewCell
        menuInputTableView.register(menuNib, forCellReuseIdentifier: cellIdentifier)
    }
    
    func initializeCollectionView() {
        
        reviewImageCollectionView.delegate = self
        reviewImageCollectionView.dataSource = self
    }
    
    func initializeTextView() {
        
        reviewTextView.delegate = self
        reviewTextView.text = "방문하셨던 맛집에 대한 솔직한 리뷰를 남겨주세요!"
        reviewTextView.textColor = UIColor.lightGray
        
        reviewTextView.layer.cornerRadius = 14.0
        reviewTextView.clipsToBounds = true
        reviewTextView.layer.borderWidth = 1
        reviewTextView.layer.borderColor = UIColor.black.cgColor
    }
    
    func initializeTextField() {
        
        menuInputTextField.delegate = self
        menuInputTextField.placeholder = "메뉴를 고르시거나 직접 입력해 보세요!"
        menuInputTextField.layer.cornerRadius = menuInputTextField.frame.height / 2
        menuInputTextField.clipsToBounds = true
        menuInputTextField.layer.borderWidth = 1
        menuInputTextField.layer.borderColor = UIColor.black.cgColor
        
        menuInputTextField.leftView = UIView(frame: CGRect(x: 0,
                                                           y: 0,
                                                           width: 10,
                                                           height: 0))
        menuInputTextField.leftViewMode = .always
            
        let addMenuButton = UIButton(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: 25,
                                                   height: 25))
        
        addMenuButton.setImage(UIImage(named: "plus button"),
                               for: .normal)
        addMenuButton.isUserInteractionEnabled = true
        addMenuButton.contentMode = .scaleAspectFit
        addMenuButton.addTarget(self,
                                action: #selector(pressedAddMenuButton),
                                for: .touchUpInside)
        
        let rightView = UIView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: 30,
                                             height: 25))
        rightView.addSubview(addMenuButton)
        menuInputTextField.rightView = rightView
        menuInputTextField.rightViewMode = .always
        initializePickerViewForMenuTextField()
    }
    
    func initializePickerViewForMenuTextField() {
        
        let existingMenusPickerView = UIPickerView()
        existingMenusPickerView.backgroundColor = .white
        existingMenusPickerView.delegate = self
        existingMenusPickerView.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .systemBlue
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "완료",
                                         style: UIBarButtonItem.Style.done,
                                         target: self,
                                         action: #selector(self.dismissPicker))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
                                          target: nil,
                                          action: nil)
        
        let cancelButton = UIBarButtonItem(title: "취소",
                                           style: UIBarButtonItem.Style.plain,
                                           target: self,
                                           action: #selector(self.dismissPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        menuInputTextField.inputView = existingMenusPickerView
        menuInputTextField.inputAccessoryView = toolBar
    }
    
    @objc func dismissPicker(){
        self.view.endEditing(true)
    }
    
}

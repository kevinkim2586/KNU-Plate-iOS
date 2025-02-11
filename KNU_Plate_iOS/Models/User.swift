import Foundation

class User {
    
    //MARK: - Singleton
    static var shared: User = User()
    
    /// user unique ID
    public var id: String
    
    /// username
    public var username: String
    
    /// user password
    public var password: String
    
    /// nickname
    public var displayName: String
    
    /// user email address (...@knu.ac.kr)
    public var email: String
    
    /// registered date
    public var dateCreated: String
    
    public var isActive: String
     
    /// variable for medal image
    public var ranking: Int
    
    private init() {
        self.id = ""
        self.username = ""
        self.password = ""
        self.displayName = ""
        self.email = ""
        self.dateCreated = ""
        self.isActive = ""
        self.ranking = 3
    }

    enum Codingkeys: String, CodingKey {

        case password

        case username = "user_name"
        case displayName = "display_name"
        case email = "mail_address"
        case dateCreated = "date_create"
        case isActive = "is_active"
    }
    
    
}

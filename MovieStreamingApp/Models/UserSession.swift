import Foundation

struct UserSession: Codable, Equatable {
    let user: User
    let token: String
    let loginDate: Date
    let expiresAt: Date

    var isExpired: Bool {
        Date() > expiresAt
    }
    
    var remainingDays: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: expiresAt).day ?? 0
    }
    
    static func == (lhs: UserSession, rhs: UserSession) -> Bool {
        lhs.token == rhs.token
    }
}


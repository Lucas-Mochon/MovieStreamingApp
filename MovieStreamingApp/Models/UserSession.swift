import Foundation

struct UserSession: Codable {
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
}

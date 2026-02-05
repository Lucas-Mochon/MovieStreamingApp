import XCTest
@testable import MovieStreamingApp

final class UserSessionTests: XCTestCase {
    
    func testSessionNotExpired() {
        let user = User(
            id: "1",
            name: "Test",
            email: "test@test.com",
            password: "hashed",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let futureDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        let session = UserSession(
            user: user,
            token: "token123",
            loginDate: Date(),
            expiresAt: futureDate
        )
        
        XCTAssertFalse(session.isExpired)
    }
    
    func testSessionExpired() {
        let user = User(
            id: "1",
            name: "Test",
            email: "test@test.com",
            password: "hashed",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let session = UserSession(
            user: user,
            token: "token123",
            loginDate: Date(),
            expiresAt: pastDate
        )
        
        XCTAssertTrue(session.isExpired)
    }
    
    func testRemainingDays() {
        let user = User(
            id: "1",
            name: "Test",
            email: "test@test.com",
            password: "hashed",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let futureDate = Calendar.current.date(byAdding: .day, value: 15, to: Date())!
        let session = UserSession(
            user: user,
            token: "token123",
            loginDate: Date(),
            expiresAt: futureDate
        )
        
        XCTAssertEqual(session.remainingDays, 14)
    }
    
    func testSessionEquality() {
        let user = User(
            id: "1",
            name: "Test",
            email: "test@test.com",
            password: "hashed",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let futureDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        
        let session1 = UserSession(
            user: user,
            token: "token123",
            loginDate: Date(),
            expiresAt: futureDate
        )
        
        let session2 = UserSession(
            user: user,
            token: "token123",
            loginDate: Date(),
            expiresAt: futureDate
        )
        
        XCTAssertEqual(session1, session2)
    }
}

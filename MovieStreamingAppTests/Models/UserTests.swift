import XCTest
@testable import MovieStreamingApp

final class UserTests: XCTestCase {
    
    func testUserInitialization() {
        let now = Date()
        let user = User(
            id: "123",
            name: "John Doe",
            email: "john@example.com",
            password: "hashedPassword",
            createdAt: now,
            updatedAt: now
        )
        
        XCTAssertEqual(user.id, "123")
        XCTAssertEqual(user.name, "John Doe")
        XCTAssertEqual(user.email, "john@example.com")
    }
}

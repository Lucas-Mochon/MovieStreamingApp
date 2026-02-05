import XCTest
@testable import MovieStreamingApp

@MainActor
final class AuthViewModelTests: XCTestCase {
    
    var viewModel: AuthViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = AuthViewModel()
        viewModel.userService.logout()
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel.userService.logout()
    }
    
    func testInitialState() {
        XCTAssertNil(viewModel.currentSession)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    
    func testRegisterWithEmptyEmail() async {
        await viewModel.register(
            name: "Test User",
            email: "",
            password: "passwordUnit"
        )
        
        XCTAssertNil(viewModel.currentSession)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Email et mot de passe invalides")
    }
    
    func testRegisterWithEmptyPassword() async {
        await viewModel.register(
            name: "Test User",
            email: "test-empty-pwd-\(UUID().uuidString)@test.com",
            password: ""
        )
        
        XCTAssertNil(viewModel.currentSession)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Email et mot de passe invalides")
    }
    
    func testRegisterWithPasswordTooShort() async {
        await viewModel.register(
            name: "Test User",
            email: "test-short-pwd-\(UUID().uuidString)@test.com",
            password: "short"
        )
        
        XCTAssertNil(viewModel.currentSession)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Email et mot de passe invalides")
    }
    
    func testLoginSuccess() async {
        let uniqueEmail = "login-test-\(UUID().uuidString)@test.com"
        
        await viewModel.register(
            name: "Test User",
            email: uniqueEmail,
            password: "password"
        )
        
        await viewModel.logout()
        XCTAssertNil(viewModel.currentSession)
        
        await viewModel.login(
            email: uniqueEmail,
            password: "password"
        )
        
        XCTAssertNotNil(viewModel.currentSession)
        XCTAssertEqual(viewModel.currentSession?.user.email, uniqueEmail)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoginWithInvalidEmail() async {
        await viewModel.login(
            email: "nonexistent-\(UUID().uuidString)@example.com",
            password: "password"
        )
        
        XCTAssertNil(viewModel.currentSession)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Identifiants incorrects")
    }
    
    func testLoginWithInvalidPassword() async {
        let uniqueEmail = "login-invalid-pwd-\(UUID().uuidString)@test.com"
        
        await viewModel.register(
            name: "Test User",
            email: uniqueEmail,
            password: "password"
        )
        
        await viewModel.logout()
        await viewModel.login(
            email: uniqueEmail,
            password: "wrongPassword"
        )
        
        XCTAssertNil(viewModel.currentSession)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Identifiants incorrects")
    }
    
    func testLoginWithEmptyEmail() async {
        await viewModel.login(
            email: "",
            password: "password"
        )
        
        XCTAssertNil(viewModel.currentSession)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testLoginWithEmptyPassword() async {
        await viewModel.login(
            email: "test-empty-login-\(UUID().uuidString)@test.com",
            password: ""
        )
        
        XCTAssertNil(viewModel.currentSession)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testLogoutSuccess() async {
        await viewModel.register(
            name: "Test User",
            email: "logout-test-\(UUID().uuidString)@test.com",
            password: "passwordUnit"
        )
        
        XCTAssertNotNil(viewModel.currentSession)
        
        await viewModel.logout()
        
        XCTAssertNil(viewModel.currentSession)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLogoutWhenNoSession() async {
        XCTAssertNil(viewModel.currentSession)
        
        await viewModel.logout()
        
        XCTAssertNil(viewModel.currentSession)
    }
    
    func testLoadingStateBeforeRegister() async {
        let task = Task {
            await viewModel.register(
                name: "Test User",
                email: "loading-register-\(UUID().uuidString)@test.com",
                password: "passwordUnit"
            )
        }
        
        await task.value
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadingStateBeforeLogin() async {
        let uniqueEmail = "loading-login-\(UUID().uuidString)@test.com"
        
        await viewModel.register(
            name: "Test User",
            email: uniqueEmail,
            password: "password"
        )
        
        await viewModel.logout()
        
        let task = Task {
            await viewModel.login(
                email: uniqueEmail,
                password: "password"
            )
        }
        
        await task.value
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testSessionPersistence() async {
        let uniqueEmail = "persistence-\(UUID().uuidString)@test.com"
        
        await viewModel.register(
            name: "Test User",
            email: uniqueEmail,
            password: "passwordUnit"
        )
        
        let sessionToken = viewModel.currentSession?.token
        
        let newViewModel = AuthViewModel()
        
        XCTAssertNotNil(newViewModel.currentSession)
        XCTAssertEqual(newViewModel.currentSession?.token, sessionToken)
    }
    
    func testErrorMessageClearedOnNewAction() async {
        await viewModel.login(
            email: "invalid-\(UUID().uuidString)@example.com",
            password: "password"
        )
        
        XCTAssertNotNil(viewModel.errorMessage)
        
        await viewModel.register(
            name: "Test User",
            email: "error-cleared-\(UUID().uuidString)@test.com",
            password: "passwordUnit"
        )
        
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSessionValidAfterLogin() async {
        let uniqueEmail = "valid-session-\(UUID().uuidString)@test.com"
        
        await viewModel.register(
            name: "Test User",
            email: uniqueEmail,
            password: "password"
        )
        
        let session = viewModel.currentSession
        XCTAssertNotNil(session)
        XCTAssertFalse(session?.isExpired ?? true)
    }
}

import Foundation
import SQLite3

final class UserDAO {

    private let db: OpaquePointer?

    let SQLITE_TRANSIENT = unsafeBitCast(
        -1,
        to: sqlite3_destructor_type.self
    )

    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    init(db: OpaquePointer? = DatabaseManager.shared.getDB()) {
        self.db = db
    }

    // MARK: - Public API

    func insert(_ user: User) throws {
        let query = """
        INSERT INTO users (id, name, email, password, createdAt, updatedAt)
        VALUES (?, ?, ?, ?, ?, ?);
        """

        let stmt = try prepare(query)
        defer { sqlite3_finalize(stmt) }

        bind(stmt, 1, user.id)
        bind(stmt, 2, user.name)
        bind(stmt, 3, user.email)
        bind(stmt, 4, user.password)
        bind(stmt, 5, dateFormatter.string(from: user.createdAt))
        bind(stmt, 6, dateFormatter.string(from: user.updatedAt))

        try stepDone(stmt)
    }

    func findByEmail(_ email: String) throws -> User? {
        let query = "SELECT * FROM users WHERE email = ? LIMIT 1;"
        let stmt = try prepare(query)
        defer { sqlite3_finalize(stmt) }

        bind(stmt, 1, email)

        return stepRow(stmt) ? parseUser(stmt) : nil
    }

    func findById(_ id: String) throws -> User? {
        let query = "SELECT * FROM users WHERE id = ? LIMIT 1;"
        let stmt = try prepare(query)
        defer { sqlite3_finalize(stmt) }

        bind(stmt, 1, id)

        return stepRow(stmt) ? parseUser(stmt) : nil
    }

    func update(_ user: User) throws {
        let query = """
        UPDATE users
        SET name = ?, email = ?, password = ?, updatedAt = ?
        WHERE id = ?;
        """

        let stmt = try prepare(query)
        defer { sqlite3_finalize(stmt) }

        bind(stmt, 1, user.name)
        bind(stmt, 2, user.email)
        bind(stmt, 3, user.password)
        bind(stmt, 4, dateFormatter.string(from: Date()))
        bind(stmt, 5, user.id)

        try stepDone(stmt)
    }

    func delete(id: String) throws {
        let query = "DELETE FROM users WHERE id = ?;"
        let stmt = try prepare(query)
        defer { sqlite3_finalize(stmt) }

        bind(stmt, 1, id)
        try stepDone(stmt)
    }

    // MARK: - Parsing

    private func parseUser(_ stmt: OpaquePointer?) -> User {
        let id = columnText(stmt, 0)
        let name = columnText(stmt, 1)
        let email = columnText(stmt, 2)
        let password = columnText(stmt, 3)
        let createdAt = date(columnText(stmt, 4))
        let updatedAt = date(columnText(stmt, 5))

        return User(
            id: id,
            name: name,
            email: email,
            password: password,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    // MARK: - Helpers SQLite

    private func prepare(_ query: String) throws -> OpaquePointer? {
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK else {
            throw SQLiteError.prepare(message: errorMessage)
        }
        return stmt
    }

    private func stepDone(_ stmt: OpaquePointer?) throws {
        guard sqlite3_step(stmt) == SQLITE_DONE else {
            throw SQLiteError.step(message: errorMessage)
        }
    }

    private func stepRow(_ stmt: OpaquePointer?) -> Bool {
        sqlite3_step(stmt) == SQLITE_ROW
    }

    private func bind(_ stmt: OpaquePointer?, _ index: Int32, _ value: String) {
        sqlite3_bind_text(
            stmt,
            index,
            (value as NSString).utf8String,
            -1,
            SQLITE_TRANSIENT
        )
    }

    private func columnText(_ stmt: OpaquePointer?, _ index: Int32) -> String {
        guard let cString = sqlite3_column_text(stmt, index) else { return "" }
        return String(cString: cString)
    }

    private func date(_ string: String) -> Date {
        dateFormatter.date(from: string) ?? Date()
    }

    private var errorMessage: String {
        guard let db, let c = sqlite3_errmsg(db) else {
            return "Erreur SQLite inconnue"
        }
        return String(cString: c)
    }
}

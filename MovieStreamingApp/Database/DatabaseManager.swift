import Foundation
import SQLite3

final class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?

    private init() {
        openDatabase()
        createTables()
    }

    deinit {
        sqlite3_close(db)
    }

    private func openDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("movie_streaming.sqlite3")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            fatalError("Erreur ouverture base SQLite")
        }
    }

    private func createTables() {
        let createUserTable = """
        CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
        );
        """

        let createFavoriteTable = """
        CREATE TABLE IF NOT EXISTS favorites (
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            movieId INTEGER NOT NULL,
            movieData BLOB NOT NULL,
            addedAt TEXT NOT NULL,
            FOREIGN KEY(userId) REFERENCES users(id)
        );
        """

        if sqlite3_exec(db, createUserTable, nil, nil, nil) != SQLITE_OK {
            let errMsg = String(cString: sqlite3_errmsg(db))
            print("Erreur création table users: \(errMsg)")
        }

        if sqlite3_exec(db, createFavoriteTable, nil, nil, nil) != SQLITE_OK {
            let errMsg = String(cString: sqlite3_errmsg(db))
            print("Erreur création table favorites: \(errMsg)")
        }
    }

    func getDB() -> OpaquePointer? {
        db
    }
}

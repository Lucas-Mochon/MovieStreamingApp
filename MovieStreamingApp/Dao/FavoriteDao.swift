import Foundation
import SQLite3

final class FavoriteDAO {

    private let db = DatabaseManager.shared.getDB()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    let SQLITE_TRANSIENT = unsafeBitCast(
        -1,
        to: sqlite3_destructor_type.self
    )

    private let dateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    // MARK: - Insert

    func insert(_ favorite: Favorite) throws -> Favorite {
        let query = """
        INSERT INTO favorites (id, userId, movieId, movieData, addedAt)
        VALUES (?, ?, ?, ?, ?);
        """

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK else {
            throw SQLiteError.prepare(message: errMsg)
        }
        defer { sqlite3_finalize(stmt) }

        let movieData = try encoder.encode(favorite.movie)

        sqlite3_bind_text(stmt, 1, favorite.id, -1, SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 2, favorite.userId, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(stmt, 3, Int32(favorite.movieId))
        sqlite3_bind_blob(
            stmt,
            4,
            (movieData as NSData).bytes,
            Int32(movieData.count),
            SQLITE_TRANSIENT
        )
        sqlite3_bind_text(
            stmt,
            5,
            dateFormatter.string(from: favorite.addedAt),
            -1,
            SQLITE_TRANSIENT
        )

        guard sqlite3_step(stmt) == SQLITE_DONE else {
            throw SQLiteError.step(message: errMsg)
        }

        return favorite
    }

    // MARK: - Delete

    func delete(userId: String, movieId: Int) throws {
        let query = """
        DELETE FROM favorites
        WHERE userId = ? AND movieId = ?;
        """

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK else {
            throw SQLiteError.prepare(message: errMsg)
        }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (userId as NSString).utf8String, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(stmt, 2, Int32(movieId))

        guard sqlite3_step(stmt) == SQLITE_DONE else {
            throw SQLiteError.step(message: errMsg)
        }
    }

    // MARK: - Fetch

    func findAllByUserId(_ userId: String) throws -> [Favorite] {
        let query = """
        SELECT id, userId, movieId, movieData, addedAt
        FROM favorites
        WHERE userId = ?
        ORDER BY addedAt DESC;
        """

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK else {
            throw SQLiteError.prepare(message: errMsg)
        }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (userId as NSString).utf8String, -1, SQLITE_TRANSIENT)

        var favorites: [Favorite] = []

        while sqlite3_step(stmt) == SQLITE_ROW {
            favorites.append(try parseFavorite(stmt))
        }

        return favorites
    }

    // MARK: - Exists

    func exists(userId: String, movieId: Int) throws -> Bool {
        let query = """
        SELECT 1
        FROM favorites
        WHERE userId = ? AND movieId = ?
        LIMIT 1;
        """

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK else {
            throw SQLiteError.prepare(message: errMsg)
        }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (userId as NSString).utf8String, -1, SQLITE_TRANSIENT)
        sqlite3_bind_int(stmt, 2, Int32(movieId))

        return sqlite3_step(stmt) == SQLITE_ROW
    }

    // MARK: - Parser

    private func parseFavorite(_ stmt: OpaquePointer?) throws -> Favorite {
        guard let stmt else {
            throw SQLiteError.step(message: "Invalid statement")
        }

        let id = String(cString: sqlite3_column_text(stmt, 0))
        let userId = String(cString: sqlite3_column_text(stmt, 1))
        let movieId = Int(sqlite3_column_int(stmt, 2))
        let addedAtStr = String(cString: sqlite3_column_text(stmt, 4))
        let addedAt = dateFormatter.date(from: addedAtStr) ?? Date()

        guard let blob = sqlite3_column_blob(stmt, 3) else {
            throw SQLiteError.step(message: "Invalid movie data")
        }

        let size = Int(sqlite3_column_bytes(stmt, 3))
        let data = Data(bytes: blob, count: size)
        let movie = try decoder.decode(Movie.self, from: data)

        return Favorite(
            id: id,
            userId: userId,
            movieId: movieId,
            movie: movie,
            addedAt: addedAt
        )
    }

    // MARK: - Error

    private var errMsg: String {
        guard let db, let c = sqlite3_errmsg(db) else {
            return "Erreur SQLite inconnue"
        }
        return String(cString: c)
    }
}

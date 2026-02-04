enum SQLiteError: Error {
    case prepare(message: String)
    case step(message: String)
}

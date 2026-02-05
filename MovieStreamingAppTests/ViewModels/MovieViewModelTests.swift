import XCTest
@testable import MovieStreamingApp

@MainActor
final class MovieViewModelTests: XCTestCase {
    
    var viewModel: MovieViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = MovieViewModel()
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }
    
    func testInitialState() {
        XCTAssertEqual(viewModel.movies.count, 0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertTrue(viewModel.hasMorePages)
        XCTAssertEqual(viewModel.searchQuery, "")
    }
    
    func testDefaultSortOptions() {
        XCTAssertEqual(viewModel.selectedSortField, .popularity)
        XCTAssertEqual(viewModel.selectedSortOrder, .descending)
    }
    
    func testSelectedSortOption() {
        let expectedSort = SortOption(field: .popularity, order: .descending)
        XCTAssertEqual(viewModel.selectedSort.field, expectedSort.field)
        XCTAssertEqual(viewModel.selectedSort.order, expectedSort.order)
    }
    
    func testLoadInitialMovies() async {
        viewModel.currentPage = 5
        viewModel.hasMorePages = false
        viewModel.movies = [createTestMovie(id: 1)]
        
        await viewModel.loadInitialMovies()
        
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertTrue(viewModel.hasMorePages)
        XCTAssertEqual(viewModel.movies.count, 20)
    }
    
    func testLoadMoviesFirstPage() async {
        await viewModel.loadMovies()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertGreaterThan(viewModel.movies.count, 0)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadMoviesMultiplePages() async {
        await viewModel.loadMovies()
        let firstPageCount = viewModel.movies.count
        
        viewModel.currentPage = 2
        await viewModel.loadMovies()
        
        let secondPageCount = viewModel.movies.count
        XCTAssertGreaterThan(secondPageCount, firstPageCount)
    }
    
    func testLoadMoreMovies() async {
        await viewModel.loadInitialMovies()
        let initialCount = viewModel.movies.count
        
        await viewModel.loadMoreMovies()
        
        let newCount = viewModel.movies.count
        XCTAssertGreaterThanOrEqual(newCount, initialCount)
    }
    
    func testLoadMoreMoviesWhenNoMorePages() async {
        viewModel.hasMorePages = false
        viewModel.currentPage = 1
        
        await viewModel.loadMoreMovies()
        
        XCTAssertEqual(viewModel.currentPage, 1)
    }
    
    func testLoadMoreMoviesWhenLoading() async {
        viewModel.isLoading = true
        viewModel.currentPage = 1
        
        await viewModel.loadMoreMovies()
        
        XCTAssertEqual(viewModel.currentPage, 1)
    }
    
    func testLoadMoreMoviesWithSearchQuery() async {
        viewModel.searchQuery = "test"
        viewModel.currentPage = 1
        
        await viewModel.loadMoreMovies()
        
        XCTAssertEqual(viewModel.currentPage, 1)
    }
    
    func testSearchMovies() async {
        await viewModel.searchMovies(by: "Inception")
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertGreaterThan(viewModel.movies.count, 0)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.hasMorePages)
    }
    
    func testSearchMoviesEmpty() async {
        await viewModel.searchMovies(by: "")
        
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testSearchMoviesWhenLoading() async {
        viewModel.isLoading = true
        
        await viewModel.searchMovies(by: "test")
        
        XCTAssertTrue(viewModel.isLoading)
    }
    
    func testClearSearch() {
        viewModel.searchQuery = "Inception"
        XCTAssertEqual(viewModel.searchQuery, "Inception")
        
        viewModel.clearSearch()
        
        XCTAssertEqual(viewModel.searchQuery, "")
    }
    
    func testResetPagination() {
        viewModel.currentPage = 5
        viewModel.hasMorePages = false
        viewModel.movies = [createTestMovie(id: 1), createTestMovie(id: 2)]
        
        viewModel.resetPagination()
        
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertTrue(viewModel.hasMorePages)
        XCTAssertEqual(viewModel.movies.count, 0)
    }
    
    func testChangeSortField() async {
        await viewModel.loadInitialMovies()
        
        viewModel.selectedSortField = .rating
        
        XCTAssertEqual(viewModel.selectedSortField, .rating)
        XCTAssertEqual(viewModel.selectedSort.field, .rating)
    }
    
    func testChangeSortOrder() async {
        await viewModel.loadInitialMovies()
        
        viewModel.selectedSortOrder = .ascending
        
        XCTAssertEqual(viewModel.selectedSortOrder, .ascending)
        XCTAssertEqual(viewModel.selectedSort.order, .ascending)
    }
    
    func testErrorMessageCleared() async {
        viewModel.errorMessage = "Previous error"
        
        await viewModel.loadMovies()
        
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadingStateTrue() async {
        let task = Task {
            await viewModel.loadMovies()
        }
        
        await task.value
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testMoviesAppendOnSecondPage() async {
        await viewModel.loadInitialMovies()
        let firstPageMovies = viewModel.movies
        
        viewModel.currentPage = 2
        await viewModel.loadMovies()
        
        XCTAssertGreaterThan(viewModel.movies.count, firstPageMovies.count)
        let firstMovieStillThere = viewModel.movies.contains { $0.id == firstPageMovies.first?.id }
        XCTAssertTrue(firstMovieStillThere)
    }
    
    func testMoviesReplacedOnFirstPage() async {
        let testMovie = createTestMovie(id: 999)
        viewModel.movies = [testMovie]
        
        viewModel.currentPage = 1
        await viewModel.loadMovies()
        
        let testMovieStillThere = viewModel.movies.contains { $0.id == 999 }
        XCTAssertFalse(testMovieStillThere)
    }
    
    func testHasMorePagesCalculation() async {
        await viewModel.loadMovies()
        
        let hasMore = viewModel.hasMorePages
        XCTAssertTrue(hasMore)
    }
    
    func testSearchQueryDebounce() async {
        let expectation = XCTestExpectation(description: "Search debounce")
        
        viewModel.searchQuery = "I"
        viewModel.searchQuery = "In"
        viewModel.searchQuery = "Inc"
        viewModel.searchQuery = "Ince"
        viewModel.searchQuery = "Incep"
        viewModel.searchQuery = "Incepti"
        viewModel.searchQuery = "Inception"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testSortFieldAllCases() {
        let allFields = SortField.allCases
        XCTAssertGreaterThan(allFields.count, 0)
        XCTAssertTrue(allFields.contains(.popularity))
        XCTAssertTrue(allFields.contains(.rating))
        XCTAssertTrue(allFields.contains(.releaseDate))
        XCTAssertTrue(allFields.contains(.title))
    }
    
    func testSortOrderAllCases() {
        let allOrders = SortOrder.allCases
        XCTAssertEqual(allOrders.count, 2)
        XCTAssertTrue(allOrders.contains(.ascending))
        XCTAssertTrue(allOrders.contains(.descending))
    }
    
    func testSortOptionDisplay() {
        let sortOption = SortOption(field: .popularity, order: .descending)
        XCTAssertEqual(sortOption.displayName, "Popularité ↓")
    }
    
    func testSortOptionAPIValue() {
        let sortOption = SortOption(field: .rating, order: .ascending)
        XCTAssertEqual(sortOption.apiValue, "vote_average.asc")
    }
    
    func testPerformSearchEmpty() async {
        viewModel.movies = [createTestMovie(id: 1)]
        viewModel.currentPage = 5
        
        await viewModel.performSearch(text: "")
        
        XCTAssertEqual(viewModel.currentPage, 1)
    }
}

func createTestMovie(id: Int = 1) -> Movie {
    Movie(
        id: id,
        title: "Test Movie \(id)",
        overview: "Test overview",
        posterPath: "/test.jpg",
        backdropPath: nil,
        voteAverage: 8.0,
        releaseDate: "2024-01-01",
        popularity: 100.0
    )
}

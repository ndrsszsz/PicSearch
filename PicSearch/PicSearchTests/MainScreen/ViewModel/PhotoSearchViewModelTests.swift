//
//  Tests.swift
//  PicSearchTests
//
//  Created by Andras Szasz on 2025. 09. 29..
//

import XCTest
@testable import PicSearch

// MARK: Mock

class MockAPIService: APIService {
    var config: APIConfig = FlickrAPIConfig()
    var session: URLSession = .shared

    var photosToReturn: [FlickrPhoto] = []
    var shouldThrowError = false

    func searchPhotos(query: String, page: Int) async throws -> [FlickrPhoto] {
        if shouldThrowError {
            throw URLError(.badServerResponse)
        }
        return photosToReturn
    }
}

// MARK: Tests

@MainActor
class PhotoSearchViewModelTests: XCTestCase {

    var viewModel: PhotoSearchViewModel!
    var mockService: MockAPIService!

    override func setUp() {
        super.setUp()
        mockService = MockAPIService()
        viewModel = PhotoSearchViewModel(service: mockService, autoLoad: false)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "lastSearch")
        super.tearDown()
    }

    func testInitialQueryIsLoadedFromUserDefaults() async {
        UserDefaults.standard.setValue("cat", forKey: "lastSearch")
        let vm = PhotoSearchViewModel(service: mockService, autoLoad: false)
        XCTAssertEqual(vm.query, "cat")
    }

    func testSearchAddsPhotos() async {
        let photo1 = FlickrPhoto(id: "1", title: "Photo1", server: "1", secret: "", farm: 1)
        let photo2 = FlickrPhoto(id: "2", title: "Photo2", server: "1", secret: "", farm: 1)
        mockService.photosToReturn = [photo1, photo2]

        await viewModel.search(reset: true)

        XCTAssertEqual(viewModel.photos.count, 2)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.noResults)
    }

    func testSearchHandlesNoResults() async {
        mockService.photosToReturn = []

        await viewModel.search(reset: true)

        XCTAssertTrue(viewModel.noResults)
        XCTAssertEqual(viewModel.photos.count, 0)
    }

    func testSearchHandlesError() async {
        mockService.shouldThrowError = true

        await viewModel.search(reset: true)

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
}

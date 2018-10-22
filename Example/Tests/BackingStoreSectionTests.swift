import XCTest
import BackingStore

class TestDataSource: BackingStoreDataSource {
    
    var backingStoreView: BackingStoreView? = UITableView()
    
    func decorate(cell: UIView, at indexPath: IndexPath, animated: Bool) { }
}

class BackingStoreSectionTests: XCTestCase {
    
    func testMovedIndexPaths() {
        let expectation = XCTestExpectation(description: "BackingStoreUpdate")
        let dataSource = TestDataSource()
        let backingStore = BackingStore<TestSectionType>()
        backingStore.update(
            itemsForSections: [
                .one: ["a", "b", "c"],
                .two: []
            ],
            dataSource: dataSource,
            completion: {
                XCTAssertEqual(backingStore.sectionCount, 2)
                
                if let section = backingStore.section(at: 0) {
                    XCTAssertEqual(section.allItems.count, 3)
                    XCTAssertFalse(section.isEmpty)
                    XCTAssertEqual(section.type, .one)
                    XCTAssertEqual(section.itemCount, 3)
                } else {
                    XCTFail()
                }
                
                if let section = backingStore.section(at: 1) {
                    XCTAssertEqual(section.allItems.count, 0)
                    XCTAssert(section.isEmpty)
                    XCTAssertEqual(section.type, .two)
                    XCTAssertEqual(section.itemCount, 0)
                } else {
                    XCTFail()
                }
                
                XCTAssertNotNil(backingStore.section(for: .one))
                XCTAssertNotNil(backingStore.section(for: .two))
                XCTAssertNil(backingStore.section(for: .three))
                
                XCTAssertNotNil(backingStore.section(at: IndexPath(row: 0, section: 0)))
                XCTAssertNotNil(backingStore.section(at: IndexPath(row: 0, section: 1)))
                XCTAssertNil(backingStore.section(at: IndexPath(row: 0, section: 2)))
                
                expectation.fulfill()
            }
        )
        wait(for: [expectation], timeout: 1.0)
    }
}

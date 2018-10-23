import XCTest
import BackingStore

class TestDecorator: BackingStoreDecorator {
    
    func decorate(cell: UIView, at indexPath: IndexPath, animated: Bool) { }
}

class BackingStoreSectionTests: XCTestCase {
    
    let testDecorator = TestDecorator()
    let tableView = UITableView()
    let backingStore = BackingStore<TestSectionType>()
    
    override func setUp() {
        backingStore.view = tableView
        backingStore.decorator = testDecorator
    }
    
    func testMovedIndexPaths() {
        let expectation = XCTestExpectation(description: "BackingStoreUpdate")
        backingStore.update(
            itemsForSections: [
                .one: ["a", "b", "c"],
                .two: []
            ],
            completion: {
                XCTAssertEqual(self.backingStore.sectionCount, 2)
                
                if let section = self.backingStore.section(at: 0) {
                    XCTAssertEqual(section.allItems.count, 3)
                    XCTAssertFalse(section.isEmpty)
                    XCTAssertEqual(section.type, .one)
                    XCTAssertEqual(section.itemCount, 3)
                } else {
                    XCTFail()
                }
                
                if let section = self.backingStore.section(at: 1) {
                    XCTAssertEqual(section.allItems.count, 0)
                    XCTAssert(section.isEmpty)
                    XCTAssertEqual(section.type, .two)
                    XCTAssertEqual(section.itemCount, 0)
                } else {
                    XCTFail()
                }
                
                XCTAssertNotNil(self.backingStore.section(for: .one))
                XCTAssertNotNil(self.backingStore.section(for: .two))
                XCTAssertNil(self.backingStore.section(for: .three))
                
                XCTAssertNotNil(self.backingStore.section(at: IndexPath(row: 0, section: 0)))
                XCTAssertNotNil(self.backingStore.section(at: IndexPath(row: 0, section: 1)))
                XCTAssertNil(self.backingStore.section(at: IndexPath(row: 0, section: 2)))
                
                expectation.fulfill()
            }
        )
        wait(for: [expectation], timeout: 1.0)
    }
}

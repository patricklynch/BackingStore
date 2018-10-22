import XCTest
import BackingStore

enum TestSectionType: Int, Comparable {
    case one, two, three
}

class BackingStoreDiffTests: XCTestCase {
    
    func testMovedIndexPaths() {
        let oldValue: [TestSectionType: NSOrderedSet] = [
            .one: ["a", "b", "c"]
        ]
        let newValue: [TestSectionType: NSOrderedSet] = [
            .one: ["a", "c", "b"]
        ]
        guard let diff = BackingStoreDiff(from: oldValue, to: newValue) else {
            XCTFail("There should be a valid `BackingStoreDiff` if there are changes between `oldValue` and `newValue`")
            return
        }
        
        XCTAssertEqual(diff.movedIndexPaths.count, 2)
        XCTAssertEqual(diff.movedIndexPaths[0].origin, IndexPath(row: 2, section: 0))
        XCTAssertEqual(diff.movedIndexPaths[0].destination, IndexPath(row: 1, section: 0))
        XCTAssertEqual(diff.movedIndexPaths[1].origin, IndexPath(row: 1, section: 0))
        XCTAssertEqual(diff.movedIndexPaths[1].destination, IndexPath(row: 2, section: 0))
        
        XCTAssertEqual(diff.insertedIndexPaths.count, 0)
        XCTAssertEqual(diff.insertedSections.count, 0)
        XCTAssertEqual(diff.deletedIndexPaths.count, 0)
        XCTAssertEqual(diff.deletedSections.count, 0)
    }
    
    func testDeletedSections() {
        let oldValue: [TestSectionType: NSOrderedSet] = [
            .one: ["a", "b", "c"]
        ]
        let newValue: [TestSectionType: NSOrderedSet] = [:]
        guard let diff = BackingStoreDiff(from: oldValue, to: newValue) else {
            XCTFail("There should be a valid `BackingStoreDiff` if there are changes between `oldValue` and `newValue`")
            return
        }
        
        XCTAssertEqual(diff.deletedSections.count, 1)
        XCTAssertEqual(diff.deletedSections[0], 0)
        
        XCTAssertEqual(diff.insertedIndexPaths.count, 0)
        XCTAssertEqual(diff.insertedSections.count, 0)
        XCTAssertEqual(diff.deletedIndexPaths.count, 0)
        XCTAssertEqual(diff.movedIndexPaths.count, 0)
    }
    
    func testInsertedSections() {
        let oldValue: [TestSectionType: NSOrderedSet] = [:]
        let newValue: [TestSectionType: NSOrderedSet] = [
            .one: ["a", "b", "c"]
        ]
        guard let diff = BackingStoreDiff(from: oldValue, to: newValue) else {
            XCTFail("There should be a valid `BackingStoreDiff` if there are changes between `oldValue` and `newValue`")
            return
        }
        
        XCTAssertEqual(diff.insertedSections.count, 1)
        XCTAssertEqual(diff.insertedSections[0], 0)
        
        XCTAssertEqual(diff.insertedIndexPaths.count, 0)
        XCTAssertEqual(diff.deletedIndexPaths.count, 0)
        XCTAssertEqual(diff.deletedSections.count, 0)
        XCTAssertEqual(diff.movedIndexPaths.count, 0)
    }
    
    func testInsertedIndexPaths() {
        let oldValue: [TestSectionType: NSOrderedSet] = [
            .one: ["a", "b", "c"]
        ]
        let newValue: [TestSectionType: NSOrderedSet] = [
            .one: ["a", "b", "c", "d", "e"]
        ]
        guard let diff = BackingStoreDiff(from: oldValue, to: newValue) else {
            XCTFail("There should be a valid `BackingStoreDiff` if there are changes between `oldValue` and `newValue`")
            return
        }
        
        XCTAssertEqual(diff.insertedIndexPaths.count, 2)
        XCTAssertEqual(diff.insertedIndexPaths[0], IndexPath(row: 3, section: 0))
        XCTAssertEqual(diff.insertedIndexPaths[01], IndexPath(row: 4, section: 0))
        
        XCTAssertEqual(diff.deletedIndexPaths.count, 0)
        XCTAssertEqual(diff.insertedSections.count, 0)
        XCTAssertEqual(diff.deletedSections.count, 0)
        XCTAssertEqual(diff.movedIndexPaths.count, 0)
    }
    
    func testDeletedIndexPaths() {
        let oldValue: [TestSectionType: NSOrderedSet] = [
            .one: ["a", "b", "c"]
        ]
        let newValue: [TestSectionType: NSOrderedSet] = [
            .one: ["a", "b"]
        ]
        guard let diff = BackingStoreDiff(from: oldValue, to: newValue) else {
            XCTFail("There should be a valid `BackingStoreDiff` if there are changes between `oldValue` and `newValue`")
            return
        }
        
        XCTAssertEqual(diff.deletedIndexPaths.count, 1)
        XCTAssertEqual(diff.deletedIndexPaths[0], IndexPath(row: 2, section: 0))
        
        XCTAssertEqual(diff.insertedIndexPaths.count, 0)
        XCTAssertEqual(diff.insertedSections.count, 0)
        XCTAssertEqual(diff.deletedSections.count, 0)
        XCTAssertEqual(diff.movedIndexPaths.count, 0)
    }
    
    func testNoDiff() {
        let oldValue: [TestSectionType: NSOrderedSet] = [
            .one: ["a", "b", "c"]
        ]
        let newValue: [TestSectionType: NSOrderedSet] = [
            .one: ["a", "b", "c"]
        ]
        let diff = BackingStoreDiff(from: oldValue, to: newValue)
        XCTAssertNil(diff, "There should be no `BackingStoreDiff` created when there is no difference between `oldValue` and `newValue`")
    }
    
    func testPerformanceExample() {
        self.measure() {
            
        }
    }
}

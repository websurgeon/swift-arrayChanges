//
//  Copyright © 2018 Peter Barclay. All rights reserved.
//

import XCTest
import ArrayChanges

class DiffArraysTests: XCTestCase {
    
    func test_diffArray_delete() {
        assertChanges(from: [ createItem(1),
                              createItem(2),
                              createItem(3)],
                      to: [ createItem(1),
                            createItem(3)],
                      equals: [
                        .delete(index: 1)])
        
    }
    
    func test_diffArray_insert() {
        assertChanges(from: [ createItem(1),
                              createItem(2),
                              createItem(3)],
                      to: [ createItem(1),
                            createItem(2),
                            createItem(4),
                            createItem(3)],
                      equals: [.insert(index: 2)])
        
    }
    
    func test_diffArray_update() {
        assertChanges(from: [ createItem(1),
                              createItem(2, "a value"),
                              createItem(3)],
                      to: [ createItem(1),
                            createItem(2, "changed value"),
                            createItem(3)],
                      equals: [.update(oldIndex: 1, newIndex: 1)])
        
    }
    
    func test_diffArray_move() {
        assertChanges(from: [ createItem(1),
                              createItem(2),
                              createItem(3),
                              createItem(4) ],
                      to: [ createItem(1),
                            createItem(3),
                            createItem(2),
                            createItem(4)],
                      equals: [.move(from: 2, to: 1),
                               .move(from: 1, to: 2)])
    }
    
    func test_diffArray_multipleChanges() {
        assertChanges(from: [ createItem(1),
                              createItem(2),
                              createItem(3),
                              createItem(4) ],
                      to:  [ createItem(2),
                             createItem(5),
                             createItem(4, "a change"),
                             createItem(6),
                             createItem(3)],
                      equals: [ .delete(index: 0),
                                .insert(index: 1),
                                .insert(index: 3),
                                .update(oldIndex: 3, newIndex: 2),
                                .move(from: 3, to: 2),
                                .move(from: 2, to: 4)])
    }
    
    private func assertChanges(from: [CustomItem], to: [CustomItem], equals expected: [ArrayChange],
                               inFile: String = #file, atLine: Int = #line) {
        let changes = diffArrays(from: from, to: to,
                                 sameItems: { $0.id == $1.id },
                                 hasChanged: {
                                    !($0.id == $1.id &&
                                        $0.value == $1.value) })
        if changes != expected {
            recordFailure(withDescription: "expected \(expected), got \(changes)", inFile: inFile, atLine: atLine, expected: true)
        }
    }
    
}

extension ArrayChange: Equatable {
    public static func ==(lhs: ArrayChange, rhs: ArrayChange) -> Bool {
        switch (lhs, rhs) {
        case (let .delete(indexA), let .delete(indexB)): return indexA == indexB
        case (let .insert(indexA), let .insert(indexB)):  return indexA == indexB
        case (let .update(indexA), let .update(indexB)):  return indexA == indexB
        case (let .move(fromA, toA), let .move(fromB, toB)):  return fromA == fromB && toA == toB
        case (.delete, .insert), (.delete, update), (.delete, move),
             (.insert, .delete), (.insert, update), (.insert, move),
             (.update, .delete), (.update, insert), (.update, move),
             (.move, .delete), (.move, insert), (.move, update):
            return false
        }
    }
    
}

private func createItem(_ id: Int, _ value: String? = nil) -> CustomItem {
    return CustomItem(id: id, value: value ?? "")
}

struct CustomItem {
    let id: Int
    let value: String
}

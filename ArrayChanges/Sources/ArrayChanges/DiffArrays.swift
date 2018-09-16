//
//  Copyright © 2018 Peter Barclay. All rights reserved.
//

import Foundation

public func diffArrays<T>(from oldData: [T], to newData: [T],
                          sameItems: (_ a: T, _ b: T) -> Bool,
                          hasChanged: (_ a: T, _ b: T) -> Bool) -> [ArrayChange] {
    var inserted = [ArrayChange]()
    var deleted = [ArrayChange]()
    var moved = [ArrayChange]()
    var updated = [ArrayChange]()
    
    var adjOldData = oldData
    
    oldData.enumerated().forEach { (old) in
        if missingItem(old.element, in: newData, sameItems: sameItems) {
            adjOldData.remove(at: old.offset - deleted.count)
            deleted.append(.delete(index: old.offset))
        }
    }
    
    newData.enumerated().forEach { (new) in
        guard let oldIndex = index(of: new.element, in: oldData, sameItems: sameItems) else {
            adjOldData.insert(new.element, at: new.offset)
            inserted.append(.insert(index: new.offset))
            return
        }
        
        let item = adjOldData[new.offset]
        
        if hasChanged(oldData[oldIndex], new.element) {
            updated.append(.update(oldIndex: oldIndex, newIndex: new.offset))
        }
        
        if sameItems(item, new.element) {
            return
        }
        
        if oldIndex != new.offset {
            moved.append(.move(from: oldIndex, to: new.offset))
        }
        
    }
    
    return  deleted + inserted + updated + moved
}

public func diffArrays<T: Equatable>(from oldData: [T], to newData: [T],
                                     sameItems: (_ a: T, _ b: T) -> Bool) -> [ArrayChange] {
    return diffArrays(from: oldData, to: newData, sameItems: sameItems, hasChanged: { $0 != $1 })
}

private func index<T>(of item: T, in data: [T], sameItems: (_ a: T, _ b: T) -> Bool) -> Int? {
    return data.index(where: { (dataItem) -> Bool in
        return sameItems(dataItem, item)
    })
}

private func missingItem<T>(_ item: T, in data: [T], sameItems: (_ a: T, _ b: T) -> Bool) -> Bool {
    return index(of: item, in: data, sameItems: sameItems) == nil
}

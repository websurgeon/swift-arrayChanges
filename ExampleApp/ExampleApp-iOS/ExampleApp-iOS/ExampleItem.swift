//
//  Copyright © 2018 Peter Barclay. All rights reserved.
//

import Foundation

struct ExampleItem {
    let id: Int
    var value: String
    var changes: Int
}

extension ExampleItem: Equatable {
    static func ==(lhs: ExampleItem, rhs: ExampleItem) -> Bool {
        return lhs.id == rhs.id &&
            lhs.value == rhs.value &&
            lhs.changes == rhs.changes
    }
}

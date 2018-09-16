//
//  Copyright © 2018 Peter Barclay. All rights reserved.
//

import Foundation

public enum ArrayChange {
    case insert(index: Int)
    case delete(index: Int)
    case update(oldIndex: Int, newIndex: Int)
    case move(from: Int, to: Int)
}

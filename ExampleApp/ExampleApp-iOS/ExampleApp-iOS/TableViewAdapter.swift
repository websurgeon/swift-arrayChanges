//
//  Copyright © 2018 Peter Barclay. All rights reserved.
//

import UIKit
import ArrayChanges

typealias ItemProps = (id: Int, value: String, changes: Int)
typealias TableDataItem = ExampleItem
typealias TableData = [TableDataItem]

func createItem(_ id: Int,
                _ value: String,
                _ changes: Int) -> TableDataItem {
    return ExampleItem(id: id, value: value, changes: changes)
}

class TableViewAdapter: NSObject {
    var tableView: UITableView?
    var tableData = TableData()
    let initialItemCount = 10

    var initialData: TableData {
        return (0..<initialItemCount).map { i in
            return createItem(i, "item \(i)", 0)
        }
    }

    func setupTableView(_ tableView: UITableView) {
        self.tableView = tableView
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func resetData() {
        updateTableData(initialData)
    }
    
    func changeData() {
        updateTableData(updatedData)
    }
    
    var updatedData: TableData {
        var newData: TableData = tableData
        if (newData.count > 0) {
            if arc4random_uniform(2) == 0 {
                newData.remove(at: 0)
            }
        }
        if arc4random_uniform(2) == 0 {
            let maxId = newData.reduce(0) { (result, item) -> Int in
                return max(result, item.id)
            }
            let newItem = createItem(maxId + 1, "item \(maxId + 1)", 0)
            newData.append(newItem)
        }
        
        if newData.count > 0 {
            let updateIndex = Int(arc4random_uniform(UInt32(newData.count)))
            newData[updateIndex].changes += 1
        }
        return newData.sorted { _,_ in arc4random_uniform(2) == 0 }
    }
    
    func updateTableData(_ data: TableData) {
        let changes = diffArrays(from: tableData, to: data, sameItems: { (a, b) in
            return a.id == b.id
        }, hasChanged: { (a, b) in
            return !(a.id == b.id && a.changes == b.changes)
        })

        self.tableData = data
        animateDataChanges(changes)
    }
}

extension TableViewAdapter: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let item = tableData[indexPath.row]
        cell.textLabel?.text = "\(item.value) (\(item.changes))"
        return cell
    }
    
}

extension TableViewAdapter {
    
    func animateDataChanges(_ changes: [ArrayChange]) {
        tableView?.performBatchUpdates({
            changes.forEach { (change) in
                switch change {
                case let .insert(index):
                    tableView?.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                case let .delete(index):
                    tableView?.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                case .update:
                    return
                case let .move(from, to):
                    tableView?.moveRow(at: IndexPath(row: from, section: 0), to: IndexPath(row: to, section: 0))
                }
            }
        }) { done in
            changes.forEach { (change) in
                switch change {
                case .insert, .delete, .move:
                    return
                case let .update(_, newIndex):
                    if (done) {
                        self.tableView?.performBatchUpdates({
                            self.tableView?.reloadRows(at: [IndexPath(row: newIndex, section: 0)], with: .automatic)
                        })
                    } else {
                        self.tableView?.reloadRows(at: [IndexPath(row: newIndex, section: 0)], with: .automatic)
                    }
                }
            }
        }
    }

}

//
//  Copyright © 2018 Peter Barclay. All rights reserved.
//

import UIKit
import ArrayChanges

class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView?
    @IBOutlet var resetButton: UIBarButtonItem?
    @IBOutlet var updateButton: UIBarButtonItem?
    var adapter: TableViewAdapter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adapter = TableViewAdapter()
        if let tableView = tableView {
            adapter?.setupTableView(tableView)
        }
        resetData()
    }
    
    @IBAction func resetData() {
        adapter?.resetData()
    }
    
    @IBAction func updateData() {
        adapter?.changeData()
    }
    
}


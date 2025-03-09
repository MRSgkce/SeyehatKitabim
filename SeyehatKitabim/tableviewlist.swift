//
//  tableviewlist.swift
//  SeyehatKitabim
//
//  Created by Mürşide Gökçe on 9.03.2025.
//

import UIKit
class tableviewlist: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addNewItem))
    }
    
    @objc func addNewItem(){
        performSegue(withIdentifier: "todetailsVC", sender: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text="test"
        return cell
    }
    
}

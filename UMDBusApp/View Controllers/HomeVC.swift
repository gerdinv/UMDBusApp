//
//  HomeVC.swift
//  UMDBusApp
//
//  Created by Gerdin Ventura on 10/6/21.
//

import UIKit
import FloatingPanel

class HomeVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView: UITableView = {
        let tb = UITableView()
//        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.register(BusInformationCell.self, forCellReuseIdentifier: BusInformationCell.identifier)
        return tb
    }()
    
    let panel = FloatingPanelController()
    let searchVC = SearchVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 120
//        tableView.frame = view.bounds
        
        panel.set(contentViewController: searchVC)
        panel.move(to: .half, animated: false, completion: nil) //Moves screen down
        panel.addPanel(toParent: self)
        
    }
    
    private func setConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BusInformationCell.identifier, for: indexPath) as! BusInformationCell
        cell.busIdLabel.text = "BOB"
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

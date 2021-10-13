//
//  HomeVC.swift
//  UMDBusApp
//
//  Created by Gerdin Ventura on 10/6/21.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var button: UIButton!
    
    private let customView: UIView = {
        let view = UIView()
//        view.frame = CGRect(x: 150, y: 150, width: 250, height: 150)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        view.layer.cornerRadius = 50
        view.tag = 1
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        button.layer.cornerRadius = 50
        
        let tapGesture = UIPanGestureRecognizer(target: self, action: #selector(screenClicked(_:)))
        let gesture = UITapGestureRecognizer(target: self, action: #selector(viewClicked(_ :)))
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(gesture)
        
    }
    
    private func setConstraints() {
        var constraints = [NSLayoutConstraint]()
        constraints.append(customView.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(customView.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        constraints.append(customView.widthAnchor.constraint(equalToConstant: 350))
        constraints.append(customView.heightAnchor.constraint(equalToConstant: 250))
        NSLayoutConstraint.activate(constraints)
    }
    

    @IBAction func onClick(_ sender: Any) {
        print("CLICKED!")   
        view.addSubview(customView)
        setConstraints()
    }
    
    @objc private func screenClicked(_ gesture: UITapGestureRecognizer) {
        if let viewWithTag = self.view.viewWithTag(1) {
            viewWithTag.removeFromSuperview()
        }
        print("Screen clicked!")
        
    }
    
    @objc private func viewClicked(_ gesture: UITapGestureRecognizer) {
        print("Main view clicked")
        
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

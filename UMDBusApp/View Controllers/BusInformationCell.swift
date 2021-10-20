//
//  BusInformationCell.swift
//  UMDBusApp
//
//  Created by Gerdin Ventura on 10/14/21.
//

import UIKit

class BusInformationCell: UITableViewCell {
    static let identifier = "BusInformationCell"
    
    let busIdLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.label
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(busIdLabel)
        contentView.backgroundColor = .secondarySystemBackground
        setupConstraints()
    }
    
    func setupConstraints() {
        var constraints = [NSLayoutConstraint]()
        constraints.append(busIdLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10))
        constraints.append(busIdLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor))
        constraints.append(busIdLabel.topAnchor.constraint(equalTo: contentView.topAnchor))
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

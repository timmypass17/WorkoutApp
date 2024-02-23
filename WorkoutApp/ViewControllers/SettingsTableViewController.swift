//
//  SettingsTableViewController.swift
//  WorkoutApp
//
//  Created by Timmy Nguyen on 2/19/24.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    struct Section {
        var title: String
        var data: [Model]
    }
    
    struct Model {
        let image: UIImage?
        let text: String
        var secondary: String?
        let backgroundColor: UIColor?
        
        init(image: UIImage, text: String, secondary: String? = nil, backgroundColor: UIColor?) {
            self.image = image
            self.text = text
            self.secondary = secondary
            self.backgroundColor = backgroundColor
        }
    }
    
    var sections = [
        Section(title: "General",
                data: [Model(image: UIImage(systemName: "dumbbell.fill")!, text: "Weight Units", secondary: Settings.shared.weightUnit.description, backgroundColor: .accentColor),
                       Model(image: UIImage(systemName: "alarm.fill")!, text: "Show Timer", backgroundColor: .accentColor)]),
        Section(title: "Appearance",
                data: [Model(image: UIImage(systemName: "moon.stars.fill")!, text: "Theme", secondary: Settings.shared.theme.description, backgroundColor: .systemIndigo),
                       Model(image: UIImage(systemName: "paintpalette.fill")!, text: "Accent Color", backgroundColor: .systemOrange)]),
        Section(title: "Help & Support",
                data: [Model(image: UIImage(systemName: "mail.fill")!, text: "Contact Us", backgroundColor: .systemGreen),
                       Model(image: UIImage(systemName: "ladybug.fill")!, text: "Bug Report", backgroundColor: .systemRed)]),
        Section(title: "Privacy",
                data: [Model(image: UIImage(systemName: "hand.raised.fill")!, text: "Privacy Policy", backgroundColor: .systemGray)])
    ]
    
    static let weightIndexPath = IndexPath(row: 0, section: 0)
    static let timerIndexPath = IndexPath(row: 1, section: 0)
    static let themeIndexpath = IndexPath(row: 0, section: 1)
        
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsTableViewCell
        let model = sections[indexPath.section].data[indexPath.row]
        cell.update(with: model)
        if indexPath == SettingsTableViewController.timerIndexPath {
            cell.addToggleView()
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == SettingsTableViewController.weightIndexPath {
            let weightTableViewController = WeightTableViewController(style: .grouped)
            weightTableViewController.delegate = self
            navigationController?.pushViewController(weightTableViewController, animated: true)
        } else if indexPath == SettingsTableViewController.themeIndexpath {
            let themeTableViewController = ThemeTableViewController(style: .grouped)
            themeTableViewController.delegate = self
            navigationController?.pushViewController(themeTableViewController, animated: true)
        }
    }
}

extension SettingsTableViewController: WeightTableViewControllerDelegate {
    func weightTableViewController(_ viewController: WeightTableViewController, didSelectWeightType weightType: WeightType) {
        let weightIndexPath = SettingsTableViewController.weightIndexPath
        sections[weightIndexPath.section].data[weightIndexPath.row].secondary = weightType.description
        tableView.reloadRows(at: [weightIndexPath], with: .automatic)
    }
}

extension SettingsTableViewController: ThemeTableViewControllerDelegate {
    func themeTableViewController(_ controller: ThemeTableViewController, didSelectTheme theme: UIUserInterfaceStyle) {
        let themeIndexPath = SettingsTableViewController.themeIndexpath
        sections[themeIndexPath.section].data[themeIndexPath.row].secondary = theme.description
        tableView.reloadRows(at: [themeIndexPath], with: .automatic)
    }
}

class RoundedSquareImageView: UIImageView {
    
    init(systemName: String, backgroundColor: UIColor) {
        super.init(image: UIImage(systemName: systemName))
        self.backgroundColor = backgroundColor
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // Set corner radius to create a rounded square
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 1.0;
    }
}

/**
 2 Ways to to pass messages between objects
 1. Delegates (protocol)
 - used for 1 to 1 communication (phone call)
 - can communicate between one another
 2. Notification
 - 1 to many communication (radio station, multible people can listen)
 - Can only broadcast message, can't communication back and forth between listener (unless
 
 Reference: https://stackoverflow.com/questions/5325226/what-is-the-difference-between-delegate-and-notification
 */

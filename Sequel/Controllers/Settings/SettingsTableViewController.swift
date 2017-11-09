import Kingfisher
import MessageUI
import StoreKit
import UIKit

class SettingsTableViewController: UITableViewController {

    struct Section {
        let name: String
        let cells: [UITableViewCell]
    }

    struct Style {
        let backgroundColor: String
        let dividerColor: String
        let buttonColor: String
        let textColor: String
        let detailTextColor: String
        let headerTextColor: String

        static let light = Style(
            backgroundColor: Color.light.background,
            dividerColor: Color.light.blackDivider,
            buttonColor: Color.light.accentNormal,
            textColor: Color.light.blackPrimary,
            detailTextColor: Color.light.blackSecondary,
            headerTextColor: Color.light.blackSecondary
        )
    }

    var sections = [Section]()

    var lastScrollOffset: CGFloat = 0
    var initialModalOffset: CGFloat = 0

    var cacheSizeCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()

        initTitle()
        initDoneButton()
        initTableView()

        initStorageSection()
        initOtherSection()

        updateCacheSize()
    }

    override func viewWillAppear(_ animated: Bool) {
        if let navigationController = self.navigationController {
            initialModalOffset = navigationController.view.frame.origin.y
        }
    }

    /* Init */
    func initTitle() {
        let titleLabel = UILabel()
        titleLabel.text = "Settings"
        titleLabel.theme_textColor = [Color.light.blackSecondary]
        titleLabel.font = Font.title
        self.navigationItem.titleView = titleLabel
    }

    func initDoneButton() {
        let doneButton = ExtendedButton()
        doneButton.setTitle("Done", font: Font.body!)
        doneButton.setColors(colors: [Color.light.accentNormal], highlightColors: [Color.light.accentHighlighted])
        doneButton.addTarget(self, action: #selector(doneButtonTouchUpInside), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
    }

    func initTableView() {
        self.tableView.theme_backgroundColor = [Style.light.backgroundColor]
    }

    func initStorageSection() {
        var storageCells = [UITableViewCell]()

        cacheSizeCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cacheSizeCell.textLabel?.text = "Cache Size"
        cacheSizeCell.textLabel?.theme_textColor = [Style.light.textColor]
        cacheSizeCell.textLabel?.font = Font.body
        cacheSizeCell.detailTextLabel?.theme_textColor = [Style.light.detailTextColor]
        cacheSizeCell.detailTextLabel?.font = Font.body
        cacheSizeCell.selectionStyle = .none
        storageCells.append(cacheSizeCell)

        let clearCacheCell = UITableViewCell()
        clearCacheCell.textLabel?.text = "Remove Cache"
        clearCacheCell.textLabel?.theme_textColor = [Style.light.buttonColor]
        clearCacheCell.textLabel?.font = Font.body
        storageCells.append(clearCacheCell)

        sections.append(Section(name: "Storage", cells: storageCells))
    }

    func initOtherSection() {
        var otherCells = [UITableViewCell]()

        let aboutCell = UITableViewCell()
        aboutCell.textLabel?.text = "About"
        aboutCell.textLabel?.theme_textColor = [Style.light.textColor]
        aboutCell.textLabel?.font = Font.body
        aboutCell.accessoryType = .disclosureIndicator
        otherCells.append(aboutCell)

        let feedbackCell = UITableViewCell()
        feedbackCell.textLabel?.text = "Feedback"
        feedbackCell.textLabel?.theme_textColor = [Style.light.textColor]
        feedbackCell.textLabel?.font = Font.body
        feedbackCell.accessoryType = .disclosureIndicator
        otherCells.append(feedbackCell)

        let rateCell = UITableViewCell()
        rateCell.textLabel?.text = "Rate"
        rateCell.textLabel?.theme_textColor = [Style.light.textColor]
        rateCell.textLabel?.font = Font.body
        rateCell.accessoryType = .disclosureIndicator
        otherCells.append(rateCell)

        sections.append(Section(name: "Other", cells: otherCells))

    }

    /* Update */
    func updateCacheSize() {
        ImageCache.default.calculateDiskCacheSize { (size) in
            self.cacheSizeCell.detailTextLabel?.text = Humanize.fileSize(bytes: Int(size))
        }
    }

    /* DoneButton */
    @objc func doneButtonTouchUpInside(sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true)
    }

    /* TableView */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].name
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.theme_textColor = [Style.light.headerTextColor]
            header.textLabel?.font = Font.caption
            header.textLabel?.text = sections[section].name
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sections[indexPath.section].cells[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.isSelected = false
        }

        if indexPath.section == 0 && indexPath.row == 1 {
            clearCacheCellTouchUpInside()
        }

        if indexPath.section == 1 && indexPath.row == 0 {
            aboutCellTouchUpInside()
        }

        if indexPath.section == 1 && indexPath.row == 1 {
            feedbackCellTouchUpInside()
        }

        if indexPath.section == 1 && indexPath.row == 2 {
            rateCellTouchUpInside()
        }
    }

    /* TableView Events */
    func clearCacheCellTouchUpInside() {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to remove the cache?", preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Remove", style: .destructive) { (_) in
            ImageCache.default.clearDiskCache()
            self.updateCacheSize()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func aboutCellTouchUpInside() {
        let settingsAboutTableViewController = SettingsAboutTableViewController(style: .grouped)
        self.navigationController?.pushViewController(settingsAboutTableViewController, animated: true)
    }

    func feedbackCellTouchUpInside() {
        if MFMailComposeViewController.canSendMail() {
            let settingsFeedbackViewController = SettingsFeedbackViewController(nibName: nil, bundle: nil)
            self.present(settingsFeedbackViewController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Could not send feedback", message: "Your device could not send mails. Please check your mail configuration and try again.", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(okAction)

            self.present(alertController, animated: true, completion: nil)
        }
    }

    func rateCellTouchUpInside() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            if let path = Bundle.main.path(forResource: "Config", ofType: "plist") {
                if let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any] {
                    if let appId = dictionary["App ID"] {
                        if let url = URL(string: "itms-apps://itunes.apple.com/app/\(appId)") {
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
            }
        }
    }

    /* Scroll */
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let navigationController = self.navigationController {
            let navigationBarHeight = navigationController.navigationBar.frame.size.height
            let currentModalOffset = navigationController.view.frame.origin.y
            let currentModalScope = 4 as CGFloat

            if lastScrollOffset > scrollView.contentOffset.y {
                // Scroll down
                if scrollView.contentOffset.y <= -navigationBarHeight {
                    scrollView.contentOffset = CGPoint(x: 0, y: -navigationBarHeight)
                }
            } else {
                // Scroll up
                if initialModalOffset < currentModalOffset - currentModalScope {
                    scrollView.contentOffset = CGPoint(x: 0, y: -navigationBarHeight)
                }
            }
        }

        self.lastScrollOffset = scrollView.contentOffset.y
    }
}
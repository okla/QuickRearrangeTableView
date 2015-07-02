import UIKit

class ViewController: UIViewController, QuickRearrangeTableViewDataSource, UITableViewDelegate, UITableViewDataSource {

  var currentIndexPath: NSIndexPath?

  var cellTitles = ["0x15", "0x2", "0x3", "0x4", "0x5", "0x6", "0x7", "0x8", "0x9", "0xA", "0xB", "0xC",
    "0xD", "0xE", "0xF", "0x10", "0x11", "0x12", "0x13", "0x14", "0x1"]

  override func prefersStatusBarHidden() -> Bool {

    return true
  }

  override func viewDidLoad() {

    super.viewDidLoad()

    let tableView = QuickRearrangeTableView(frame: view.frame,
      options: QuickRearrangeTableViewOptions(hover: true, translucency: false))

    tableView.delegate = self
    tableView.dataSource = self
    tableView.rearrangeDataSource = self
    tableView.separatorInset = UIEdgeInsetsZero
    tableView.layoutMargins = UIEdgeInsetsZero
    tableView.backgroundColor = .grayColor()

    tableView.tableFooterView = UIView()

    tableView.rowHeight = tableView.frame.height/10.0

    view.addSubview(tableView)
  }

  // MARK: UITableViewDelegate

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

  // MARK: UITableViewDataSource

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    return cellTitles.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)

    if let unwrappedCurrentIndexPath = currentIndexPath where indexPath == unwrappedCurrentIndexPath {

      cell.backgroundColor = nil
    }
    else {

      cell.textLabel?.text = cellTitles[indexPath.row]
    }

    cell.separatorInset = UIEdgeInsetsZero
    cell.layoutMargins = UIEdgeInsetsZero

    return cell
  }

  // MARK: QuickRearrangeTableViewDataSource

  func moveObjectAtCurrentIndexPathToIndexPath(indexPath: NSIndexPath) {

    if let unwrappedCurrentIndexPath = currentIndexPath {

      let object = cellTitles[unwrappedCurrentIndexPath.row]

      cellTitles.removeAtIndex(unwrappedCurrentIndexPath.row)

      cellTitles.insert(object, atIndex: indexPath.row)
    }
  }
}
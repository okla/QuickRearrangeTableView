import UIKit

class ViewController: UIViewController {

  var currentIndexPath: IndexPath?

  var cellTitles = ["0x15", "0x2", "0x3", "0x4", "0x5", "0x6", "0x7", "0x8", "0x9", "0xA", "0xB",
                    "0xC", "0xD", "0xE", "0xF", "0x10", "0x11", "0x12", "0x13", "0x14", "0x1"]

  override var prefersStatusBarHidden : Bool {

    return true
  }

  override func viewDidLoad() {

    super.viewDidLoad()

    let tableView = TableView(frame: view.frame, style: .plain)

    tableView.delegate = self
    tableView.dataSource = self
    tableView.setRearrangeOptions([.hover, .translucency], dataSource: self)

    view.addSubview(tableView)
  }
}

extension ViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension ViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    return cellTitles.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

    if indexPath == currentIndexPath {

      cell.backgroundColor = nil
    }
    else {

      cell.textLabel?.text = cellTitles[indexPath.row]
    }

    cell.separatorInset = UIEdgeInsets.zero
    cell.layoutMargins = UIEdgeInsets.zero
    
    return cell
  }
}

extension ViewController: RearrangeDataSource {

  func moveObjectAtCurrentIndexPath(to indexPath: IndexPath) {

    guard let unwrappedCurrentIndexPath = currentIndexPath else { return }

    let object = cellTitles[unwrappedCurrentIndexPath.row]

    cellTitles.remove(at: unwrappedCurrentIndexPath.row)
    cellTitles.insert(object, at: indexPath.row)
  }
}

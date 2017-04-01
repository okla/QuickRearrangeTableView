import UIKit

class TableView: UITableView {

  var rearrange: RearrangeProperties!

  override init(frame: CGRect, style: UITableViewStyle) {

    super.init(frame: frame, style: style)

    tableFooterView = UIView()
    backgroundColor = .gray
    layoutMargins = UIEdgeInsets.zero
    separatorInset = UIEdgeInsets.zero

    rowHeight = frame.height/10.0
  }

  required init?(coder aDecoder: NSCoder) {

    fatalError("init(coder:) has not been implemented")
  }
}


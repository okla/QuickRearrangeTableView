import UIKit

protocol RearrangeDataSource: class {

  var currentIndexPath: IndexPath? { get set }

  func moveObjectAtCurrentIndexPath(to indexPath: IndexPath)
}

struct RearrangeOptions: OptionSet {

  let rawValue: Int

  init(rawValue: Int) { self.rawValue = rawValue }

  static let hover = RearrangeOptions(rawValue: 1)
  static let translucency = RearrangeOptions(rawValue: 2)
}

struct RearrangeProperties {

  let options: RearrangeOptions
  let displayLink: CADisplayLink
  let recognizer: UILongPressGestureRecognizer

  var catchedView: UIImageView?
  var scrollSpeed: CGFloat = 0.0

  weak var dataSource: RearrangeDataSource?

  init(options: RearrangeOptions, dataSource: RearrangeDataSource,
       recognizer: UILongPressGestureRecognizer, displayLink: CADisplayLink) {

    self.options = options
    self.dataSource = dataSource
    self.recognizer = recognizer
    self.displayLink = displayLink
  }
}

protocol Rearrangable {

  var rearrange: RearrangeProperties! { get set }
}

extension TableView: Rearrangable {

  func setRearrangeOptions(_ options: RearrangeOptions, dataSource: RearrangeDataSource) {

    rearrange = RearrangeProperties(options: options, dataSource: dataSource,
                                    recognizer: UILongPressGestureRecognizer(target: self, action: #selector(longPress)),
                                    displayLink: CADisplayLink(target: self, selector: #selector(scrollEvent)))

    rearrange.displayLink.add(to: .main, forMode: RunLoopMode.defaultRunLoopMode)
    rearrange.displayLink.isPaused = true

    addGestureRecognizer(rearrange.recognizer)
  }

  func scrollEvent() {

    contentOffset.y = min(max(0.0, contentOffset.y + rearrange.scrollSpeed), contentSize.height - frame.height)

    moveCatchedViewCenterToY(rearrange.recognizer.location(in: self).y)
  }

  fileprivate func moveCatchedViewCenterToY(_ y: CGFloat) {

    guard let catchedView = rearrange.catchedView else { return }

    catchedView.center.y = min(max(y, bounds.origin.y), bounds.origin.y + bounds.height)

    moveDummyRowIfNeeded()
  }

  fileprivate func moveDummyRowIfNeeded() {

    guard let source = rearrange.dataSource, let currentIndexPath = source.currentIndexPath,
      let catchedViewCenter = rearrange.catchedView?.center, let newIndexPath = indexPathForRow(at: catchedViewCenter), newIndexPath != currentIndexPath else { return }

    source.moveObjectAtCurrentIndexPath(to: newIndexPath)
    source.currentIndexPath = newIndexPath

    beginUpdates()
    deleteRows(at: [currentIndexPath], with: .top)
    insertRows(at: [newIndexPath], with: .top)
    endUpdates()
  }

  func longPress() {

    guard let source = rearrange.dataSource, !isEditing else { return }

    let location = rearrange.recognizer.location(in: self)

    switch rearrange.recognizer.state {

    case .began:

      source.currentIndexPath = indexPathForRow(at: location)

      guard let currentIndexPath = source.currentIndexPath,
        let catchedCell = cellForRow(at: currentIndexPath) else { return }

      allowsSelection = false

      catchedCell.isHighlighted = false

      let sizeWithoutSeparator = CGSize(width: catchedCell.bounds.size.width, height: catchedCell.bounds.size.height - 1.0)

      UIGraphicsBeginImageContextWithOptions(sizeWithoutSeparator, true, 0.0)

      guard let context = UIGraphicsGetCurrentContext() else { return }

      catchedCell.layer.render(in: context)

      rearrange.catchedView = UIImageView(image: UIGraphicsGetImageFromCurrentImageContext())

      UIGraphicsEndImageContext()

      rearrange.catchedView!.center = catchedCell.center

      addSubview(rearrange.catchedView!)

      rearrange.catchedView!.layer.shadowRadius = 4.0
      rearrange.catchedView!.layer.shadowOpacity = 0.25
      rearrange.catchedView!.layer.shadowOffset = CGSize.zero
      rearrange.catchedView!.layer.shadowPath = UIBezierPath(rect: rearrange.catchedView!.bounds).cgPath

      UIView.animate(withDuration: 0.2, animations: { [unowned self] in

        if self.rearrange.options.contains(.translucency) { self.rearrange.catchedView!.alpha = 0.5 }

        if self.rearrange.options.contains(.hover) {

          self.rearrange.catchedView!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }

        self.moveCatchedViewCenterToY(location.y)
      }) 

      reloadRows(at: [currentIndexPath], with: .none)

    case .changed:

      guard let catchedView = rearrange.catchedView else { return }

      moveCatchedViewCenterToY(location.y)

      rearrange.scrollSpeed = 0.0

      if contentSize.height > frame.height {

        let halfCellHeight = 0.5*catchedView.frame.height
        let cellCenterY = catchedView.center.y - bounds.origin.y

        if cellCenterY < halfCellHeight {

          rearrange.scrollSpeed = 5.0*(cellCenterY/halfCellHeight - 1.1)
        }
        else if cellCenterY > frame.height - halfCellHeight {

          rearrange.scrollSpeed = 5.0*((cellCenterY - frame.height)/halfCellHeight + 1.1)
        }

        rearrange.displayLink.isPaused = rearrange.scrollSpeed == 0.0
      }

    default:

      allowsSelection = true

      rearrange.displayLink.isPaused = true

      guard let currentIndexPath = source.currentIndexPath, let catchedView = rearrange.catchedView else { return }

      source.currentIndexPath = nil

      UIView.animate(withDuration: 0.2, animations: { [unowned self] in

        if self.rearrange.options.contains(.translucency) { catchedView.alpha = 1.0 }
        if self.rearrange.options.contains(.hover) { catchedView.transform = CGAffineTransform.identity }

        catchedView.frame = self.rectForRow(at: currentIndexPath)

      }, completion: { [unowned self] _ in

        catchedView.layer.shadowOpacity = 0.0
        
        UIView.animate(withDuration: 0.1, animations: {
          
          self.reloadData()
          self.layer.add(CATransition(), forKey: "reload")
          
        }, completion: { _ in
          
          catchedView.removeFromSuperview()
          
          self.rearrange.catchedView = nil
        }) 
      }) 
    }
  }
}

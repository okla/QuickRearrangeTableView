import UIKit

protocol RearrangeDataSource: class {

  var currentIndexPath: NSIndexPath? { get set }

  func moveObjectAtCurrentIndexPath(to indexPath: NSIndexPath)
}

struct RearrangeOptions: OptionSetType {

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

  func setRearrangeOptions(options: RearrangeOptions, dataSource: RearrangeDataSource) {

    rearrange = RearrangeProperties(options: options, dataSource: dataSource,
                                    recognizer: UILongPressGestureRecognizer(target: self, action: #selector(longPress)),
                                    displayLink: CADisplayLink(target: self, selector: #selector(scrollEvent)))

    rearrange.displayLink.addToRunLoop(.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    rearrange.displayLink.paused = true

    addGestureRecognizer(rearrange.recognizer)
  }

  func scrollEvent() {

    contentOffset.y = min(max(0.0, contentOffset.y + rearrange.scrollSpeed), contentSize.height - frame.height)

    moveCatchedViewCenterToY(rearrange.recognizer.locationInView(self).y)
  }

  private func moveCatchedViewCenterToY(y: CGFloat) {

    guard let catchedView = rearrange.catchedView else { return }

    catchedView.center.y = min(max(y, bounds.origin.y), bounds.origin.y + bounds.height)

    moveDummyRowIfNeeded()
  }

  private func moveDummyRowIfNeeded() {

    guard let source = rearrange.dataSource, currentIndexPath = source.currentIndexPath,
      catchedViewCenter = rearrange.catchedView?.center, newIndexPath = indexPathForRowAtPoint(catchedViewCenter)
      where newIndexPath != currentIndexPath else { return }

    source.moveObjectAtCurrentIndexPath(to: newIndexPath)
    source.currentIndexPath = newIndexPath

    beginUpdates()
    deleteRowsAtIndexPaths([currentIndexPath], withRowAnimation: .Top)
    insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Top)
    endUpdates()
  }

  func longPress() {

    guard let source = rearrange.dataSource where !editing else { return }

    let location = rearrange.recognizer.locationInView(self)

    switch rearrange.recognizer.state {

    case .Began:

      source.currentIndexPath = indexPathForRowAtPoint(location)

      guard let currentIndexPath = source.currentIndexPath,
        catchedCell = cellForRowAtIndexPath(currentIndexPath) else { return }

      allowsSelection = false

      catchedCell.highlighted = false

      let sizeWithoutSeparator = CGSizeMake(catchedCell.bounds.size.width, catchedCell.bounds.size.height - 1.0)

      UIGraphicsBeginImageContextWithOptions(sizeWithoutSeparator, true, 0.0)

      guard let context = UIGraphicsGetCurrentContext() else { return }

      catchedCell.layer.renderInContext(context)

      rearrange.catchedView = UIImageView(image: UIGraphicsGetImageFromCurrentImageContext())

      UIGraphicsEndImageContext()

      rearrange.catchedView!.center = catchedCell.center

      addSubview(rearrange.catchedView!)

      rearrange.catchedView!.layer.shadowRadius = 4.0
      rearrange.catchedView!.layer.shadowOpacity = 0.25
      rearrange.catchedView!.layer.shadowOffset = CGSizeZero
      rearrange.catchedView!.layer.shadowPath = UIBezierPath(rect: rearrange.catchedView!.bounds).CGPath

      UIView.animateWithDuration(0.2) { [unowned self] in

        if self.rearrange.options.contains(.translucency) { self.rearrange.catchedView!.alpha = 0.5 }

        if self.rearrange.options.contains(.hover) {

          self.rearrange.catchedView!.transform = CGAffineTransformMakeScale(1.05, 1.05)
        }

        self.moveCatchedViewCenterToY(location.y)
      }

      reloadRowsAtIndexPaths([currentIndexPath], withRowAnimation: .None)

    case .Changed:

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

        rearrange.displayLink.paused = rearrange.scrollSpeed == 0.0
      }

    default:

      allowsSelection = true

      rearrange.displayLink.paused = true

      guard let currentIndexPath = source.currentIndexPath, catchedView = rearrange.catchedView else { return }

      source.currentIndexPath = nil

      UIView.animateWithDuration(0.2, animations: { [unowned self] in

        if self.rearrange.options.contains(.translucency) { catchedView.alpha = 1.0 }
        if self.rearrange.options.contains(.hover) { catchedView.transform = CGAffineTransformIdentity }

        catchedView.frame = self.rectForRowAtIndexPath(currentIndexPath)

      }) { [unowned self] _ in

        catchedView.layer.shadowOpacity = 0.0
        
        UIView.animateWithDuration(0.1, animations: {
          
          self.reloadData()
          self.layer.addAnimation(CATransition(), forKey: "reload")
          
        }) { _ in
          
          catchedView.removeFromSuperview()
          
          self.rearrange.catchedView = nil
        }
      }
    }
  }
}

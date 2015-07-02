import UIKit

@objc protocol QuickRearrangeTableViewDataSource {

  var currentIndexPath: NSIndexPath? { get set }

  func moveObjectAtCurrentIndexPathToIndexPath(indexPath: NSIndexPath)
}

struct QuickRearrangeTableViewOptions {

  let hover: Bool
  let translucency: Bool
}

class QuickRearrangeTableView: UITableView {

  weak var rearrangeDataSource: QuickRearrangeTableViewDataSource?

  private var displayLink: CADisplayLink!
  private var recognizer: UILongPressGestureRecognizer!

  private var catchedCellView: UIImageView?

  private var scrollSpeed: CGFloat = 0.0

  private let options: QuickRearrangeTableViewOptions

  init(frame: CGRect, options: QuickRearrangeTableViewOptions) {

    self.options = options

    super.init(frame: frame, style: .Plain)

    displayLink = CADisplayLink(target: self, selector: "scrollEvent")

    displayLink.addToRunLoop(.mainRunLoop(), forMode: NSDefaultRunLoopMode)

    displayLink.paused = true

    recognizer = UILongPressGestureRecognizer(target: self, action: "longPress")

    addGestureRecognizer(recognizer)
  }

  required init(coder aDecoder: NSCoder) {

    fatalError("init(coder:) has not been implemented")
  }

  @objc private func longPress() {

    if let source = rearrangeDataSource where !editing {

      let location = recognizer.locationInView(self)

      switch recognizer.state {

      case .Began:

        source.currentIndexPath = indexPathForRowAtPoint(location)

        if let currentIndexPath = source.currentIndexPath, catchedCell = cellForRowAtIndexPath(currentIndexPath) {

          allowsSelection = false

          catchedCell.highlighted = false

          var sizeWithoutSeparator = catchedCell.bounds.size

          sizeWithoutSeparator.height -= 1.0

          UIGraphicsBeginImageContextWithOptions(sizeWithoutSeparator, true, 0.0)

          catchedCell.layer.renderInContext(UIGraphicsGetCurrentContext())

          catchedCellView = UIImageView(image: UIGraphicsGetImageFromCurrentImageContext())

          UIGraphicsEndImageContext()

          catchedCellView!.center = catchedCell.center

          addSubview(catchedCellView!)

          catchedCellView!.layer.shadowOffset = CGSizeZero

          catchedCellView!.layer.shadowRadius = 4.0

          catchedCellView!.layer.shadowOpacity = 0.25

          catchedCellView!.layer.shadowPath = UIBezierPath(rect: catchedCellView!.bounds).CGPath

          UIView.animateWithDuration(0.2) {

            if self.options.hover { self.catchedCellView!.transform = CGAffineTransformMakeScale(1.05, 1.05) }

            if self.options.translucency { self.catchedCellView!.alpha = 0.5 }

            self.moveCatchedCellViewCenterToY(location.y)
          }

          reloadRowsAtIndexPaths([currentIndexPath], withRowAnimation: .None)
        }

      case .Changed:

        if let unwrappedCatchedCellView = catchedCellView {

          moveCatchedCellViewCenterToY(location.y)

          scrollSpeed = 0.0

          if contentSize.height > frame.height {

            let halfCellHeight = 0.5*unwrappedCatchedCellView.frame.height
            let cellCenterY = unwrappedCatchedCellView.center.y - bounds.origin.y

            if cellCenterY < halfCellHeight {

              scrollSpeed = 5.0*(cellCenterY/halfCellHeight - 1.1)
            }
            else if cellCenterY > frame.height - halfCellHeight {

              scrollSpeed = 5.0*((cellCenterY - frame.height)/halfCellHeight + 1.1)
            }

            displayLink.paused = scrollSpeed == 0.0
          }
        }

      default:

        allowsSelection = true

        displayLink.paused = true

        if let currentIndexPath = source.currentIndexPath, unwrappedCatchedCellView = catchedCellView {

          source.currentIndexPath = nil

          UIView.animateWithDuration(0.2, animations: {

            if self.options.hover { unwrappedCatchedCellView.transform = CGAffineTransformIdentity }

            if self.options.translucency { unwrappedCatchedCellView.alpha = 1.0 }

            unwrappedCatchedCellView.frame = self.rectForRowAtIndexPath(currentIndexPath)

          }) { _ in

            unwrappedCatchedCellView.layer.shadowOpacity = 0.0

            UIView.animateWithDuration(0.1, animations: {

              self.reloadData()

              self.layer.addAnimation(CATransition(), forKey: "reload")

            }) { _ in

              unwrappedCatchedCellView.removeFromSuperview()

              self.catchedCellView = nil
            }
          }
        }
      }
    }
  }

  @objc private func scrollEvent() {

    contentOffset.y = min(max(0.0, contentOffset.y + scrollSpeed), contentSize.height - frame.height)

    moveCatchedCellViewCenterToY(recognizer.locationInView(self).y)
  }

  private func moveCatchedCellViewCenterToY(y: CGFloat) {

    if let unwrappedCatchedCellView = catchedCellView {

      unwrappedCatchedCellView.center.y = min(max(y, bounds.origin.y), bounds.origin.y + bounds.height)

      moveDummyRowIfNeeded()
    }
  }

  private func moveDummyRowIfNeeded() {

    if let source = rearrangeDataSource, currentIndexPath = source.currentIndexPath,
      catchedCellViewCenter = catchedCellView?.center, newIndexPath = indexPathForRowAtPoint(catchedCellViewCenter)
        where newIndexPath != currentIndexPath {

          source.moveObjectAtCurrentIndexPathToIndexPath(newIndexPath)

          source.currentIndexPath = newIndexPath
          
          beginUpdates()
          
          deleteRowsAtIndexPaths([currentIndexPath], withRowAnimation: .Top)
          insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Top)
          
          endUpdates()
    }
  }
}
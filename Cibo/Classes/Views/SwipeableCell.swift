//
//  SwipeableCell.swift
//  SwipeableCell
//
//  Created by John Nguyen on 20/08/16.
//  Copyright © 2016 John Nguyen. All rights reserved.
//
//	=====================================================================
//	To use this class, construct the cell in IB as a prototype cell:
//		
//	1) Drag 3 buttons and constrain them to the right of the content view.
//	   Note, button1 should be on the right, button3 on the left, button 2 in
//	   the middle.
//	2) Drag a UIView over the top to conceal the buttons and constrain to the
//	   exact size of the content view. This will be the new content view.
//	3) Drag a label into the new content view. Additional views must be
//	   subviews of the new content view. Constrain to this view.
//	4) Connect all the outlets and actions, implement the delegate methods.
//	   Note: set delegate in tableView(cellForRow). Use didOpen/didClose
//	   delegate methods to keep track of indexPaths of open & closed cells,
//	   since reused cells will always be closed.



import UIKit

// DELEGATE PROTOCOL
//
protocol SwipeableCellDelegate: class {
	
	func button1ActionForCell(cell: SwipeableCell)
	func button2ActionForCell(cell: SwipeableCell)
	func button3ActionForCell(cell: SwipeableCell)
	func cellShouldPan(cell: SwipeableCell) -> Bool
	func cellIsPanning(cell: SwipeableCell)
	func cellWillOpen(cell: SwipeableCell)
	func cellDidOpen(cell: SwipeableCell)
	func cellDidClose(cell: SwipeableCell)
}

// SWIPEABLE CELL
//
class SwipeableCell: UITableViewCell {
	
	// MARK: - OUTLETS & PROPERTIES
	// ============================================================
	
	weak var delegate: SwipeableCellDelegate?
	
	@IBOutlet weak var myContentView: UIView!
	@IBOutlet weak var mainTextLabel: UILabel!
	@IBOutlet weak var subTextLabel: UILabel!
	@IBOutlet weak var rightDetailLabel: UILabel!
	@IBOutlet weak var button1: UIButton!
	@IBOutlet weak var button2: UIButton!
	@IBOutlet weak var button3: UIButton!
	
	// adjusting these constraints moves content view horizontally.
	// a +ve value for right constraint & equal -ve value for left
	@IBOutlet weak var contentViewRightConstraint: NSLayoutConstraint!
	@IBOutlet weak var contentViewLeftConstraint: NSLayoutConstraint!
	
	// recognizer handles swipe gestures
	var panRecognizer: UIPanGestureRecognizer!
	var panStartPoint: CGPoint = CGPoint.zero
	var startingRightLayoutConstraintConstant: CGFloat = 0
	let kBounceValue: CGFloat = 20
	let animationDuration = 0.2
	
	// width of button area
	var buttonTotalWidth: CGFloat {
		return CGRectGetWidth(contentView.frame) - CGRectGetMinX(button3.frame)
	}
	// past this point, cell will snap to open
	lazy var openOnReleaseThreshold: CGFloat =  {
		// middle of 1st button (from right edge to half width button1)
		return CGRectGetWidth(self.button1.frame)/2
	}()
	
	// past this point, cell will snap to close
	lazy var closeOnReleaseThreshold: CGFloat = {
		let button1Width = CGRectGetWidth(self.button1.frame)
		let button2Width = CGRectGetWidth(self.button2.frame)
		let button3Width = CGRectGetWidth(self.button3.frame)
		// middle of 3rd button
		return button1Width + button2Width + button3Width/2
	}()
	
	// MARK: - STANDARD
	// ============================================================
	
	// AWAKE FROM NIB
	//
    override func awakeFromNib() {
        super.awakeFromNib()
		// set up gesture recognizer
		panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SwipeableCell.panThisCell(_:)))
		panRecognizer.delegate = self
		myContentView.addGestureRecognizer(panRecognizer)
    }
	
	// SET SELECTED
	//
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	// PREPARE FOR REUSE
	// ------------------------------------------------------------
	// Close the cell before it is re-used by table view
	//
	override func prepareForReuse() {
		super.prepareForReuse()
		resetConstraintConstantsToZero(animated: false, notifyDelegateDidClose: false)
	}
	
	// GESTURE RECOGNIZER ALLOW SIMULTANEOUS RECOGNIZERS
	// ------------------------------------------------------------
	// Returning true allows pan recognizer to work simultaneously
	// with other tableView recognizer
	//
	override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
	
	// MARK: - HELPERS
	// ============================================================
	
	// PAN THIS CELL
	// ------------------------------------------------------------
	// Parse pan recognizer data to handle cell layout
	//
	func panThisCell(recognizer: UIPanGestureRecognizer) {
		
		switch recognizer.state {
		
		case .Began:
			// store pan start point to determine direction of pan
			panStartPoint = recognizer.translationInView(myContentView)
			// store initial pos of cell to determine if opening or closing
			startingRightLayoutConstraintConstant = contentViewRightConstraint.constant
			
			
		case .Changed:
			// pan only if allowed to
			if delegate != nil && delegate!.cellShouldPan(self) {
				// pan amount (left drag: -ve, right: +ve)
				let currentPoint = recognizer.translationInView(myContentView)
				let deltaX = currentPoint.x - panStartPoint.x
				
				// direction of pan
				let panningLeft = currentPoint.x < panStartPoint.x
				
				
				// the cell was closed and is now opening
				if startingRightLayoutConstraintConstant == 0 {
					// panning right (potentially reclosing from left pan)
					if !panningLeft {
						// if starting with right pan, deltaX will be +ve. So we
						// invert and take max -> consant will be 0 (no shift).
						// if panned left & then right (without lifting finger)
						// deltaX will be -ve -> constant will be > 0 (shift)
						let constant: CGFloat = max(-deltaX, 0)
						// in closed pos
						if constant == 0 {
							// close cell
							resetConstraintConstantsToZero(animated: true, notifyDelegateDidClose: false)
						} else {
							// set cell shift
							contentViewRightConstraint.constant = constant
						}
					}
						// panning left
					else {
						
						delegate!.cellIsPanning(self)
						
						// deltaX is -ve, we take lesser of two (button width
						// indicates the upper bound to shift cell left).
						let constant: CGFloat = min(-deltaX, buttonTotalWidth)
						// fully opened pos
						if constant == buttonTotalWidth {
							// open cell
							setConstraintsToShowAllButtons(animated: true, notifyDelegateDidOpen: false)
						} else {
							// set cell shift
							contentViewRightConstraint.constant = constant
						}
					}
				}
				// the cell was at least partially open
				else {
					
					delegate!.cellIsPanning(self)
					
					// how much of an adjustment was made from original position
					let adjustment: CGFloat = startingRightLayoutConstraintConstant - deltaX
					
					// panning right
					if !panningLeft {
						let constant: CGFloat = max(adjustment, 0)
						if constant == 0 {
							resetConstraintConstantsToZero(animated: true, notifyDelegateDidClose: false)
						} else {
							contentViewRightConstraint.constant = constant
						}
					}
					// panning left
					else {
						let constant: CGFloat = min(adjustment, buttonTotalWidth)
						if constant == buttonTotalWidth {
							setConstraintsToShowAllButtons(animated: true, notifyDelegateDidOpen: false)
						} else {
							contentViewRightConstraint.constant = constant
						}
					}
				}
				
				// left constant is equal but inverse right constant
				contentViewLeftConstraint.constant = -contentViewRightConstraint.constant
				let scale = contentViewRightConstraint.constant / buttonTotalWidth
				button1.titleLabel?.alpha = scale
			}
			
			
		case .Ended:
			// cell was opening
			if startingRightLayoutConstraintConstant == 0 {
				// if panned past threshold
				if contentViewRightConstraint.constant >= openOnReleaseThreshold {
					// open all the way
					delegate?.cellWillOpen(self)
					setConstraintsToShowAllButtons(animated: true, notifyDelegateDidOpen: true)
				} else {
					// reclose
					resetConstraintConstantsToZero(animated: true, notifyDelegateDidClose: true)
				}
			}
			// cell was closing
			else {
				// did not panned past threshold
				if contentViewRightConstraint.constant >= closeOnReleaseThreshold {
					// reopen
					setConstraintsToShowAllButtons(animated: true, notifyDelegateDidOpen: true)
				} else {
					// close
					resetConstraintConstantsToZero(animated: true, notifyDelegateDidClose: true)
				}
			}
			
		case .Cancelled:
			// cell was closed
			if startingRightLayoutConstraintConstant == 0 {
				// reset everything to 0
				resetConstraintConstantsToZero(animated: true, notifyDelegateDidClose: true)
			}
			// cell was open
			else {
				// reset to the open state
				setConstraintsToShowAllButtons(animated: true, notifyDelegateDidOpen: true)
			}
			
		default:
			print("Unhandled recognizer state: \(recognizer.state)")
		}
	}

	
	// SET CONSTRAINTS TO SHOW ALL BUTTONS
	// ------------------------------------------------------------
	// Reveal buttons with bounce animation
	//
	func setConstraintsToShowAllButtons(animated animated: Bool, notifyDelegateDidOpen notifyDelegate: Bool) {
		
		if notifyDelegate {
			delegate?.cellDidOpen(self)
		}
		// cell is already in fully open state
		if startingRightLayoutConstraintConstant == buttonTotalWidth &&
			contentViewRightConstraint.constant == buttonTotalWidth {
			return
		}
		// set cell slightly to left (bounce value) of final resting pos
		contentViewLeftConstraint.constant = -buttonTotalWidth - kBounceValue
		contentViewRightConstraint.constant = buttonTotalWidth + kBounceValue
		
		self.animateButtons()
		
		// trigger animation to update frames
		updateConstraintsIfNeeded(animated) { _ in
			// set cell to final resting pos
			self.contentViewLeftConstraint.constant = -self.buttonTotalWidth
			self.contentViewRightConstraint.constant = self.buttonTotalWidth
			// trigger animation
			self.updateConstraintsIfNeeded(animated) { _ in
				// update "starting" pos
				self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant
			}
		}
	}
	
	// RESET CONSTRAINT CONSTANTS TO ZERO
	// ------------------------------------------------------------
	// Cover buttons with bounce animation
	//
	func resetConstraintConstantsToZero(animated animated: Bool, notifyDelegateDidClose notifyDelegate: Bool) {
		// already all the way closed, no bounce needed
		if startingRightLayoutConstraintConstant == 0 &&
			contentViewRightConstraint.constant == 0 {
			return
		}
		// set cell slightly to right of close position
		contentViewRightConstraint.constant = -kBounceValue
		contentViewLeftConstraint.constant = kBounceValue
		// trigger animation
		updateConstraintsIfNeeded(animated) { _ in
			// set cell exactly at close position
			self.contentViewRightConstraint.constant = 0
			self.contentViewLeftConstraint.constant = 0
			// trigger animation
			self.updateConstraintsIfNeeded(animated) { _ in
				// update "starting" position
				self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant
				// notify delegate when ani complete
				if notifyDelegate {
					self.delegate?.cellDidClose(self)
				}
			}
		}
	}
	
	// UPDATE CONSTRAINTS IF NEEDED
	// ------------------------------------------------------------
	// Snaps cell into position (per constaints) with animation.
	//
	func updateConstraintsIfNeeded(animated: Bool, completion: (finished: Bool) -> ()) {
		
		let duration = animated ? animationDuration : 0.0
		UIView.animateWithDuration(duration,
		                           delay: 0,
		                           options: UIViewAnimationOptions.CurveEaseOut,
		                           animations: {self.layoutIfNeeded()},
		                           completion: completion)
	}
	
	func animateButtons() {
		
		UIView.animateWithDuration(animationDuration,
		                           delay: 0,
		                           options: UIViewAnimationOptions.CurveEaseOut,
		                           animations: {
									self.button1.titleLabel?.alpha = 1.0
									
			},
		                           completion: nil)
	}
	
	// OPEN CELL (no animation)
	//
	func openCell() {
		setConstraintsToShowAllButtons(animated: false,
		                               notifyDelegateDidOpen: true)
	}
	
	
	
	// MARK: - ACTIONS
	// ============================================================
	
	// BUTTON TAPPED
	// ------------------------------------------------------------
	// Send delegate messages depending on button
	//
	@IBAction func buttonTapped(button: UIButton) {
		switch button {
		case button1:
			delegate?.button1ActionForCell(self)
		case button2:
			delegate?.button2ActionForCell(self)
		case button3:
			delegate?.button3ActionForCell(self)
		default:
			print("Swipeable Cell: Unknown button tapped!")
		}
	}

}







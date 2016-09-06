//
//  MealSectionHeaderView.swift
//  Cibo
//
//  Created by John Nguyen on 01/09/16.
//  Copyright © 2016 John Nguyen. All rights reserved.
//

import UIKit

protocol MealSectionHeaderViewDelegate: class {
	func headerViewButtonTappedForSection(section: Int)
}

class MealSectionHeaderView: UITableViewHeaderFooterView {

	@IBOutlet weak var titleLabel: UILabel!
	
	var section: Int!
	weak var delegate: MealSectionHeaderViewDelegate?
	
	
	// BUTTON TAPPED
	//
	@IBAction func buttonTapped(sender: AnyObject) {
		delegate?.headerViewButtonTappedForSection(section)
	}

	/*
	// Only override drawRect: if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	override func drawRect(rect: CGRect) {
	// Drawing code
	}
	*/
}

//
//  UIView+Constraints.swift
//  Drop
//
//  Created by Loïc Saillant on 05/06/2024.
//

import UIKit

enum SizeConstraintDirection {
    case height, width
}

extension UIView {

    // MARK: - UIView
    
    func pinToSuperview(_ edges: [NSLayoutConstraint.Attribute] = [.leading, .top, .trailing, .bottom],
                        constant: CGFloat = 0.0) {
        guard let superview = superview else { fatalError("Should add view before") }
        edges.forEach {
            let negativeEdges: [NSLayoutConstraint.Attribute] = [.trailing, .right, .bottom]
            let constant = negativeEdges.contains($0) ? -constant : constant
            pin($0, to: superview, constant: constant)
        }
    }
    
    @discardableResult
    func pin(_ attribute: NSLayoutConstraint.Attribute,
             to view: UIView,
             otherViewAttribute: NSLayoutConstraint.Attribute? = nil,
             constant: CGFloat = 0.0,
             priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: attribute,
            relatedBy: .equal,
            toItem: view,
            attribute: otherViewAttribute ?? attribute,
            multiplier: 1.0,
            constant: constant
        )
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
    
    func constraint(_ directions: [SizeConstraintDirection], constant: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        directions.forEach { direction in
            switch direction {
            case .height:
                heightAnchor.constraint(equalToConstant: constant).isActive = true
            case .width:
                widthAnchor.constraint(equalToConstant: constant).isActive = true
            }
        }
    }
}


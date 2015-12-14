//
//  ElloTextField.swift
//  Ello
//
//  Created by Sean Dougherty on 11/25/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

enum ValidationState {
    case Loading
    case Error
    case OK
    case None

    var imageRepresentation: UIImage? {
        switch self {
        case .Loading: return Interface.Image.ValidationLoading.normalImage
        case .Error: return Interface.Image.ValidationError.normalImage
        case .OK: return Interface.Image.ValidationOK.normalImage
        case .None: return nil
        }
    }
}

public class ElloTextField: UITextField {
    var hasOnePassword = false
    var validationState = ValidationState.None {
        didSet {
            self.rightViewMode = .Always
            self.rightView = UIImageView(image: validationState.imageRepresentation)
        }
    }

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedSetup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedSetup()
    }

    func sharedSetup() {
        self.backgroundColor = UIColor.greyE5()
        self.font = UIFont.defaultFont()
        self.textColor = UIColor.blackColor()

        self.setNeedsDisplay()
    }

    override public func textRectForBounds(bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    override public func editingRectForBounds(bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    override public func clearButtonRectForBounds(bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRectForBounds(bounds)
        rect.origin.x -= 10
        if hasOnePassword {
            rect.origin.x -= 44
        }
        return rect
    }

    override public func rightViewRectForBounds(bounds: CGRect) -> CGRect {
        var rect = super.rightViewRectForBounds(bounds)
        rect.origin.x -= 10
        return rect
    }

    private func rectForBounds(var bounds: CGRect) -> CGRect {
        bounds.size.width -= 15
        return CGRectInset(bounds, 15, 10)
    }

}

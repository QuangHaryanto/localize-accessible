//
//  SheetViewController.swift
//  myLocalSwiftApp
//
//  Created by Haryanto Salim on 29/09/22.
//

import UIKit

struct ActivitySuggestion: Codable {
    let activity, type: String
    let participants, price: Int
    let link, key: String
    let accessibility: Int
}


class SheetViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.viewDidLoad()
        
        
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [
                .medium(),
                .large(),
            ]
            presentationController.delegate = self
            presentationController.prefersGrabberVisible = true
            presentationController.largestUndimmedDetentIdentifier = .medium
            presentationController.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        setupView()
    }
    
    @objc func endEditing(){
        
    }
    
    func setupView(){
        view.backgroundColor = .systemBackground
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        view.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        // autolayout constraint
        let layoutGuide: UILayoutGuide = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 50),
            mainStackView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor)
        ])
    }
    
    lazy var mainStackView = {
        //Stack View
        var stackView = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.fill
        stackView.spacing   = 8.0
        
        let activityContentStack = customStackView(.vertical, .fill, .center)
        let activityContentScrollView = UIScrollView()
        activityContentScrollView.delegate = self
        stackView.addArrangedSubview(activityContentScrollView)
        
        activityContentScrollView.addSubview(activityContentStack)

        activityContentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityContentStack.leadingAnchor.constraint(equalTo: activityContentScrollView.leadingAnchor),
            activityContentStack.trailingAnchor.constraint(equalTo: activityContentScrollView.trailingAnchor),
            activityContentStack.bottomAnchor.constraint(equalTo: activityContentScrollView.bottomAnchor),
            activityContentStack.topAnchor.constraint(equalTo: activityContentScrollView.topAnchor),
            activityContentStack.widthAnchor.constraint(equalTo:activityContentScrollView.widthAnchor),
        ])
        
        let activityStack = keyValueFormatStack("Activity", "Have a bonfire with your close friends", .vertical, .fill, .fill)
        activityContentStack.addArrangedSubview(activityStack)
        activityStack.translatesAutoresizingMaskIntoConstraints = false
        activityStack.leadingAnchor.constraint(equalTo: activityContentStack.leadingAnchor).isActive = true
        
//        let activityStack1 = keyValueStack("Activity", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", .vertical, .fill, .fill)
//        activityStack1.backgroundColor = .yellow
//        contentStack.addArrangedSubview(activityStack1)
//        activityStack1.translatesAutoresizingMaskIntoConstraints = false
//        activityStack1.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor).isActive = true
//
//        let activityStack2 = keyValueStack("Activity", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", .vertical, .fill, .fill)
//        activityStack2.backgroundColor = .yellow
//        contentStack.addArrangedSubview(activityStack2)
//        activityStack2.translatesAutoresizingMaskIntoConstraints = false
//        activityStack2.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor).isActive = true
        
        let typeStack = keyValueFormatStack("Type", "Social", .vertical, .fill, .fill)
        activityContentStack.addArrangedSubview(typeStack)
        typeStack.leadingAnchor.constraint(equalTo: activityContentStack.leadingAnchor).isActive = true
        
        let participantStack = keyValueFormatStack("Participants", "4", .vertical, .fill, .fill)
        activityContentStack.addArrangedSubview(participantStack)
        participantStack.translatesAutoresizingMaskIntoConstraints = false
        participantStack.leadingAnchor.constraint(equalTo: activityContentStack.leadingAnchor).isActive = true
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        
        let priceStack = keyValueFormatStack("Price", formatter.string(from: NSNumber(floatLiteral: 0.1)) ?? "n/a", .vertical, .fill, .fill)
        activityContentStack.addArrangedSubview(priceStack)
        priceStack.leadingAnchor.constraint(equalTo: activityContentStack.leadingAnchor).isActive = true
        
        let linkStack = keyValueFormatStack("Link", "http://", .vertical, .fill, .fill)
        activityContentStack.addArrangedSubview(linkStack)
        linkStack.leadingAnchor.constraint(equalTo: activityContentStack.leadingAnchor).isActive = true
        
//        let accessibilityStack = keyValueStack("Accessibility", "0.1", .vertical, .fill, .fill)
//        contentStack.addArrangedSubview(accessibilityStack)
//        accessibilityStack.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor).isActive = true
        
        let fillerStack = keyValueFormatStack("", "", .vertical, .fill, .fill)
        activityContentStack.addArrangedSubview(fillerStack)
        fillerStack.leadingAnchor.constraint(equalTo: activityContentStack.leadingAnchor).isActive = true
        
        stackView.addArrangedSubview(activitySuggestButton)
        activitySuggestButton.translatesAutoresizingMaskIntoConstraints = false
        activitySuggestButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        activitySuggestButton.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
        
        return stackView
    }()
    
    func keyValueFormatStack(_ key: String, _ value: String, _ axis: NSLayoutConstraint.Axis, _ distri: UIStackView.Distribution, _ align: UIStackView.Alignment) -> UIStackView{
        let myStack = UIStackView()
        myStack.axis  = axis
        myStack.distribution  = distri
        myStack.alignment = align
        myStack.spacing   = 4.0
        
        let myKeyLabel = UILabel()
        myKeyLabel.font = UIFont.preferredFont(forTextStyle: .title3, compatibleWith: .none)
        myKeyLabel.adjustsFontForContentSizeCategory = true
        myKeyLabel.text = key
        myKeyLabel.numberOfLines = 0
        myStack.addArrangedSubview(myKeyLabel)

        let myValueLabel = UILabel()
        myValueLabel.font = UIFont.preferredFont(forTextStyle: .body, compatibleWith: .none)
        myValueLabel.adjustsFontForContentSizeCategory = true
        myValueLabel.text = value
        myValueLabel.numberOfLines = 0
        myStack.addArrangedSubview(myValueLabel)

        return myStack
    }
    
    func customStackView(_ axis: NSLayoutConstraint.Axis, _ distri: UIStackView.Distribution, _ align: UIStackView.Alignment) -> UIStackView{
        let myStack = UIStackView()
        myStack.axis  = axis
        myStack.distribution  = distri
        myStack.alignment = align
        myStack.spacing   = 8.0
        
        return myStack
    }
    
    lazy var activitySuggestButton: UIButton = {
        let myButton = UIButton()
        myButton.setTitle(NSLocalizedString("Suggest Me An Activity", comment: "A Suggestion Button Tap"), for: .normal)
        myButton.configuration = .bordered()
        myButton.configuration?.cornerStyle = .capsule
        myButton.configuration?.image = UIImage(systemName: "hourglass.bottomhalf.filled")?.imageFlippedForRightToLeftLayoutDirection()
        myButton.addTarget(self, action: #selector(didTapMyButton), for: .touchUpInside)
        return myButton
    }()
    
    @objc func didTapMyButton(){
        print("button tapped")
    }
}

extension SheetViewController:UIScrollViewDelegate{
}

extension SheetViewController:UISheetPresentationControllerDelegate{
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        print("change detend")
        
        if let detent = sheetPresentationController.selectedDetentIdentifier{
            switch detent{
            case .medium:
                print("medium")
           case .large:
                print("large")
            default:
                print("default")
            }
        }
    }
}

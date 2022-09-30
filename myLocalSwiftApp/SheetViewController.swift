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
    
    var stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.viewDidLoad()
        view.backgroundColor = .white
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        //Stack View
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.fill
        stackView.spacing   = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        
        let contentStack = viewStack(.vertical, .fill, .center)
        let myScrollView = UIScrollView()
        myScrollView.delegate = self
        stackView.addArrangedSubview(myScrollView)
        
        myScrollView.addSubview(contentStack)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: myScrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: myScrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: myScrollView.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: myScrollView.topAnchor),
            contentStack.widthAnchor.constraint(equalTo:myScrollView.widthAnchor),
        ])
        
        let activityStack = keyValueStack("Activity", "Have a bonfire with your close friends", .vertical, .fill, .fill)
        contentStack.addArrangedSubview(activityStack)
        activityStack.translatesAutoresizingMaskIntoConstraints = false
        activityStack.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor).isActive = true
        
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
        
        let typeStack = keyValueStack("Type", "Social", .vertical, .fill, .fill)
        contentStack.addArrangedSubview(typeStack)
        typeStack.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor).isActive = true
        
        let participantStack = keyValueStack("Participants", "4", .vertical, .fill, .fill)
        contentStack.addArrangedSubview(participantStack)
        participantStack.translatesAutoresizingMaskIntoConstraints = false
        participantStack.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor).isActive = true
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        
        let priceStack = keyValueStack("Price", formatter.string(from: NSNumber(floatLiteral: 0.1)) ?? "n/a", .vertical, .fill, .fill)
        contentStack.addArrangedSubview(priceStack)
        priceStack.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor).isActive = true
        
        let linkStack = keyValueStack("Link", "http://", .vertical, .fill, .fill)
        contentStack.addArrangedSubview(linkStack)
        linkStack.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor).isActive = true
        
//        let accessibilityStack = keyValueStack("Accessibility", "0.1", .vertical, .fill, .fill)
//        contentStack.addArrangedSubview(accessibilityStack)
//        accessibilityStack.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor).isActive = true
        
        let fillerStack = keyValueStack("", "", .vertical, .fill, .fill)
        contentStack.addArrangedSubview(fillerStack)
        fillerStack.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor).isActive = true
        
        let myButton = setupButton()
        myButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(myButton)
        myButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        myButton.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
        
        // autolayout constraint
        let layoutGuide: UILayoutGuide = view.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 50),
            stackView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor)
        ])
    }
    
    func keyValueStack(_ key: String, _ value: String, _ axis: NSLayoutConstraint.Axis, _ distri: UIStackView.Distribution, _ align: UIStackView.Alignment) -> UIStackView{
        let kvStack = UIStackView()
        kvStack.axis  = axis
        kvStack.distribution  = distri
        kvStack.alignment = align
        kvStack.spacing   = 4.0
        
        let myKeyLabel = UILabel()
        
        myKeyLabel.font = UIFont.preferredFont(forTextStyle: .title3, compatibleWith: .none)
        myKeyLabel.adjustsFontForContentSizeCategory = true
        myKeyLabel.text = key
        myKeyLabel.numberOfLines = 0

        kvStack.addArrangedSubview(myKeyLabel)

        let myValueLabel = UILabel()
        myValueLabel.font = UIFont.preferredFont(forTextStyle: .body, compatibleWith: .none)
        myValueLabel.adjustsFontForContentSizeCategory = true
        myValueLabel.text = value
        myValueLabel.numberOfLines = 0
        kvStack.addArrangedSubview(myValueLabel)

        return kvStack
    }
    
    func viewStack(_ axis: NSLayoutConstraint.Axis, _ distri: UIStackView.Distribution, _ align: UIStackView.Alignment) -> UIStackView{
        let kvStack = UIStackView()
        kvStack.axis  = axis
        kvStack.distribution  = distri
        kvStack.alignment = align
        kvStack.spacing   = 8.0
        
        return kvStack
    }
    
    func setupButton()->UIButton{
        let myButton = myCustomButton()
        myButton.setTitle(NSLocalizedString("Suggest Me An Activity", comment: "A Suggestion Button Tap"), for: .normal)
        myButton.configuration = .bordered()
        myButton.configuration?.cornerStyle = .capsule
        myButton.configuration?.image = UIImage(systemName: "hourglass.bottomhalf.filled")?.imageFlippedForRightToLeftLayoutDirection()
        myButton.addTarget(self, action: #selector(didTapMyButton), for: .touchUpInside)
        return myButton
    }
    
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

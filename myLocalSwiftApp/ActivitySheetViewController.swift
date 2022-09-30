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

class ActivitySheetViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [
                .medium(),
                .large(),
            ]
            presentationController.delegate = self
            presentationController.prefersGrabberVisible = true
            presentationController.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        setupView()
    }

    func setupView(){
        view.backgroundColor = .systemBackground
        
        //setup navbar
        view.addSubview(myCustomNavigationBar)
        myCustomNavigationBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            myCustomNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            myCustomNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        // autolayout constraint
        let layoutGuide: UILayoutGuide = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 65),
            mainStackView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor)
        ])
    }
    
    lazy var myCustomNavigationBar: UIView = {
        let navBar = UINavigationBar()
        let navItem = UINavigationItem(title: "Activity Suggestion")

        navBar.setItems([navItem], animated: false)
        
        return navBar
    }()
    
    lazy var mainStackView = {
        //Stack View
        var stackView = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.fill
        stackView.spacing   = 8.0
        
        let activityContentStack = customStackView(.vertical, .fill, .center)
        let activityContentScrollView = UIScrollView()
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
        
        let activityStack = keyValueFormatStack("Activity Name", "Have a bonfire with your close friends", .vertical, .fill, .fill)
        activityContentStack.addArrangedSubview(activityStack)
        activityStack.translatesAutoresizingMaskIntoConstraints = false
        activityStack.leadingAnchor.constraint(equalTo: activityContentStack.leadingAnchor).isActive = true
        
        let typeStack = keyValueFormatStack("Type", "Social", .vertical, .fill, .fill)
        activityContentStack.addArrangedSubview(typeStack)
        typeStack.leadingAnchor.constraint(equalTo: activityContentStack.leadingAnchor).isActive = true
        
        let participantStack = keyValueFormatStack("Participants", "4", .vertical, .fill, .fill)
        activityContentStack.addArrangedSubview(participantStack)
        participantStack.translatesAutoresizingMaskIntoConstraints = false
        participantStack.leadingAnchor.constraint(equalTo: activityContentStack.leadingAnchor).isActive = true
        participantStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        
        let priceStack = keyValueFormatStack("Price", formatter.string(from: NSNumber(floatLiteral: 0.1)) ?? "n/a", .vertical, .fill, .fill)
        activityContentStack.addArrangedSubview(priceStack)
        priceStack.leadingAnchor.constraint(equalTo: activityContentStack.leadingAnchor).isActive = true
        priceStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let linkStack = keyValueFormatStack("Link", "http://", .vertical, .fill, .fill)
        activityContentStack.addArrangedSubview(linkStack)
        linkStack.leadingAnchor.constraint(equalTo: activityContentStack.leadingAnchor).isActive = true
        linkStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
   
        let fillerStack = keyValueFormatStack("", "", .vertical, .fill, .fill)
        activityContentStack.addArrangedSubview(fillerStack)
        fillerStack.leadingAnchor.constraint(equalTo: activityContentStack.leadingAnchor).isActive = true
        fillerStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        stackView.addArrangedSubview(activitySuggestButton)
        activitySuggestButton.translatesAutoresizingMaskIntoConstraints = false
        activitySuggestButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        activitySuggestButton.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
        activitySuggestButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        return stackView
    }()
    
    func keyValueFormatStack(_ key: String, _ value: String, _ axis: NSLayoutConstraint.Axis, _ distri: UIStackView.Distribution, _ align: UIStackView.Alignment) -> UIStackView{
        let myStack = UIStackView()
        myStack.axis  = axis
        myStack.distribution  = distri
        myStack.alignment = align
        myStack.spacing   = 4.0
        
        let myKeyLabel = UILabel()
        myKeyLabel.text = key
        myStack.addArrangedSubview(myKeyLabel)

        let myValueLabel = UILabel()
        myValueLabel.text = value
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
        myButton.setTitle("Suggest Me An Activity", for: .normal)
        myButton.backgroundColor = .systemGray4
        myButton.tintColor = .white
        myButton.setImage(UIImage(systemName: "hourglass.bottomhalf.filled"), for: .normal)
        myButton.addTarget(self, action: #selector(didTapActSuggestionButton), for: .touchUpInside)
        return myButton
    }()
    
    @objc func didTapActSuggestionButton(){
        print("button tapped")
    }
}

extension ActivitySheetViewController:UISheetPresentationControllerDelegate{
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

//
//  SecondViewController.swift
//  myLocalSwiftApp
//
//  Created by Haryanto Salim on 21/09/22.
//

import UIKit
struct Author: Codable {
    let edsgerWDijkstra, tonyHoare, jeffHammerbacher, fredBrooks: AuthorDetail
    let michaelStal: AuthorDetail
    
    enum CodingKeys: String, CodingKey {
        case edsgerWDijkstra
        case tonyHoare
        case jeffHammerbacher
        case fredBrooks
        case michaelStal
    }
}

struct AuthorDetail: Codable {
    let name: String?
    let wikiURL: String?
    let quoteCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case wikiURL
        case quoteCount
    }
}

class SecondViewController: UIViewController {
    var items: [AuthorDetail] = [AuthorDetail(name: "Haryanto", wikiURL: "http://", quoteCount: 8), AuthorDetail(name: "Salim", wikiURL: "http://", quoteCount: 8)]
    let stackView = UIStackView()
    var myTable = UITableView()
    var xnetworkService = ExampleNetworkService(sessionConfiguration: URLSessionConfiguration.default)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupManualNavigationBar()
        setupView()
        loadData()
    }
    
    func loadData(){
        xnetworkService.request(url: "https://programming-quotes-api.herokuapp.com/Authors", query: nil, httpMethod: "GET") { [self] response in
            switch response {
            case .success(let data):
                DispatchQueue.main.async { [self] in
                    //                    self.items = self.xnetworkService.parse(model: AuthorDetail.self, json: data)
                    do{
                        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                            // appropriate error handling
                            return
                        }
                        items = []
                        for item in json{
                            let data = try JSONSerialization.data(withJSONObject: item.value, options: [])
                            let author = try JSONDecoder().decode(AuthorDetail.self, from: data)
                            items.append(author)
                        }
                    }catch{
                        print(error.localizedDescription)
                    }
                    self.myTable.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func setupView(){
        //Stack View
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalCentering
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        
        myTable.translatesAutoresizingMaskIntoConstraints = false
        myTable = setupTable()
        stackView.addArrangedSubview(myTable)
        myTable.leadingAnchor.constraint(equalTo: myTable.superview!.leadingAnchor).isActive = true
        myTable.heightAnchor.constraint(equalTo: myTable.superview!.heightAnchor, constant:-44).isActive = true
        myTable.backgroundColor = .systemCyan
        
        let myButton = setupButton()
        myButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(myButton)
        myButton.leadingAnchor.constraint(equalTo: myButton.superview!.leadingAnchor).isActive = true
        
        reLayout()
    }
    
    func reLayout(){
        // autolayout constraint
        let layoutGuide: UILayoutGuide = view.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 44.0),
            //            stackView.leftAnchor.constraint(equalTo: layoutGuide.leftAnchor),
            //            stackView.rightAnchor.constraint(equalTo: layoutGuide.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor)
            
        ])
    }
    
    func setupButton()->UIButton{
        let myButton = UIButton()
        myButton.setTitle(NSLocalizedString("Tap Me", comment: "A Button Tap"), for: .normal)
        myButton.setTitleColor(.white, for: .normal)
        myButton.backgroundColor = .systemBlue
        myButton.layer.cornerRadius = 5;
        myButton.addTarget(self, action: #selector(didTapMyButton), for: .touchUpInside)
        return myButton
    }
    
    @objc func didTapMyButton(){
        
    }
    
    func setupTable()->UITableView{
        let myTable = UITableView()
        myTable.dataSource = self
        myTable.delegate = self
        myTable.register(MyCustomCell.self, forCellReuseIdentifier: "MyCell")
        return myTable
    }
    
    func setupManualNavigationBar(){
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        view.addSubview(navBar)
        
        let navItem = UINavigationItem(title: NSLocalizedString("Modal Page", comment: "Modal Page"))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        navItem.rightBarButtonItem = doneItem
        
        navBar.setItems([navItem], animated: false)
    }
    
    @objc func didTapDone(){
        self.dismiss(animated: true, completion: nil)
    }
    
    private func quotesCountUniversal(count: UInt) -> String{
        
        let formatString : String = NSLocalizedString("quotes count",
                                                      comment: "Quotes count string format to be found in Localized.stringsdict")
        let resultString : String = String.localizedStringWithFormat(formatString, count)
        return resultString;
    }
    
}

extension SecondViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell") as? MyCustomCell{
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "\(items[indexPath.row].name ?? "") \(quotesCountUniversal(count: UInt(items[indexPath.row].quoteCount ?? 0)))"
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = items[indexPath.row].wikiURL
            
            return cell
        }
        return UITableViewCell()
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}



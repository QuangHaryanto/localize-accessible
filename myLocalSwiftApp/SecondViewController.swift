//
//  SecondViewController.swift
//  myLocalSwiftApp
//
//  Created by Haryanto Salim on 21/09/22.
//

import UIKit

struct AuthorDetail: Codable {
    let name: String?
    let wikiURL: String?
    let quoteCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case wikiURL
        case quoteCount
    }
    
    static var initialJSON = """
{
  "Haryanto Salim": {
    "name": "Haryanto Salim",
    "wikiUrl": "https://",
    "quoteCount": 0
  },
  "Edsger W. Dijkstra": {
    "name": "Edsger W. Dijkstra",
    "wikiUrl": "https://en.wikipedia.org/wiki/Edsger W. Dijkstra",
    "quoteCount": 23
  },
  "Tony Hoare": {
    "name": "Tony Hoare",
    "wikiUrl": "https://en.wikipedia.org/wiki/Tony Hoare",
    "quoteCount": 1
  },
  "Jeff Hammerbacher": {
    "name": "Jeff Hammerbacher",
    "wikiUrl": "https://en.wikipedia.org/wiki/Jeff Hammerbacher",
    "quoteCount": 1
  },
  "Fred Brooks": {
    "name": "Fred Brooks",
    "wikiUrl": "https://en.wikipedia.org/wiki/Fred Brooks",
    "quoteCount": 35
  },
  "Michael Stal": {
    "name": "Michael Stal",
    "wikiUrl": "https://en.wikipedia.org/wiki/Michael Stal",
    "quoteCount": 1
  },
  "Jeff Sickel": {
    "name": "Jeff Sickel",
    "wikiUrl": "https://en.wikipedia.org/wiki/Jeff Sickel",
    "quoteCount": 1
  },
  "Ken Thompson": {
    "name": "Ken Thompson",
    "wikiUrl": "https://en.wikipedia.org/wiki/Ken Thompson",
    "quoteCount": 8
  },
  "Donald Knuth": {
    "name": "Donald Knuth",
    "wikiUrl": "https://en.wikipedia.org/wiki/Donald Knuth",
    "quoteCount": 14
  },
  "Grace Hopper": {
    "name": "Grace Hopper",
    "wikiUrl": "https://en.wikipedia.org/wiki/Grace Hopper",
    "quoteCount": 1
  },
  "Rick Osborne": {
    "name": "Rick Osborne",
    "wikiUrl": "https://en.wikipedia.org/wiki/Rick Osborne",
    "quoteCount": 1
  },
  "John Ousterhout": {
    "name": "John Ousterhout",
    "wikiUrl": "https://en.wikipedia.org/wiki/John Ousterhout",
    "quoteCount": 1
  },
  "Poul Anderson": {
    "name": "Poul Anderson",
    "wikiUrl": "https://en.wikipedia.org/wiki/Poul Anderson",
    "quoteCount": 1
  },
  "Robert C. Martin": {
    "name": "Robert C. Martin",
    "wikiUrl": "https://en.wikipedia.org/wiki/Robert C. Martin",
    "quoteCount": 4
  },
  "David Gelernter": {
    "name": "David Gelernter",
    "wikiUrl": "https://en.wikipedia.org/wiki/David Gelernter",
    "quoteCount": 1
  },
  "Edward V. Berard": {
    "name": "Edward V. Berard",
    "wikiUrl": "https://en.wikipedia.org/wiki/Edward V. Berard",
    "quoteCount": 1
  },
  "Brian Kernighan": {
    "name": "Brian Kernighan",
    "wikiUrl": "https://en.wikipedia.org/wiki/Brian Kernighan",
    "quoteCount": 3
  },
  "Chris Wenham": {
    "name": "Chris Wenham",
    "wikiUrl": "https://en.wikipedia.org/wiki/Chris Wenham",
    "quoteCount": 1
  },
  "Haryanto Salim": {
    "name": "Haryanto Salim",
    "wikiUrl": "https://",
    "quoteCount": 0
  }
}
"""
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
    
    func loadDataFromNetwork(){
        xnetworkService.request(url: "https://programming-quotes-api.herokuapp.com/Authors", query: nil, httpMethod: "GET") { [self] response in
            switch response {
            case .success(let data):
                DispatchQueue.main.async { [self] in
                    do{
                        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
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
    
    func loadData(){
        DispatchQueue.main.async { [self] in
            guard let data = AuthorDetail.initialJSON.data(using: .utf8) else { return }
            
            do{
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
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
            myTable.reloadData()
        }
    }
    
    func setupView(){
        //Stack View
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        
        myTable.translatesAutoresizingMaskIntoConstraints = false
        myTable = setupTable()
        stackView.addArrangedSubview(myTable)
        myTable.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        
        let myButton = setupButton()
        myButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(myButton)
        myButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        
        // autolayout constraint
        let layoutGuide: UILayoutGuide = view.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 60),
            stackView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor)
        ])
    }
    
    func setupButton()->UIButton{
        let myButton = UIButton()
        myButton.setTitle(NSLocalizedString("Close", comment: "A Button Tap"), for: .normal)
        myButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        myButton.titleLabel?.adjustsFontForContentSizeCategory = true
        myButton.configuration = .filled()
        myButton.configuration?.cornerStyle = .capsule
        let imgConfig = UIImage.SymbolConfiguration.preferringMulticolor()
        let img = UIImage(systemName: "xmark.circle.fill", withConfiguration: imgConfig)
        myButton.configuration?.image = img
        myButton.addTarget(self, action: #selector(didTapMyButton), for: .touchUpInside)
        return myButton
    }
    
    @objc func didTapMyButton(){
        self.dismiss(animated: true)
    }
    
    func setupTable()->UITableView{
        let myTable = UITableView()
        myTable.dataSource = self
        myTable.delegate = self
        myTable.register(MyCustomCell.self, forCellReuseIdentifier: "MyCell")
        myTable.layer.cornerRadius = 10
        return myTable
    }
    
    func setupManualNavigationBar(){
        let navBar = UINavigationBar()
        view.addSubview(navBar)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let navItem = UINavigationItem(title: NSLocalizedString("Author List", comment: "Modal Page"))
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



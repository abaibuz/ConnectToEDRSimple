//
//  ViewController.swift
//  ConnectToEDRSimple
//
//  Created by Baibuz Oleksandr on 17.09.2018.
//  Copyright © 2018 Baibuz Oleksandr. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    
    
    func updateSearchResults(for searchController: UISearchController) {


    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if  searchBar.text != "" {
            executeQuery(textForSearch: searchBar.text)
            searchBar.endEditing(true)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        if self.firms != nil {
            self.firms.firms.removeAll();
        }
   //     self.tableFirm.reloadData()
        tableFirm.tableHeaderView = nil
        startView.frame = tableFirm.frame
        tableFirm.tableFooterView = startView
        self.tableFirm.reloadData()
   }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arraySearchField.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
    //         searchController.searchBar.placeholder = self.arraySearchField[row][0]
             searchBarStoryBoard.placeholder = self.arraySearchField[row][0]
 //           searchController.searchBar.text = ""
            searchBarStoryBoard.text = ""
            searchBarCancelButtonClicked(searchBarStoryBoard)
            if row == 0 {
                searchBarStoryBoard.keyboardType = .numberPad
                searchBarStoryBoard.inputAccessoryView = toolBarKeyboard
                
            } else {
                searchBarStoryBoard.keyboardType = .default
                searchBarStoryBoard.inputAccessoryView = nil
            }
        //        searchController.searchBar.showsCancelButton = false
     //        self.searchBarCancelButtonClicked(searchController.searchBar)
     //       searchController.searchBar.showsCancelButton = true
        } else {
            let orderField = self.arraySearchField[row][1]
            sortByField(field : orderField)
            self.tableFirm.reloadData()
        }
    }
    
    func sortByField(field : String) {
        if self.firms == nil {
            self.modelController.edrpouToFirmCoreData.removeAll()
            return
        }
        
        switch field {
        case "edrpou":
            self.firms.firms.sort(by: {$0.edrpou < $1.edrpou})
            break
        case "address":
            self.firms.firms.sort(by: {$0.address < $1.address})
            break
        case "mainPerson":
            self.firms.firms.sort(by: {$0.mainPerson < $1.mainPerson})
            break
        case "name":
            self.firms.firms.sort(by: {$0.name < $1.name})
            break
        case "occupation":
            self.firms.firms.sort(by: {$0.occupation < $1.occupation})
            break
        case "officialName":
            self.firms.firms.sort(by: {$0.officialName < $1.officialName})
            break
        case "status":
            self.firms.firms.sort(by: {$0.status < $1.status})
            break
        default:
            self.firms.firms.sort(by: {$0.id < $1.id})
            break
        }
        
        for firm in self.firms.firms {
            let predicate = NSPredicate(format: "edrpou = %@",  firm.edrpou)
            let fetchedResultsController = CoreDataManager.instance.fetchedResultsController(entityName: "Firms", keyForSort: "edrpou", predicate: predicate)
            do {
                try fetchedResultsController.performFetch()
                let filteredImemsCount = fetchedResultsController.sections![0].numberOfObjects
                if filteredImemsCount > 0 {
                    let newElement = EdrpouToFirmCoreData(edrpou: firm.edrpou, firmCoreData: fetchedResultsController.object(at: IndexPath(row: 0, section: 0)) as! Firms)
                    self.modelController.edrpouToFirmCoreData.append(newElement)
                }
            }
            catch{
                print(error)
            }

        }
        
    }
/*
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return self.arraySearchField[row][0]
    }
*/
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "System", size: 14)
            pickerLabel?.textAlignment = NSTextAlignment.left
        }
        pickerLabel?.text = self.arraySearchField[row][0]
        return pickerLabel!;
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let firms = firms {
            return firms.firms.count
        }
        else {
            return 0;
        }
    }
    
    
    //--------
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        let firm = firms.firms[indexPath.row]
        if firm.name == "" {
            cell.textLabel?.text = firm.officialName
        } else {
            cell.textLabel?.text = firm.name
        }
        
        let isFirmCoreData = self.modelController.edrpouToFirmCoreData.contains { (edrpouToFirmCoreData)  in
            if edrpouToFirmCoreData.edrpou == firm.edrpou {
                return true
            }
            else {
                return false
            }
        }
        
        cell.detailTextLabel?.text = firm.edrpou
        if isFirmCoreData {
           cell.textLabel?.textColor = .red
           cell.detailTextLabel?.textColor = .red
        }
        return cell
    }
    
    
    var tempUrl = "http://edr.data-gov-ua.org/api/companies?where={\"Field\":{\"contains\":\"Content\"}}&limit=countRecord&skip=startRecord&sort=id"
    var firms: edrFirms!
  //  var edrpouToFirmCoreData: [EdrpouToFirmCoreData] = []
    var modelController: ModelController!
    
    var searchController: UISearchController!
    var searchFooter: SearchFooter!
    @IBOutlet weak var searchBarStoryBoard: UISearchBar! {
        didSet {
            searchBarStoryBoard.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForcountRecord)))
        }
    }
    var toolBarKeyboard: UIToolbar = UIToolbar()
    
    var didSelectedTableView = false
    
    @IBOutlet weak var countRecord: UITextField! {
        didSet {
            countRecord?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForcountRecord)))
        }
    }
    @IBOutlet weak var startRecord: UITextField!{
        didSet {
            startRecord?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForstartRecord)))
        }
    }
    
    @IBOutlet weak var tableFirm: UITableView!
   
    @IBOutlet weak var selectSearchField: UIPickerView!
    
    @IBOutlet weak var startView: UIView!
    
    @IBOutlet weak var cancelView: UIView!
    
    @objc func doneButtonTappedForcountRecord(_ sender: Any) {
  //      let searchBar = self.searchController.searchBar
        if let searchBar = self.searchBarStoryBoard {
            self.searchBarSearchButtonClicked(searchBar)
        }
        countRecord.resignFirstResponder()
  }
    
    @objc func doneButtonTappedForstartRecord(_ sender: Any) {
//        let searchBar = self.searchController.searchBar
        if let searchBar = self.searchBarStoryBoard {
            self.searchBarSearchButtonClicked(searchBar)
        }
        startRecord.resignFirstResponder()
    }

    @IBOutlet weak var HeadView: UIView!
    
    let arraySearchField = [["ЕДРПОУ","edrpou"], ["назва", "name"], ["повн.назва", "officialName"], ["адреса", "address"], ["керівник","mainPerson"],["діяльність", "occupation"]]
     
    var getDataQueue = OperationQueue()
    
    let loadDataQueue = DispatchQueue(label: "com.ConnectToEDR.getData")

    let progressHUD = ProgressHUD(text: "Перервати")
    
    private let refreshControl = UIRefreshControl()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressHUD.hide()
        
        countRecord.text = "10"
        startRecord.text = "0"
        selectSearchField.delegate = self
        
        
//       definesPresentationContext = false
//       self.extendedLayoutIncludesOpaqueBars = true
 
        if let tbc = self.tabBarController as? ModelTabBarController {
            self.modelController = tbc.modelController
        }
        
        setTableFooterView()
        setSearchBarProperty(searchBar: searchBarStoryBoard)
        setRefreshControlProperties(refreshControl: refreshControl)
 
    }

    private func setSearchBarProperty(searchBar : UISearchBar ) {
        searchBar.placeholder = "ЕДРПОУ"
        searchBar.searchBarStyle = UISearchBar.Style.prominent
//        searchBar.tintColor = .candyGreen
//        searchBar.sizeToFit()
        searchBar.setShowsCancelButton(true, animated: true)
   //     searchBar.barTintColor =
        searchBar.keyboardType = .numberPad
        toolBarKeyboard = searchBar.inputAccessoryView as! UIToolbar
    }
    
    private func setRefreshControlProperties(refreshControl : UIRefreshControl) {
        refreshControl.addTarget(self, action: #selector(refreshTableFirmData(_:)), for: .allEvents)
        tableFirm.refreshControl = refreshControl
    }
    
    @objc private func refreshTableFirmData(_ sender: Any) {
        self.refreshControl.endRefreshing()
        self.searchBarSearchButtonClicked(self.searchBarStoryBoard)
    }

    private func setTableFooterView() {
        searchFooter = SearchFooter(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        let curframe = tableFirm.frame
        self.startView.frame = curframe
        tableFirm.tableFooterView = self.startView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    func executeQuery(textForSearch: String!) {
        let urlText = self.tempUrl as NSString;
        let selectRow = selectSearchField.selectedRow(inComponent: 0)
        var feildName = "edrpou"
        if  selectRow >= 0 {
            feildName = self.arraySearchField[selectRow][1]
        }
        
        let url1 = urlText.replacingOccurrences(of: "Field", with: feildName) as NSString
       //--111111111
        if let textForSearch = textForSearch {
            let url2 = url1.replacingOccurrences(of: "Content", with: textForSearch) as NSString
            
            var countR: String
            
            if let count = self.countRecord.text{
                if count == "" {
                    countR = "1"
                } else {
                    countR = count
                }
            } else {
                countR = "1"
            }
            
            var startR: String
            
            if let start = self.startRecord.text{
                if start == "" {
                    startR = "1"
                } else {
                    startR = start
                }
            } else {
                startR = "1"
            }

            
            let url3 = url2.replacingOccurrences(of: "countRecord", with: countR) as NSString
            let url4 = url3.replacingOccurrences(of: "startRecord", with: startR) as NSString
            var countRInt: Int
            if let countR = self.countRecord.text {
                countRInt = Int(countR)!
            } else {
                countRInt = 0
            }
            
            //-222222222222
            loadDataQueue.async {
                let getDataFromEDR = GetDataFromEDR(url: url4 as String)
                var statusFinishOperation: StatusFinishGetDataOperation = .ok
                DispatchQueue.main.async{
                    self.view.addSubview(self.progressHUD)
                    self.progressHUD.operation = getDataFromEDR
                    self.setUserInteractionEnabled(isUserInteractionEnabled: false, alpha: 0.7)
                    self.progressHUD.show()
                }
                
                let parserDataFromEDR = ParserDataFromEDR()
                let fetchOperation = BlockOperation() {
                    DispatchQueue.main.async {
                        self.progressHUD.hide()
                        self.progressHUD.removeFromSuperview()
                        self.setUserInteractionEnabled(isUserInteractionEnabled: true, alpha: 1)
                    }
                    
                    statusFinishOperation = getDataFromEDR.statusFinishOperation
                    
                    if statusFinishOperation == .ok {
                        if let data = getDataFromEDR.data {
                            parserDataFromEDR.data = data
                            parserDataFromEDR.error = getDataFromEDR.error
                        }
                        else {
                            DispatchQueue.main.async {
                                statusFinishOperation = .nodata
 //                               self.receiveResponseServerEDR(sattusOperation: .nodata)
                            }
   //                         return
                        }
                    }
                    else {
                         DispatchQueue.main.async {
 //                            self.receiveResponseServerEDR(sattusOperation: getDataFromEDR.statusFinishOperation)
                       }
                        if self.firms != nil {
                            self.firms.firms.removeAll()
                            DispatchQueue.main.async {
                                    self.tableFirm.reloadData()
                            }
                        }
 //                       return
                    }
                }
                //-333333
                let finishOperation = BlockOperation() {
                    if statusFinishOperation == .ok {
                        if let firms =  parserDataFromEDR.firms {
                            self.firms = firms
                            DispatchQueue.main.async {
                                let row = self.selectSearchField.selectedRow(inComponent: 1)
                                let orderField = self.arraySearchField[row][1]
                                self.sortByField(field : orderField)
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                 statusFinishOperation = parserDataFromEDR.statusFinishOperation
//                                self.receiveResponseServerEDR(sattusOperation: parserDataFromEDR.statusFinishOperation)
                            }
       //                     return
                        }
                    }
                    var countFirms = 0
                    if let firms = self.firms {
                        countFirms = firms.firms.count
                    }
                    let showDataFromEDR = ShowDataFromEDR(table: self.tableFirm, filteredImemsCount: countFirms, totalItemCount: countRInt, searchFooter: self.searchFooter, statusFinishOperation: statusFinishOperation, cancelView: self.cancelView )
                    self.getDataQueue.addOperation(showDataFromEDR)
                 }
                 //-333333
               
                fetchOperation.addDependency(getDataFromEDR)
                parserDataFromEDR.addDependency(fetchOperation)
                finishOperation.addDependency(parserDataFromEDR)
                self.getDataQueue.addOperations([getDataFromEDR, fetchOperation, parserDataFromEDR,finishOperation], waitUntilFinished: true)
            }
            //-222222
        }
        //-111111
    }
    
    

    
    func setUserInteractionEnabled(isUserInteractionEnabled: Bool, alpha: CGFloat) {
        self.tableFirm.isUserInteractionEnabled = isUserInteractionEnabled
        self.HeadView.isUserInteractionEnabled = isUserInteractionEnabled
//        self.searchController.searchBar.isUserInteractionEnabled = isUserInteractionEnabled
//        self.searchController.searchBar.alpha = alpha
        self.searchBarStoryBoard.isUserInteractionEnabled = isUserInteractionEnabled
        self.searchBarStoryBoard.alpha = alpha
        self.HeadView.alpha = alpha
        self.view.alpha = alpha
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FirmsToDetailes" {
            let controller = segue.destination as! CompanyDetailes
            let edrFirm = sender as? edrFirm
            controller.edrFirms = edrFirm
            controller.modelController = self.modelController

            var firmsCD = self.modelController.edrpouToFirmCoreData.filter { $0.edrpou == edrFirm!.edrpou }
            if firmsCD.count > 0 {
                controller.firmCoreData = firmsCD[0].firmCoreData
            }
      }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let firm = self.firms.firms[indexPath.row]
        performSegue(withIdentifier: "FirmsToDetailes", sender: firm)
        self.didSelectedTableView = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableFirm.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    

}


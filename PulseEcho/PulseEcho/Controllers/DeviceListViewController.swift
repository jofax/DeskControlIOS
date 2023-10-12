//
//  DeviceListViewController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-12.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import FontAwesome_swift
import EventCenter
import CoreBluetooth
import PanModal
import SPAlert
import EmptyStateKit
import SwiftEventBus

protocol DeviceListViewControllerDelegate {
    func toggleBleIndicator()
}

class DeviceListViewController: BaseController {

    //STORYBOARD OUTLETS
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var lblDetectedDevices: UILabel?
    @IBOutlet weak var btnRefreshDeviceList: UIButton?
    @IBOutlet weak var btnPairingMode: UIButton?
    @IBOutlet weak var refreshView: UIView?
    @IBOutlet weak var viewConnectedIndicator: UIView?
    @IBOutlet weak var viewConnectedIndicatorHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var lblPreviouslyConnected: UILabel?
    var boxIdentifier: SPIdentifier?

    var delegate: DeviceListViewControllerDelegate?
    var needOrgCodeToSyncData: Bool = false
    
     //CLASS VARIABLES
    var isLoadingList: Bool = true
    var selected: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SPBluetoothManager.shared.delegate = self
        SPBluetoothManager.shared.event = self.event
        
        let email = Utilities.instance.getUserEmail()
        createCustomNavigationBar(title: "ble_device_list.title".localize(), user: email, cloud: true, back: false, ble: false)
        customizeUI()
        addObserver()
        
        lblDetectedDevices?.adjustContentFontSize()
        btnRefreshDeviceList?.titleLabel?.adjustContentFontSize()
        registerDataListener()
//        if Utilities.instance.isFirstAppLaunch() {
//            btnPairingMode?.isEnabled = false
//            btnPairingMode?.setImage(nil, for: .normal)
//        } else {
//            btnPairingMode?.isEnabled = true
//            btnPairingMode?.setImage(UIImage(named: "ble_pair_device"), for: .normal)
//        }
        
        
        
    }
    
    override func customizeUI() {
        self.tableView?.tableFooterView = UIView()
        lblDetectedDevices?.text = "ble_device_list.detected_devices".localize()
        lblDetectedDevices?.adjustContentFontSize()
        
        view.emptyState.format = DataState.noBLEDevices.format
        view.emptyState.delegate = self
        
        
        btnRefreshDeviceList?.setImage(UIImage.fontAwesomeIcon(name: .sync,
                                                               style: .solid,
                                                               textColor: UIColor(hexString: Constants.smartpods_green),
                                                               size: CGSize(width: 40, height: 40)), for: .normal)
    }
    
    
    func registerDataListener() {
        // Need to unregister event listener to avoid duplicate data stream
        unregisterListener(name: ViewEventListenerType.DeviceListStream.rawValue)
        unregisterListener(name: ViewEventListenerType.PairScreenDataStream.rawValue)
        
        //Event to check core data stream from bluetooth
        SwiftEventBus.onMainThread(self, name: ViewEventListenerType.DeviceListStream.rawValue) { [weak self] result in
            let obj = result?.object
            
            print("ViewEventListenerType.DeviceListStream.rawValue: \(obj)")
            
            if obj is SPCoreObject {
                print("should dismiss the device listview")
                    SPBluetoothManager.shared.checkForDataStream()
                self?.unregisterListener(name: ViewEventListenerType.DeviceListStream.rawValue)
                
            }
            
        }
        
        SwiftEventBus.onMainThread(self, name: ViewEventListenerType.PairScreenDataStream.rawValue) { [weak self] result in
            let obj = result?.object
            
           
            if obj is SPIdentifier {
                
                let boxInformation = obj as? SPIdentifier
                    print("DEVICE LIST: SPIdentifier: \(String(describing: obj))")
                    Utilities.instance.saveDefaultValueForKey(value: String(format: "%@",boxInformation?.SerialNumber ?? ""), key: "serialNumber")
                    Utilities.instance.saveDefaultValueForKey(value: String(format: "%@",boxInformation?.RegistrationID ?? ""), key: "registrationID")
                    self?.updateDeviceConnectStatus(serial: boxInformation?.SerialNumber ?? "",registration: boxInformation?.RegistrationID ?? "" ,connected: true)
                    self?.unregisterListener(name: ViewEventListenerType.PairScreenDataStream.rawValue)
                
            }
        }
        
    }
    
    func unregisterListener(name: String) {
        SwiftEventBus.unregister(self, name: name)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 13.0, *) {
            guard SPBluetoothManager.shared.central.authorization == .allowedAlways else {
                return
            }
            scanDeviceList()
        } else {
            // Fallback on earlier versions
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIfAppIsBonded()
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //SwiftEventBus.unregister(self, name: ViewEventListenerType.DeviceListStream.rawValue)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //SwiftEventBus.unregister(self, name: ViewEventListenerType.DeviceListStream.rawValue)
    }
    
    deinit {
        //SwiftEventBus.unregister(self, name: ViewEventListenerType.DeviceListStream.rawValue)
    }
    
    @IBAction func onBtnActions(sender: UIButton) {
        switch sender.tag {
        case 0:
            if #available(iOS 13.0, *) {
                guard SPBluetoothManager.shared.central.authorization == .allowedAlways else {
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                        self.openSettingsApp()
                    })
                    self.displayAlertMessage(title: "permissions.title".localize(), message: "permissions.bluetooth_permission".localize(), successAction: ok)
                    return
                }
                scanDeviceList()
            } else {
                // Fallback on earlier versions
            }
        case 1:
            btnRefreshDeviceList?.tag = 0
            btnRefreshDeviceList?.setImage(UIImage.fontAwesomeIcon(name: .sync,
                                                                   style: .solid,
                                                                   textColor: UIColor(hexString: Constants.smartpods_green),
                                                                   size: CGSize(width: 40, height: 40)), for: .normal)
            btnRefreshDeviceList?.loadingIndicator(false)
            
            SPBluetoothManager.shared.central.stopScan()
            SPBluetoothManager.shared.state = .disconnected
            
        case 3:
            self.videoInstruction()
             break
        default:
            break
        }
        
        self.tableView?.reloadData()
    }
    
    /**
     Scan available BLE device.
     - Returns: none
     */
    
    func scanDeviceList() {
        //self.reloadRow(idx: self.selected ?? IndexPath(row: 0, section: 0))
        
        self.selected = nil
        SPBluetoothManager.shared.peripherals.removeAll()
        SPBluetoothManager.shared.advertisementData.removeAll()
        SPBluetoothManager.shared.questDevices.removeAll()
        SPBluetoothManager.shared.connectionAttempt = 0
        
        self.tableView?.reloadData()
        SPBluetoothManager.shared.scan()
        btnRefreshDeviceList?.setImage(nil, for: .normal)
        btnRefreshDeviceList?.loadingIndicator(true)
        btnRefreshDeviceList?.tag = 1
    }
    
    func checkIfAppIsBonded() {
        
        guard Utilities.instance.typeOfUserLogged() != .None else {
            return
        }
        
        let dataHelper = SPRealmHelper()
        let email = Utilities.instance.getLoggedEmail()
        do {
            let pulseData = try dataHelper.getPulseDevice(email)
            
            if pulseData.PeripheralName.isEmpty {
                self.lblPreviouslyConnected?.text = String(format: "It seems you are previously bonded to a device. Make sure it exist in the bluetooth settings and you can connect on it.", pulseData.PeripheralName)
            } else {
                self.lblPreviouslyConnected?.text = String(format: "It seems you are previously bonded to %@. Make sure it exist in the bluetooth settings and you can connect on it.", pulseData.PeripheralName)
            }
            
            self.lblPreviouslyConnected?.adjustContentFontSize()
                    
            if pulseData.Identifier.isEmpty {
                viewConnectedIndicator?.isHidden = true
                viewConnectedIndicatorHeightConstraint?.constant = 0
                viewConnectedIndicator?.layoutIfNeeded()
                
            } else {
                viewConnectedIndicator?.isHidden = false
                viewConnectedIndicatorHeightConstraint?.constant = 50
                viewConnectedIndicator?.layoutIfNeeded()
            }
        } catch {
            print("Realm getPulseDevice error | info: \(Utilities.instance.loginfo())")
        }
    }
    
    /**
     BLE connection event observer.
     - Returns: none
     */
    
    func addObserver() {
        self.event.addObserver(forEvent: Event.Name("bleconnection"), callback: { event in
            if let obj = event.object {
                let _peripheral = obj as? CBPeripheral
                print("_peripheral status: \(_peripheral?.state == .connected)) | info: \(Utilities.instance.loginfo())")
                self.reloadRow(idx: self.selected ?? IndexPath(row: 0, section: 0), connect: false)
            }
        })
    }
    
    func tableListStatus() {
        if SPBluetoothManager.shared.peripherals.count > 0 {
            self.view.emptyState.hide()
            self.tableView?.isHidden = false
            self.tableView?.reloadData()
            
        } else {
            self.tableView?.isHidden = true
            self.view.emptyState.show(DataState.noBLEDevices)
            
            
            //settingsBLEPopUp()
        }

    }

}

/**
 UITableView Delegate and Data Source
 */

extension DeviceListViewController: UITableViewDataSource, UITableViewDelegate, DeviceTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SPBluetoothManager.shared.peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Connect to device where the peripheral is connected
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceTableViewCell") as! DeviceTableViewCell
        cell.delegate = self
        let peripheral = SPBluetoothManager.shared.peripherals.item(at: indexPath.row)
        let deviceName = peripheral?.name ?? ""
        cell.indexPath = indexPath
        cell.currentSelected = (indexPath.row == selected?.row) ? true : false
        cell.deviceName = deviceName
        cell.questDevice = SPBluetoothManager.shared.questDevices.item(at: indexPath.row)
        if peripheral?.name == nil {
            cell.peripheralLabel?.text = "No Name"
        } else {
            cell.peripheralLabel?.text = deviceName
        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.reloadRow(idx: indexPath, connect: true)
        //Threads.performTaskAfterDealy(2) {
            self.connectToDevice(indexPath)
        //}
        
    }
    
    //DeviceTableViewCell Delegate
    func connectToDevice(_ index: IndexPath) {
        
        guard Utilities.instance.typeOfUserLogged() != .None else {
            return
        }
        
        self.selected = index
        
        let dataHelper = SPRealmHelper()
        let email = Utilities.instance.getLoggedEmail()
        
        do {
            let pulseData = try dataHelper.getPulseDevice(email)
            
            if pulseData.Identifier.isEmpty {
                SPBluetoothManager.shared.boxInBond = false
            }
                let peripheral = SPBluetoothManager.shared.peripherals[index.row]
                let advertisemenData = SPBluetoothManager.shared.advertisementData[index.row]
                
                let deviceName = advertisemenData["kCBAdvDataLocalName"] as? String ?? ""
                SPBluetoothManager.shared.advertiseName = deviceName
                SPBluetoothManager.shared.connect(peripheral: peripheral)
                self.reloadRow(idx: index, connect: true)
                
        } catch {
            print("Realm getPulseDevice error | info: \(Utilities.instance.loginfo())")
        }
        
    }
    
    
    
    func reloadRow(idx: IndexPath, connect: Bool) {
        DispatchQueue.main.async {
            let cell = self.tableView?.cellForRow(at: idx) as? DeviceTableViewCell
            var _quest = SPBluetoothManager.shared.questDevices.item(at: idx.row)
            _quest?.isConnecting = connect
            cell?.questDevice = _quest
            //cell?.connectStatus?.stopAnimating()
            cell?.checkStatus()
        }
    }
    
    func dismissDeviceList() {
        if let peripheral = SPBluetoothManager.shared.state.peripheral {
            SPBluetoothManager.shared.rememberPeripheral(peripheral: peripheral)
            
           // self.requestPulseData(type: .All)
            self.dismiss(animated: true, completion: {
                //SPBluetoothManager.shared.boxInBond = false
                self.delegate?.toggleBleIndicator()
            })
        }
    }
    
    func deviceNotInPairingMode() {
        Threads.performTaskAfterDealy(2.0) {
            self.alertBlePairPopUp()
        }
    }
    
    func settingsBLEPopUp() {
        let screenBounds = UIScreen.main.bounds
        let width = screenBounds.width - 20
        let height = screenBounds.height / 2
        
        
        let controller = AlertBLESettings.instantiateFromStoryboard(storyboard: "Settings") as! AlertBLESettings
        controller.delegate = self
        let alert = UIAlertController(style: .alert, title: "")
        alert.set(vc: controller, width: width, height: height)
        //controller.preferredContentSize = CGSize(width:screenBounds.width , height: height)
        alert.setValue(controller, forKey: "contentViewController")
        
    
        Threads.performTaskInMainQueue {
            alert.show()
        }
    }
}

extension DeviceListViewController: PanModalPresentable {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    var panScrollable: UIScrollView? {
        return nil
    }

    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(40)
    }

    var anchorModalToLongForm: Bool {
        return false
    }
}

/**
 SPBluetoothManager Delegate Methods
 */

extension DeviceListViewController: SPBluetoothManagerDelegate {
    
    func alertBlePairPopUp() {
        let alertView = SPAlertView(title: "Error", message: "Either the device is removed in the settings or not paired. Please try to scan and connect again.", image: UIImage(named: "pairing_mode")!)
        alertView.duration = 5
        DispatchQueue.main.async {
            alertView.present()
        }
    }
    
    func unableToPairWithBox() {
        
        DispatchQueue.main.async {
            Threads.performTaskAfterDealy(1.0) {
                self.alertBlePairPopUp()
            }
        }
       
    }
    
    func updateInterface() {
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView?.reloadData()
            self?.btnRefreshDeviceList?.loadingIndicator(false)
            self?.tableListStatus()
            self?.btnRefreshDeviceList?.setImage(UIImage.fontAwesomeIcon(name: .sync,
                                                                   style: .solid,
                                                                   textColor: UIColor(hexString: Constants.smartpods_green),
                                                                   size: CGSize(width: 40, height: 40)), for: .normal)
        }
    }
    
    func deviceConnected() {
        print("deviceConnected connected: \(SPBluetoothManager.shared.pulse)")
        
        Threads.performTaskInMainQueue {
            let cell = self.tableView?.cellForRow(at: self.selected ?? IndexPath(row: 0, section: 0)) as? DeviceTableViewCell
            cell?.checkStatus()
            self.tableView?.reloadData()
            
            if let peripheral = SPBluetoothManager.shared.state.peripheral {
                
                if SPBluetoothManager.shared.pulse == .Connected {
                    let device = ["State": PulseState.Connected.rawValue,
                                  "Identifier":peripheral.identifier.uuidString] as [String : Any]
                    self.PulseDeviceStateUpdate(params: device)
                    
                    print("needOrgCodeToSyncData : \(self.needOrgCodeToSyncData)")
                    
                   // check if org code is verified
                    
                    let email = Utilities.instance.getLoggedEmail()
                    let state = SPRealmHelper().getAppState(email)
                    
                    guard state.OrgCode.isEmpty == false else {
                        self.requestPulseData(type: .Info)
                        self.displayNotificationMessage(title: "success.title".localize(),
                                                        subTitle: "success.sync_data".localize(),
                                                        style: .info)
                        self.showActivityIndicator(show: true)
                        
                        Threads.performTaskAfterDealy(1.0) {
                            
                            self.requestPulseData(type: .All)
                            self.needOrgCodeToSyncData = false
                        }
                        
                        return
                    }
                    
                    self.dismiss(animated: true, completion: {
                        self.PulseUpdateConnectionStatus(peripheral: peripheral)
                    })
                    
                }
                
                if peripheral.state == .disconnected {
                    SPBluetoothManager.shared.connectionAttempt = 0
                    SPBluetoothManager.shared.disconnect(forget: true)
                    cell?.checkStatus()
                    self.tableView?.reloadData()
                    //self.alertBlePairPopUp()
                }
            } else {
               
            }
        }
            
    }
    
    func PulseUpdateConnectionStatus(peripheral: CBPeripheral) {
        self.delegate?.toggleBleIndicator()
        if (peripheral.spDesiredCharacteristic != nil) {
            print("deviceConnected connected request all | info: \(Utilities.instance.loginfo())")
            self.requestPulseData(type: .All)
            guard Utilities.instance.typeOfUserLogged() != .None else {
                return
            }
            
            let profileSettingsViewModel = ProfileSettingsViewModel()
            let SPCommand = PulseCommands()
            
            guard Utilities.instance.typeOfUserLogged() != .Guest else {
                #warning ("need to check if there is an existing profile string stored in the local storage")
                
                let profile = profileSettingsViewModel.getLocalUserProfileInformation(email: Utilities.instance.getLoggedEmail()) { (profile) in
                    let userProfile = SPCommand.CreateVerticalProfile(settings: profile)
                    self.sendACommand(command: userProfile, name: "SPCommand.CreateVerticalProfile")
                    
//                                    Threads.performTaskAfterDealy(2) {
//                                        print("PulseDataState adjustSitAndStandHeights: \(PulseDataState.instance.PulseDataValues())")
//                                        PulseDataState.instance.adjustSitAndStandHeights()
//                                    }
                }
                return
            }
            

            profileSettingsViewModel.getProfileSettings(completion: { (profile) in
                if profile.ProfileSettingType != -1 {
                    let userProfile = SPCommand.CreateVerticalProfile(settings: profile)
                    let setSit = SPCommand.GetSetDownCommand(value: Double(profile.SittingPosition))
                    let setStand = SPCommand.GetSetTopCommand(value: Double(profile.StandingPosition))

                    SPBluetoothManager.shared.pushProfileTotheBox(profile: userProfile, sit: setSit, stand: setStand)
                } else {
                    self.synchronizeUserProfileSettings(defaultProfile: true, profile: profile)
                }
                
            })
            
            Threads.performTaskAfterDealy(1.0) {
                self.requestPulseData(type: .All)
            }
            
        }
    }
    
    
    func pairConnectedDevice() {
        if let peripheral = SPBluetoothManager.shared.state.peripheral {
            //log.debug("pairConnectedDevice connected delagate: \(peripheral.state)")
            
            if peripheral.state == .connected{
                //Threads.performTaskAfterDealy(6) {
                    self.dismiss(animated: true, completion: {
                        //SPBluetoothManager.shared.boxInBond = false
                        self.delegate?.toggleBleIndicator()
                    })
                //}
            }
            
        }
    }
    
   func updateDeviceConnectivity(connect: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView?.reloadData()
            self?.reloadRow(idx: self?.selected ?? IndexPath(row: 0, section: 0), connect: connect)
        }
    }
    
    func connectivityState(title: String, message: String, code: Int) {
        //self.showAlert(title: title, message: message)
        self.reloadRow(idx: self.selected ?? IndexPath(row: 0, section: 0), connect: false)
        DispatchQueue.main.async {
            
            if code == 14 {
//                self.settingsBLEPopUp()
                self.dismiss(animated: true) {
                    self.settingsBLEPopUp()
                }
            } else {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            
        }
    }
}

extension DeviceListViewController: EmptyStateDelegate {
    
    func emptyState(emptyState: EmptyState, didPressButton button: UIButton) {
        //
        //
        let alert = UIAlertController(title: "Notice", message: "Do you want to refresh device list or go to the settings?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Settings", style: .default) {_ in
            self.openSettingsApp()
        })
        
        alert.addAction(UIAlertAction(title: "Refresh", style: .default) { _ in
            self.scanDeviceList()
        })
        
        self.present(alert, animated: true)
        
        view.emptyState.hide()
    }
}

extension DeviceListViewController: AlertBLESettingsDelegate {
    func dismissAlertBleSettings() {
        self.openSettingsApp()
    }
}

//
//  SPBluetoothManager.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-13.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import CoreBluetooth
import EventCenter
import SwiftEventBus
import CommonCrypto

typealias SPBluetoothPermissionHandler = ()->()?
typealias SPBluetoothManagerHandler = ()->()?
private let restoreIdKey = "SPBluetoothManager"
let peripheralIdDefaultsKey = "SPBluetoothManagerPeripheralId"
let pairingDefaultsKey = "SPBoxPairing"
private let outOfRangeHeuristics: Set<CBError.Code> = [.unknown,
                                                       .connectionTimeout,
                                                       .peripheralDisconnected,
                                                       .connectionFailed]

@objc enum BLETypeNotice: Int {
    case BLuetoothNotPowerOn
    case DESKNotice
    case AdapterError
}

/// A  protocol to update the UI when an event occurs
protocol SPBluetoothManagerDelegate: AnyObject {
    func updateInterface()
    func deviceConnected()
    func updateDeviceConnectivity(connect: Bool)
    func connectivityState(title: String, message: String, code: Int)
    func unableToPairWithBox()
}

enum PulseState: Int {
    case Unknown = 0
    case Scanning = 1
    case Connecting = 2
    case EnterPinCode = 3
    case BoxChangeName = 4
    case BoxReconnect = 5
    case Connected = 6
    case Disconnected = 7
    case BoxError = 8
    case ResetBond = 9
    case BLEShutOff = 10
}

/// A protocol that notify user for box connectivity

@objc protocol SPBluetoothManagerConnectivityDelegate: AnyObject {
    @objc optional func deviceNotInRange()
    @objc optional func shouldSetDeviceConnected(connected: Bool)
    @objc optional func noticeMessages(type: BLETypeNotice)
    @objc optional func resumeBleConnectivity()
    
}

class SPBluetoothManager {
    static let shared = SPBluetoothManager()
    var delegate: SPBluetoothManagerDelegate?
    var connectivityDelegate: SPBluetoothManagerConnectivityDelegate?
    private var completion: SPBluetoothPermissionHandler?
    
    
    var SPBLEServiceUUID = CBUUID()
    var SPBLEUUID = ""
    var SPBLEReadUUID = CBUUID()
    var SPBLEWriteUUID = CBUUID()
    var SPBLECharacteristic = CBUUID()
    var characteristicASCIIValue = NSString()
    var RSSIs = [NSNumber]()
    var data = NSMutableData()
    var writeData: String = ""
    var peripherals: [CBPeripheral] = []
    var advertisementData: [[String: Any]] = [[String: Any]]()
    var questDevices = [QuestDevice]()
    var blePeripheralAdvertisementData: [String: Any] = [String: Any]()
    var characteristicValue = [CBUUID: NSData]()
    var characteristics = [String : CBCharacteristic]()
    var event: EventCenter?
    var startReceivingData: Bool = false
    var isConnected: Bool = false
    var serialKeyPresent: Bool = false
    var isPairing: Bool = false
    var pairingDialogOpen = false
    
    let writeBleProperty = 10
    let readBleProperty = 26
    
    var SPSignalRSSI: Int = 0
    var connectionCount = 0
    var connectionAttempt = 0
    let connectionAttemptLimit = 1
    
    var didPairDevice = false
    var pairingResponse = ""
    var advertiseName = ""
    
    var defautlPairSSID: Bool = false
    var requestPairSSID: Bool = false
    
    var heartBeatSent: Bool = false
    
    var heartBeatSentCount = 0
    let heartBeatSentLimit = 2
    
    var pulse = PulseState.Unknown
    var mininumTimerScan = 10
    var minimuTimerConnect = 13
    var boxInBond: Bool = false
    var desktopApphasPriority: Bool = false
    var AppHeartbeatSetRetry: Bool = false
    var HeartbeatRetryLimit: Int = 10
    let PulseDeviceActivityTimer = SPTimeScheduler(timeInterval: 10)
    let PulseHeartbeatReconnectTimer = SPTimeScheduler(timeInterval: 10)
    let PulseDeviceReconnectWhenTimeout = SPTimeScheduler(timeInterval: 15)
    var AdapterError: Bool = false
    
    var BLECLOSURE: SPBluetoothManagerHandler?
    let profileSettingsViewModel = ProfileSettingsViewModel()
    let SPCommand = PulseCommands()
    let BLEStreamParser: BLEDataParser = BLEDataParser()
    
    var retryTimerLimit = 10
    var retryTimerCount = 0
    
    var isAuthorized: Bool {
        if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .allowedAlways
        }
        return CBPeripheralManager.authorizationStatus() == .authorized
    }
    
    var isDenied: Bool {
        if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .denied
        }
        return CBPeripheralManager.authorizationStatus() == .denied
    }
    
    var isBluetoothPermissionGranted: Bool {
        if #available(iOS 13.1, *) {
            return CBCentralManager.authorization == .allowedAlways
        } else if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .allowedAlways
        }
        // Before iOS 13, Bluetooth permissions are not required
        return true
    }
    //var central: CBCentralManager =  CBCentralManager()
    
    var central = CBCentralManager(delegate: SPCentralManagerDelegate.shared,
                               queue: DispatchQueue(label: "BT_queue"),
                                    options: [
                                                        CBCentralManagerOptionShowPowerAlertKey: true,
                                                        CBCentralManagerOptionRestoreIdentifierKey: restoreIdKey,
                                                        CBCentralManagerScanOptionAllowDuplicatesKey: false
    ])
    
    /// The 'state machine' for remembering where we're up to.
    var state = State.disconnected
    enum State {
        case poweredOff
        case restoringConnectingPeripheral(CBPeripheral)
        case restoringConnectedPeripheral(CBPeripheral)
        case disconnected
        case scanning(Countdown)
        case connecting(CBPeripheral, Countdown)
        case discoveringServices(CBPeripheral, Countdown)
        case discoveringCharacteristics(CBPeripheral, Countdown)
        case connected(CBPeripheral)
        case outOfRange(CBPeripheral)
        case unsupported
        case unauthorized
        case resetting
        case unknown
        
        
        var peripheral: CBPeripheral? {
            switch self {
            case .poweredOff: return nil
            case .restoringConnectingPeripheral(let p): return p
            case .restoringConnectedPeripheral(let p): return p
            case .disconnected: return nil
            case .scanning: return nil
            case .connecting(let p, _): return p
            case .discoveringServices(let p, _): return p
            case .discoveringCharacteristics(let p, _): return p
            case .connected(let p): return p
            case .outOfRange(let p): return p
            case .unsupported: return nil
            case .unauthorized: return nil
            case .resetting: return nil
            case .unknown: return nil
            }
        }
    }
    
    func initializeBleCentral(completion: @escaping ()->()?) {
        self.completion = completion
    }
    
    // Begin scanning here!
    func scan() {
        if LOGS.BUILDTYPE.boolValue == false {
            print("central?.state: \(central.state.rawValue) | info: \(Utilities.instance.loginfo())")
        } else {
            print("central?.state: \(central.state.rawValue) | info: \(Utilities.instance.loginfo())")
        }
        guard central.state == .poweredOn else {
            if LOGS.BUILDTYPE.boolValue == false {
                print("Cannot scan, BT is not powered on | info: \(Utilities.instance.loginfo())")
            } else {
                print("Cannot scan, BT is not powered on | info: \(Utilities.instance.loginfo())")
            }
            self.connectivityDelegate?.noticeMessages?(type: .BLuetoothNotPowerOn)
            return
        }
        // Scan!
        central.scanForPeripherals(withServices: [CBUUID(string: "0D18")], options: nil)
        state = .scanning(Countdown(seconds: TimeInterval(mininumTimerScan), closure: {
            self.central.stopScan()
            self.state = .disconnected
            self.delegate?.updateInterface()
            self.connectionCount = 0
        }))
        pulse = .Scanning
        
    }
    
    /// Call this with forget: true to do a proper unpairing such that it won't
    /// try reconnect next startup.
    func disconnect(forget: Bool) {
        if let peripheral = state.peripheral {
            central.cancelPeripheralConnection(peripheral)
        }
        state = .disconnected
        pulse = .Disconnected
        isConnected = false
        isPairing = false
        didPairDevice = false
        desktopApphasPriority = false
        PulseDataState.instance.isDeskCurrentlyBooked = false
        PulseDataState.instance.isDeskHasIncomingBooking = false
        PulseDataState.instance.bookingSchedulerCount = 0
        PulseDataState.instance.deskCurrentlyBookAlertCount = 0
        connectionAttempt = 0
        heartBeatSentCount = 0
        SwiftEventBus.post(ViewEventListenerType.BLEConnectivityStream.rawValue, sender: self)
        self.connectivityDelegate?.shouldSetDeviceConnected?(connected: false)
        Utilities.instance.removeObjectFromDefaults(key: "serialNumber")
        Utilities.instance.removeObjectFromDefaults(key: "registrationID")
        Utilities.instance.removeObjectFromDefaults(key: "heartBeatDetected")
        Utilities.instance.saveDefaultValueForKey(value: false, key: pairingDefaultsKey)
        PulseDataState.instance.truncatedAlertShown = 0
        SPBluetoothManager.shared.delegate?.updateInterface()
        SPBluetoothManager.shared.delegate?.deviceConnected()

    }

    func connect(peripheral: CBPeripheral) {
        // Connect!
        // Note: We're retaining the peripheral in the state enum because Apple
        // says: "Pending attempts are cancelled automatically upon
        // deallocation of peripheral"
        connectionAttempt += 1
        print("func connect(peripheral: CBPeripheral) : ", state)
        
        isPairing = true
        central.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnNotificationKey: true,
                                              CBConnectPeripheralOptionNotifyOnConnectionKey: true,
                                              CBConnectPeripheralOptionNotifyOnDisconnectionKey: true])
        
        state = .connecting(peripheral, Countdown(seconds: TimeInterval(minimuTimerConnect), closure: {
            self.central.cancelPeripheralConnection(peripheral)
            self.state = .disconnected
            self.pulse = .Disconnected
            self.isPairing = false
            
            if LOGS.BUILDTYPE.boolValue == false {
                print("Connect timed out | info: \(Utilities.instance.loginfo())")
            } else {
                print("Connect timed out | info: \(Utilities.instance.loginfo())")
            }
            
            SPBluetoothManager.shared.desktopApphasPriority = false
            PulseDataState.instance.isDeskCurrentlyBooked = false
            SPBluetoothManager.shared.connectionAttempt = 0
            SPBluetoothManager.shared.defautlPairSSID = false
            SPBluetoothManager.shared.requestPairSSID = false
            SPBluetoothManager.shared.PulseHeartbeatReconnectTimer.suspend()
            self.delegate?.deviceConnected()
            self.delegate?.unableToPairWithBox()
        }))
        pulse = .Connecting
    }
    
    func discoverServices(peripheral: CBPeripheral) {
        
        if LOGS.BUILDTYPE.boolValue == false {
            print("discoverServices called | info: \(Utilities.instance.loginfo())")
        } else {
            print("discoverServices called | info: \(Utilities.instance.loginfo())")
        }
        
        peripheral.delegate = SPPeripheralDelegate.shared
        peripheral.discoverServices([BLEService_UUID])
        state = .discoveringServices(peripheral, Countdown(seconds: TimeInterval(minimuTimerConnect), closure: {
            self.disconnect(forget: false)
            if LOGS.BUILDTYPE.boolValue == false {
                print("Could not discover services | info: \(Utilities.instance.loginfo())")
            } else {
                print("Could not discover services | info: \(Utilities.instance.loginfo())")
            }
        }))
        pulse = .Connecting
    }
    
    func discoverCharacteristics(peripheral: CBPeripheral) {
        if LOGS.BUILDTYPE.boolValue == false {
            print("discoverCharacteristics called | info: \(Utilities.instance.loginfo())")
        } else {
            print("discoverCharacteristics called | info: \(Utilities.instance.loginfo())")
        }
        
        guard let myDesiredService = peripheral.spDesiredService else {
            self.disconnect(forget: false)
            return
        }
        
        peripheral.delegate = SPPeripheralDelegate.shared
        peripheral.discoverCharacteristics([BLE_Characteristic_uuid_Tx], for: myDesiredService)
        
        
        state = .discoveringCharacteristics(peripheral, Countdown(seconds: TimeInterval(minimuTimerConnect),
            closure: {
            self.disconnect(forget: false)
                if LOGS.BUILDTYPE.boolValue == false {
                    print("Could not discover characteristics | info: \(Utilities.instance.loginfo())")
                } else {
                    print("Could not discover characteristics | info: \(Utilities.instance.loginfo())")
                }
        }))
        pulse = .Connecting
    }

    func setConnected(peripheral: CBPeripheral) {
            
            guard let spCharacteristic = peripheral.spDesiredCharacteristic else {
               print("Missing characteristic")
                self.disconnect(forget: false)
               return
           }
            

            //print("notify UI if BLE is connected")
            
            state = .connected(peripheral)
            pulse = .Connected
            SPBluetoothManager.shared.startReceivingData = true
            
            DispatchQueue.main.async {
                SPBluetoothManager.shared.delegate?.updateInterface()
                SPBluetoothManager.shared.delegate?.deviceConnected()
                SPBluetoothManager.shared.delegate?.updateDeviceConnectivity(connect: false)
                
            }
        
            peripheral.setNotifyValue(true, for: spCharacteristic)
        
            SPBluetoothManager.shared.connectivityDelegate?.noticeMessages?(type: .DESKNotice)
            SwiftEventBus.post(ViewEventListenerType.BLEConnectivityStream.rawValue, sender: self)
            //self.event?.post(event: Event.Name("UserProfileDeviceConnectivity"))
            //self.sendHeartBeat(peripheral, peripheral.spDesiredCharacteristic!)
            
            didPairDevice = true
            rememberPeripheral(peripheral: peripheral)
        
            
            
        }
    
    func rememberPeripheral(peripheral: CBPeripheral) {
        
        if LOGS.BUILDTYPE.boolValue == false {
            print("rememberPeripheral: \(peripheral.identifier.uuidString) | info: \(Utilities.instance.loginfo())")
        } else {
            print("rememberPeripheral: \(peripheral.identifier.uuidString) | info: \(Utilities.instance.loginfo())")
        }
        
        UserDefaults.standard.set(peripheral.identifier.uuidString,
                forKey: peripheralIdDefaultsKey)        
        UserDefaults.standard.synchronize()
        let device = ["Identifier":peripheral.identifier.uuidString,
                      "PeripheralName": peripheral.name ?? "",
                      "State":PulseState.Connected.rawValue,
                      "DisconnectedByUser": false] as [String : Any]
        
        pulseObjectParameters(parameters: device)
    }
    
    func forgetPeripheral(forget: Bool) {
        connectionAttempt = 0
        PulseDeviceReconnectWhenTimeout.suspend()
        let device = ["Identifier":"",
                      "PeripheralName": "",
                      "State":PulseState.Disconnected.rawValue,
                      "DisconnectedByUser": false] as [String : Any]
        
        pulseObjectParameters(parameters: device)
        
        if forget {
            UserDefaults.standard.removeObject(forKey: peripheralIdDefaultsKey)
            UserDefaults.standard.synchronize()
        }
        
    }
    
    func getAdvertiseName(peripheral: CBPeripheral) -> String {
        let getAdvertisePeripheral = SPBluetoothManager.shared.advertisementData.filter { (devices) -> Bool in
            let advertiseName = devices["kCBAdvDataLocalName"] as? String ?? ""
            return advertiseName == peripheral.name
        }
        
        if getAdvertisePeripheral.count != 0 {
            let advertisePeripheral = getAdvertisePeripheral[0]
            let advertiseName = advertisePeripheral["kCBAdvDataLocalName"] as? String ?? ""
            return advertiseName
        } else {
            return ""
        }
        
    }
    
    /// Write data to the peripheral.
    func sendCommand(command: [UInt8]) throws {
        
        if LOGS.BUILDTYPE.boolValue == false {
            print("sendCommand: \(command) | info: \(Utilities.instance.loginfo())")
        } else {
            print("sendCommand: \(command) | info: \(Utilities.instance.loginfo())")
        }
        
        let _command =  Data.init(command)
        
        guard _command.count > 0 else { throw Errors.invalidCommand }
        
        guard case .connected(let peripheral) = state else {
            if LOGS.BUILDTYPE.boolValue == false {
                print("peripheral state: \(state) | info: \(Utilities.instance.loginfo())")
            } else {
                print("peripheral state: \(state) | info: \(Utilities.instance.loginfo())")
            }
           //handle command checking if state is not connected
            throw Errors.notConnected
        }
        
        guard let characteristic = peripheral.spDesiredCharacteristic else {
            if LOGS.BUILDTYPE.boolValue == false {
                print("missing command characteristics for peripheral: \(peripheral) | info: \(Utilities.instance.loginfo())")
            } else {
                print("missing command characteristics for peripheral: \(peripheral) | info: \(Utilities.instance.loginfo())")
            }
            throw Errors.missingCharacteristic
        }
        
        peripheral.writeValue(_command, for: characteristic, type: .withResponse)
    }
    
    enum Errors: Error {
        case notConnected
        case missingCharacteristic
        case invalidCommand
    }
    
    func cleanup() {
        // Don't do anything if we're not connected

        if let peripheral = state.peripheral {
            for service in (peripheral.services ?? [] as [CBService]) {
                for characteristic in (service.characteristics ?? [] as [CBCharacteristic]) {
                    if characteristic.uuid == peripheral.spDesiredCharacteristic && characteristic.isNotifying {
                        // It is notifying, so unsubscribe
                        peripheral.setNotifyValue(false, for: characteristic)
                    }
                }
            }
            central.cancelPeripheralConnection(peripheral)
        }
        
        
    }
    
    func getPeripheralServices(_ peripheral: CBPeripheral) -> CBService? {
           guard let services = peripheral.services else {
               return nil
           }
        
        guard peripheral.services?.count ?? 0 > 0 else {
            return nil
        }
        
           let _service = services[0]
           SPBluetoothManager.shared.SPBLEServiceUUID = _service.uuid
           return _service
    }
    
    func sendHeartBeat(_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic) {
           print("heartBeatSentCount before: ", heartBeatSentCount)
           guard heartBeatSentCount < heartBeatSentLimit && heartBeatSentCount != heartBeatSentLimit else {
               return
           }
           print("heartBeatSentCount after: ", heartBeatSentCount)
           heartBeatSentCount += 1
           
           DispatchQueue.main.async {
               let state = UIApplication.shared.applicationState
               if state == .active {
                   let packet = SPRequestParameters.BLEHeartbeatForeground
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("heartbeat should be sent in one minute : \(packet) | foreground | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("heartbeat should be sent in one minute : \(packet) | foreground | info: \(Utilities.instance.loginfo())")
                    }
                   
                   do {
                       if (packet.count > 0) {
                        if LOGS.BUILDTYPE.boolValue == false {
                            print("COMMAND NAME:sendHeartBeat | info: \(Utilities.instance.loginfo())")
                        } else {
                            print("COMMAND NAME:sendHeartBeat | info: \(Utilities.instance.loginfo())")
                        }
                           try self.sendCommand(command: packet)
                       }
                       
                   } catch let error as NSError {
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("error sending  command: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                        print("error sending  command with state: \(state) | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("error sending  command: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                        print("error sending  command with state: \(state) | info: \(Utilities.instance.loginfo())")
                    }
                   } catch {
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("Unable to send command | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("Unable to send command | info: \(Utilities.instance.loginfo())")
                    }
                   }
               }
               
               else if state == .background {
                   let packet = SPRequestParameters.BLEHeartbeatBackground
                   
                if LOGS.BUILDTYPE.boolValue == false {
                    print("heartbeat should be sent in one minute : \(packet) | background | info: \(Utilities.instance.loginfo())")
                } else {
                    print("heartbeat should be sent in one minute : \(packet) | background | info: \(Utilities.instance.loginfo())")
                }
                   
                do {
                    if (packet.count > 0) {
                     if LOGS.BUILDTYPE.boolValue == false {
                         print("COMMAND NAME:sendHeartBeat | info: \(Utilities.instance.loginfo())")
                     } else {
                         print("COMMAND NAME:sendHeartBeat | info: \(Utilities.instance.loginfo())")
                     }
                        try self.sendCommand(command: packet)
                    }
                    
                } catch let error as NSError {
                 if LOGS.BUILDTYPE.boolValue == false {
                     print("error sending  command: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                     print("error sending  command with state: \(state) | info: \(Utilities.instance.loginfo())")
                 } else {
                     print("error sending  command: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                     print("error sending  command with state: \(state) | info: \(Utilities.instance.loginfo())")
                 }
                } catch {
                 if LOGS.BUILDTYPE.boolValue == false {
                     print("Unable to send command | info: \(Utilities.instance.loginfo())")
                 } else {
                     print("Unable to send command | info: \(Utilities.instance.loginfo())")
                 }
                }
               }
           }
          
       }
    
    func getLatestProfile() {
        
        let dataHelper = SPRealmHelper()
        let email = Utilities.instance.getLoggedEmail()
        
        guard dataHelper.profileExists(email) == false else {
            if Utilities.instance.isBLEBoxConnected() {
                profileSettingsViewModel.getLocalUserProfileInformation(email: Utilities.instance.getLoggedEmail()) { (profile) in
                    
                    let userProfile = self.SPCommand.CreateVerticalProfile(settings: profile)
                    let setSit = self.SPCommand.GetSetDownCommand(value: Double(profile.SittingPosition))
                    let setStand = self.SPCommand.GetSetTopCommand(value: Double(profile.StandingPosition))
                    self.pushProfileTotheBox(profile: userProfile, sit: setSit, stand: setStand)
                }
            }
            
            return
        }
        
        if let peripheral = SPBluetoothManager.shared.state.peripheral {
            if peripheral.spDesiredCharacteristic != nil {
                do {
                    try self.sendCommand(command: SPRequestParameters.Profile)
                } catch let error as NSError {
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("error sending  command getLatestProfile: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("error sending  command getLatestProfile: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                    }
                } catch {
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("Unable to send command getLatestProfile | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("Unable to send command getLatestProfile | info: \(Utilities.instance.loginfo())")
                    }
                }
            }
            
        }
    }
    
    func pushProfileTotheBox(profile: [UInt8], sit: [UInt8], stand: [UInt8]) {
        
        if let peripheral = SPBluetoothManager.shared.state.peripheral {
            if peripheral.spDesiredCharacteristic != nil {
                Threads.performTaskAfterDealy(0.5) {
                    do {
                        try self.sendCommand(command: profile)
                    } catch let error as NSError {
                        if LOGS.BUILDTYPE.boolValue == false {
                            print("error sending  command defaultProfile: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                        } else {
                            print("error sending  command defaultProfile: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                        }
                    } catch {
                        if LOGS.BUILDTYPE.boolValue == false {
                            print("Unable to send command defaultProfile | info: \(Utilities.instance.loginfo())")
                        } else {
                            print("Unable to send command defaultProfile | info: \(Utilities.instance.loginfo())")
                        }
                    }
                }
                
                Threads.performTaskAfterDealy(0.5) {

                    do {
                        try self.sendCommand(command: sit)
                        try self.sendCommand(command: stand)
                    } catch let error as NSError {
                        if LOGS.BUILDTYPE.boolValue == false {
                            print("error sending  command setSit: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                        } else {
                            print("error sending  command setSit: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                        }
                    } catch {
                        if LOGS.BUILDTYPE.boolValue == false {
                            print("Unable to send command setStands | info: \(Utilities.instance.loginfo())")
                        } else {
                            print("Unable to send command setStands | info: \(Utilities.instance.loginfo())")
                        }
                    }
                }
            }
            
        } else {
            if LOGS.BUILDTYPE.boolValue == false {
                print("Device not connected and unable to pushProfileTotheBox | info: \(Utilities.instance.loginfo())")
            } else {
                print("Device not connected and unable to pushProfileTotheBox | info: \(Utilities.instance.loginfo())")
            }
        }
    }
    
    func changePeripheralNameHeartbeat(_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic) {
        let request = SPRequestParameters()
        let bytes = request.SPRequestDataObject(parameters: SPRequestParameters.BLEHearbeatWithName)
        
        //print("changePeripheralNameHeartbeat: \(SPRequestParameters.BLEHearbeatWithName)")
        peripheral.writeValue(bytes, for: characteristic, type: .withResponse)
    }
    
    func sendRequestAllData(_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic) {
        let request = SPRequestParameters()
        let bytes = request.SPRequestDataObject(parameters: SPRequestParameters.All)
        peripheral.writeValue(bytes, for: characteristic, type: .withResponse)
    }
    
    func sendRequestProfile(_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic) {
        let request = SPRequestParameters()
        let bytes = request.SPRequestDataObject(parameters: SPRequestParameters.Profile)
        peripheral.writeValue(bytes, for: characteristic, type: .withResponse)
    }
    
    func sendRequestInformation(_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic) {
        let request = SPRequestParameters()
        let bytes = request.SPRequestDataObject(parameters: SPRequestParameters.Information)
        peripheral.writeValue(bytes, for: characteristic, type: .withResponse)
    }
    
    func assignBleService(_ peripheral: CBPeripheral) {
        guard let device = peripheral.services?.first else {
            SPBluetoothManager.shared.discoverServices(peripheral: peripheral)
            return
        }
        
        let _uuid: CBUUID = device.uuid

        Utilities.instance.saveDefaultValueForKey(value: _uuid.uuidString, key: Constants.SPBLEUUID)

        SPBLEServiceUUID = _uuid
        SPBLEUUID = _uuid.uuidString
        
        guard peripheral.spDesiredService != nil else {
                  SPBluetoothManager.shared.discoverServices(peripheral: peripheral)
                   return
               }

       // Progress to the next step.
       SPBluetoothManager.shared.discoverCharacteristics(peripheral: peripheral)
    }
    
    func testIfAppIsBonded(_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic) {
        _ = SPRequestParameters()
        //let bytes = request.SPRequestDataObject(parameters: SPRequestParameters.BLEHeartbeat)
        //print("heartbeat should be sent in one minute : \(SPRequestParameters.BLEHeartbeat)")
        //peripheral.writeValue(bytes, for: characteristic, type: .withResponse)
    }
    
    func SPBleError(_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic, _ error: Error?) {
        if let _error = error {
            let errorCode = (_error as NSError).code
            _ = (_error as NSError).localizedDescription
            
            if LOGS.BUILDTYPE.boolValue == false {
                print("SPBleError errorCode: \(errorCode) | info: \(Utilities.instance.loginfo())")
                print("SPBleError error: \(_error) | info: \(Utilities.instance.loginfo())")
            } else {
                print("SPBleError errorCode: \(errorCode) | info: \(Utilities.instance.loginfo())")
                print("SPBleError error: \(_error) | info: \(Utilities.instance.loginfo())")
            }
            
            if errorCode == 15 {
                Utilities.instance.saveDefaultValueForKey(value: false, key: pairingDefaultsKey)
                SPBluetoothManager.shared.isPairing = false
                SPBluetoothManager.shared.delegate?.connectivityState(title: "Error", message: "generic.invalid_pin_code".localize(), code: 15)
                SPBluetoothManager.shared.cleanup()
                SPBluetoothManager.shared.pairingDialogOpen = false
                SPBluetoothManager.shared.disconnect(forget: true)
                SPBluetoothManager.shared.didPairDevice = false
                SPBluetoothManager.shared.boxInBond = false
                SPBluetoothManager.shared.delegate?.updateDeviceConnectivity(connect: false)
            }
            
        }
    }
    
    func SPBLEResponse(_ peripheral: CBPeripheral, _ characteristic: CBCharacteristic) {
        
        guard characteristic.value != nil else {
            print("SPBLEResponse Failed")
            return
        }
        
        let data = (characteristic.value)!
        let nsdataStr = NSData.init(data: data)
        let str = nsdataStr.description.trimmingCharacters(in:Constants.charSet).replacingOccurrences(of: " ", with: "")
        
        if LOGS.BUILDTYPE.boolValue == false {
            //print("SPBLEResponse characteristic value: \(str)")
        } else {
            //print("SPBLEResponse characteristic value: \(str)")
        }
        
        //if (str.hasPrefix("1424")) {
            //print("BLEPairingSuccessResponse :\(str) )")
        //}
        
        if str.matches(Constants.HexadecimalRegex) {
            
            DispatchQueue.main.async {
                let characteristicData = characteristic.value ?? Data()
                let rawStrValue = characteristicData.hexEncodedString()
                
                if rawStrValue.hasPrefix(Constants.BLEPairingSuccessResponse) && SPBluetoothManager.shared.isPairing {
                    //print("BLEPairingSuccessResponse :\(rawStrValue)")
                    SPBluetoothManager.shared.connectionCount = 0
                    SPBluetoothManager.shared.boxInBond = false
                    SPBluetoothManager.shared.pairingDialogOpen = false
                    SPBluetoothManager.shared.isPairing = false
                    SPBluetoothManager.shared.requestPairSSID = false
                    SPBluetoothManager.shared.defautlPairSSID = false
                    SPBluetoothManager.shared.desktopApphasPriority = false
                    PulseDataState.instance.isDeskCurrentlyBooked = false
                    SPBluetoothManager.shared.setConnected(peripheral: peripheral)
                    
                } else if rawStrValue.hasPrefix(Constants.PairingDesktopPriorityResponse) ||
                            rawStrValue.hasPrefix(Constants.InvalidateCommandResponse) ||
                            rawStrValue.hasPrefix(Constants.DesktopAppPriorityResponse) {
                    print("PairingDesktopPriorityResponse | InvalidateCommandResponse | DesktopAppPriorityResponse :\(rawStrValue)")
                    SPBluetoothManager.shared.desktopApphasPriority = true
                    PulseDataState.instance.isDeskCurrentlyBooked = false
                    SwiftEventBus.post(ViewEventListenerType.BLEConnectivityStream.rawValue, sender: self)
                    //SPBluetoothManager.shared.setConnected(peripheral: peripheral)
                    
                } else if rawStrValue.hasPrefix(Constants.NewBlePairAttemptResponse) {
                    print("NewBlePairAttemptResponse :\(rawStrValue)")
                    self.disconnect(forget: true)
                    self.forgetPeripheral(forget: true)
                    SPBluetoothManager.shared.boxInBond = false
                    
                    SPBluetoothManager.shared.desktopApphasPriority = true
                    PulseDataState.instance.isDeskCurrentlyBooked = false
                    Utilities.instance.displayStatusNotification(title: "Device disconnected, new paring request was initiated.", style: .danger)
                    
                } else if rawStrValue.hasPrefix(Constants.ResumeNormalBLEDataResponse) {
                    print("ResumeNormalBLEDataResponse :\(rawStrValue)")
                    SPBluetoothManager.shared.desktopApphasPriority = false
                    PulseDataState.instance.isDeskCurrentlyBooked = false
                    Utilities.instance.dismissStatusNotification()
                    SwiftEventBus.post(ViewEventListenerType.BLEConnectivityStream.rawValue, sender: self)
                    self.SPStreamData(data: rawStrValue)
                    SPBluetoothManager.shared.connectivityDelegate?.resumeBleConnectivity?()
                    
                } else if rawStrValue.hasPrefix(Constants.BLEGenericError) {
                    
                    print("set adapter check timer with response 4e")
                    SPBluetoothManager.shared.PulseDeviceActivityTimer.resume()
                    
                } else {
                    //print("SPStreamData sending")
                    self.SPStreamData(data: rawStrValue)
                }
            }
            
        } else {
            // parse string with predefine string
            DispatchQueue.main.async {
                if let ASCIIstring = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) {
                     SPBluetoothManager.shared.characteristicASCIIValue = ASCIIstring

                     let _rawString = (SPBluetoothManager.shared.characteristicASCIIValue as String)
                    //BLEDataParser().initWithString(raw: _rawString)
                    self.SPStreamData(data: _rawString)
                }
            }
        }
    }
    
    func SPStreamData(data: String) {
        //print("SPStreamData : \(data)")
        //SPBluetoothManager.shared.AppHeartbeatSetRetry = false
        self.PulseDeviceActivityTimer.suspend()
        SPBluetoothManager.shared.isConnected = true
        SPBluetoothManager.shared.AdapterError = false
        
        
        SPBluetoothManager.shared.characteristicASCIIValue = data as NSString
        BLEDataParser().initWithHexString(raw: data)
    }
    
    func PulseDeviceActivityCheck() {
        
        if let peripheral = SPBluetoothManager.shared.state.peripheral {
            guard peripheral.state == .connected else {
                return
            }
            
            PulseDeviceActivityTimer.eventHandler = {
                if LOGS.BUILDTYPE.boolValue == false {
                    print("PulseDeviceActivityTimer timer Scheduler Fired | info: \(Utilities.instance.loginfo())")
                } else {
                    print("PulseDeviceActivityTimer timer Scheduler Fired | info: \(Utilities.instance.loginfo())")
                }
                SPBluetoothManager.shared.connectivityDelegate?.noticeMessages?(type: .AdapterError)
                self.PulseDeviceActivityTimer.suspend()
            }

        }
        
    }
    
    func heartbeatReconnectTimer() {
        PulseHeartbeatReconnectTimer.eventHandler = {
            self.heartBeatSentCount = 0
            
            if LOGS.BUILDTYPE.boolValue == false {
                print("HeartBeatRetryTimer timer Scheduler Fired | info: \(Utilities.instance.loginfo())")
            } else {
                print("HeartBeatRetryTimer timer Scheduler Fired | info: \(Utilities.instance.loginfo())")
            }
            
            if let peripheral = SPBluetoothManager.shared.state.peripheral {
                guard peripheral.state == .connected else {
                    return
                }
                
                if (peripheral.spDesiredCharacteristic != nil) {
                    SPBluetoothManager.shared.sendHeartBeat(peripheral, peripheral.spDesiredCharacteristic!)
                }

            } else {
                self.PulseHeartbeatReconnectTimer.suspend()
            }
        }
        
       
    }
    
    func pulseDeviceReconnectTimer() {
        PulseDeviceReconnectWhenTimeout.eventHandler = {
            
            if LOGS.BUILDTYPE.boolValue == false {
                print("pulseDeviceReconnectTimer timer Scheduler Fired | info: \(Utilities.instance.loginfo())")
            } else {
                print("pulseDeviceReconnectTimer timer Scheduler Fired | info: \(Utilities.instance.loginfo())")
            }
            
            self.connectionAttempt = 0
            let email = Utilities.instance.getLoggedEmail()
            let dataHelper = SPRealmHelper()
            if email.isEmpty == false,
               let peripheralIdStr = dataHelper.getDeviceConnectedIdentifier(email) as? String,
                let peripheralId = UUID(uuidString: peripheralIdStr),
                let previouslyConnected = SPBluetoothManager.shared.central
                    .retrievePeripherals(withIdentifiers: [peripheralId])
                    .first {
                
                print("previouslyConnected.state: ", previouslyConnected.state.rawValue)

                if previouslyConnected.state == .connected {
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("centralManagerDidUpdateState retrievePeripherals: \(previouslyConnected) | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("centralManagerDidUpdateState retrievePeripherals: \(previouslyConnected) | info: \(Utilities.instance.loginfo())")
                    }
                    
                    if let peripheral = SPBluetoothManager.shared.state.peripheral {
                        if peripheral.spDesiredCharacteristic != nil {
                            SPBluetoothManager.shared.sendHeartBeat(peripheral, peripheral.spDesiredCharacteristic!)
                            SPBluetoothManager.shared.sendRequestAllData(peripheral, peripheral.spDesiredCharacteristic!)
                        }
                    } else {
                        SPBluetoothManager.shared.connect(peripheral: previouslyConnected)
                    }
                } else {
                    SPBluetoothManager.shared.connect(peripheral: previouslyConnected)
                }
            }
        }
        
       
    }
    
    func pulseObjectParameters(parameters: [String: Any]) {
        let serial = Utilities.instance.getObjectFromUserDefaults(key: "serialNumber") as? String ?? ""
        
       var _params =  parameters
        _params["Serial"] = serial
        
        updatePulseData(device: _params)
    }
    
    func updatePulseData(device: [String: Any]) {
        guard Utilities.instance.typeOfUserLogged() != .None else {
            return
        }
        
        let dataHelper = SPRealmHelper()
        let email = Utilities.instance.getLoggedEmail()
        _ = dataHelper.updatePulseObject(device, email)

    }

    func requestWriteToCharacteristic(_ command: [UInt8], _ peripheral: CBPeripheral, _ characteristic: CBCharacteristic) {
        if LOGS.BUILDTYPE.boolValue == false {
            print("requestWriteToCharacteristic : \(command) | info: \(Utilities.instance.loginfo())")
        } else {
            print("requestWriteToCharacteristic : \(command) | info: \(Utilities.instance.loginfo())")
        }
        
        do {
            if LOGS.BUILDTYPE.boolValue == false {
                print("COMMAND NAME:sendHeartBeat | info: \(Utilities.instance.loginfo())")
            } else {
                print("COMMAND NAME:sendHeartBeat | info: \(Utilities.instance.loginfo())")
            }
            try sendCommand(command: command)
            
        } catch let error as NSError {
            if LOGS.BUILDTYPE.boolValue == false {
                print("error sending  command: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                print("error sending  command with state: \(state) | info: \(Utilities.instance.loginfo())")
            } else {
                print("error sending  command: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                print("error sending  command with state: \(state) | info: \(Utilities.instance.loginfo())")
            }
        } catch {
            if LOGS.BUILDTYPE.boolValue == false {
                print("Unable to send command | info: \(Utilities.instance.loginfo())")
            } else {
                print("Unable to send command | info: \(Utilities.instance.loginfo())")
            }
        }
    }
    
    func checkForDataStream() {
        guard SPBluetoothManager.shared.isConnected  else {
            return
        }
        
        if let peripheral = SPBluetoothManager.shared.state.peripheral {
            SPBluetoothManager.shared.state = .connected(peripheral)
            SPBluetoothManager.shared.sendHeartBeat(peripheral, peripheral.spDesiredCharacteristic!)
            SPBluetoothManager.shared.setConnected(peripheral: peripheral)
        }
    }
    
}

extension CBPeripheral {
    /// Helper to find the service we're interested in.
    
   public  var spDesiredService: CBService? {
        guard let services = services else {
            return nil
        }
    
        //return services.first { $0.uuid == SPBluetoothManager.shared.SPBLEServiceUUID }
        return services.first { $0.uuid == BLEService_UUID}
    }

    /// Helper to find the characteristic we're interested in.
    
    var spDesiredCharacteristic: CBCharacteristic? {
        guard let characteristics = spDesiredService?.characteristics else {
            if LOGS.BUILDTYPE.boolValue == false {
                print("spDesiredCharacteristic nil | info: \(Utilities.instance.loginfo())")
            } else {
                print("spDesiredCharacteristic nil | info: \(Utilities.instance.loginfo())")
            }
            return nil
        }
        
        //return characteristics.first { $0.uuid == SPBluetoothManager.shared.SPBLECharacteristic }
        return characteristics.first { $0.uuid == BLE_Characteristic_uuid_Tx }
    }
    
    var spCommandCharacteristics: CBCharacteristic? {
        
        guard let characteristics = spDesiredService?.characteristics else {
            return nil
        }
        
        return characteristics.first { $0.uuid == SPBluetoothManager.shared.SPBLECharacteristic }
    }
}

class SPPeripheralDelegate: NSObject, CBPeripheralDelegate {
    static let shared = SPPeripheralDelegate()
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        
         if let error = error {
            SPBluetoothManager.shared.SPSignalRSSI = 0
            return
        }

        guard RSSI.intValue >= -200
            else {
            //print("RSSI not in range | info: \(Utilities.instance.loginfo())")
                SPBluetoothManager.shared.disconnect(forget: true)
                return
        }
        
         SPBluetoothManager.shared.SPSignalRSSI = RSSI.intValue
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard case .discoveringServices = SPBluetoothManager.shared.state else {
            return
        }
        
        if let error = error {
            if LOGS.BUILDTYPE.boolValue == false {
                print("Failed to discover services: \(error)")
            } else {
                print("Failed to discover services: \(error)")
            }
            SPBluetoothManager.shared.cleanup()
            SPBluetoothManager.shared.disconnect(forget: true)
            return
        }

        
        guard peripheral.spDesiredService != nil else {
            SPBluetoothManager.shared.assignBleService(peripheral)
            return
        }

        // Progress to the next step.
        SPBluetoothManager.shared.discoverCharacteristics(peripheral: peripheral)
        
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            if LOGS.BUILDTYPE.boolValue == false {
                print("********************didDiscoverCharacteristicsFor***********************************")
            } else {
                print("********************didDiscoverCharacteristicsFor***********************************")
            }
        
                guard case .discoveringCharacteristics =
                    SPBluetoothManager.shared.state else { return }
                
                guard let characteristics = service.characteristics else {
                    return
                }
            
                if let error = error {
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("Failed to discover characteristics: \(error) | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("Failed to discover characteristics: \(error) | info: \(Utilities.instance.loginfo())")
                    }
                    SPBluetoothManager.shared.cleanup()
                    SPBluetoothManager.shared.disconnect(forget: true)
                    return
                }
            
            
        if LOGS.BUILDTYPE.boolValue == false {
            print("Found \(characteristics.count) characteristics! | info: \(Utilities.instance.loginfo())")
        } else {
            print("Found \(characteristics.count) characteristics! | info: \(Utilities.instance.loginfo())")
        }

            SPBluetoothManager.shared.pulse = .Connecting
                for characteristic in characteristics{
                    if characteristic.uuid == BLE_Characteristic_uuid_Tx {
                        peripheralIsReady(toSendWriteWithoutResponse: peripheral)
                            SPBluetoothManager.shared.SPBLECharacteristic = characteristic.uuid
                            
                            if characteristic.properties.contains(.notify) {
                                print("characteristic has notify with rawValue \(characteristic.properties.contains(.notify)) | info: \(Utilities.instance.loginfo())")
                                peripheral.setNotifyValue(true, for: characteristic)
                                
                            }

                            if characteristic.properties.contains(.read) {
                                print("characteristic has read with rawValue: \(characteristic.properties.contains(.read)) | info: \(Utilities.instance.loginfo())")
                                peripheral.readValue(for: characteristic)

                            }
                        
                            if characteristic.properties.contains(.write) {
                                print("characteristic has write with rawValue: \(characteristic.properties.contains(.write)) | info: \(Utilities.instance.loginfo())")
                            }
                                
                            //need to check if box and app is bonded
                        
//                            print("characteristing value: \(characteristic.properties.rawValue)")
//                            print("characteristics property: \(characteristic.properties)")
//                            print("peripheral: \(peripheral)")
//                            print("characteristics: \(characteristics)")
//                            print("characteristic value: \(String(describing: characteristic.value))")
//                            print("characteristic properties: \(characteristic.properties)")
                        
                            let dataHelper = SPRealmHelper()
                            let email = Utilities.instance.getLoggedEmail()
                        
                            do {
                                let pulse =  try dataHelper.getPulseDevice(email)
                            
                                if (dataHelper.pulseDeviceExists(email)) {
                                    if (pulse.Identifier.isEmpty == false && pulse.Identifier == peripheral.identifier.uuidString) {
                                        SPBluetoothManager.shared.setConnected(peripheral: peripheral)
                                        if (characteristic.value != nil && peripheral.state == .connected) {
                                            SPBluetoothManager.shared.SPBLEResponse(peripheral, characteristic)
                                        }
                                    }
                                } else {
                                    if (characteristic.value != nil && peripheral.state == .connected) {
                                        
                                        SPBluetoothManager.shared.SPBLEResponse(peripheral, characteristic)
                                        SPBluetoothManager.shared.setConnected(peripheral: peripheral)
                                        
                                    }
                                }
                            } catch {
                                if LOGS.BUILDTYPE.boolValue == false {
                                    print("Realm getPulseDevice error | info: \(Utilities.instance.loginfo())")
                                } else {
                                    print("Realm getPulseDevice error | info: \(Utilities.instance.loginfo())")
                                }
                            }
                            
                            break
                    }
            }

    }
    
    func peripheral(_ peripheral: CBPeripheral,
            didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let error = error,
            (error as NSError).domain == CBErrorDomain,
            let code = CBError.Code(rawValue: (error as NSError).code) {
            SPBluetoothManager.shared.cleanup()
            
            if LOGS.BUILDTYPE.boolValue == false {
                print("didUpdateValueFor error: \(error) | info: \(Utilities.instance.loginfo())")
                print("didUpdateValueFor code: \(code) | info: \(Utilities.instance.loginfo())")
            } else {
                print("didUpdateValueFor error: \(error) | info: \(Utilities.instance.loginfo())")
                print("didUpdateValueFor code: \(code) | info: \(Utilities.instance.loginfo())")
            }
            
            return
        }
        
        //print("didUpdateValueFor characteristic value: ", characteristic.value)
        
        SPBluetoothManager.shared.SPBLEResponse(peripheral, characteristic)
    }
    
    /// Called when .withResponse is used.
    func peripheral(_ peripheral: CBPeripheral,
            didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let error = error,
            (error as NSError).domain == CBErrorDomain,
            let _ = CBError.Code(rawValue: (error as NSError).code) {
            print("didWriteValueFor error: ", error)
            print("didWriteValueFor code: ", error)
            SPBluetoothManager.shared.SPBleError(peripheral,characteristic,error)
            return
        }
        
        //print("didWriteValueFor characteristic value: ", characteristic.value ?? Data())
        
        SPBluetoothManager.shared.serialKeyPresent = true
        SPBluetoothManager.shared.SPBLEResponse(peripheral, characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                didUpdateNotificationStateFor characteristic: CBCharacteristic,
                error: Error?) {
            
            // Deal with errors (if any)
        if let error = error,
            (error as NSError).domain == CBErrorDomain,
            let code = CBError.Code(rawValue: (error as NSError).code) {
               
            if LOGS.BUILDTYPE.boolValue == false {
                print("ERROR NOTIFICATION error: \(error) | info: \(Utilities.instance.loginfo())")
                print("ERROR NOTIFICATION code: \(code) | info: \(Utilities.instance.loginfo())")
            } else {
                print("ERROR NOTIFICATION error: \(error) | info: \(Utilities.instance.loginfo())")
                print("ERROR NOTIFICATION code: \(code) | info: \(Utilities.instance.loginfo())")
            }
            
                SPBluetoothManager.shared.SPBleError(peripheral,characteristic,error)
                //SPBluetoothManager.shared.disconnect(forget: true)
                //SPBluetoothManager.shared.forgetPeripheral(forget: true)
                return
            }
            
        if LOGS.BUILDTYPE.boolValue == false {
            print("didUpdateNotificationStateFor: \(peripheral) | info: \(Utilities.instance.loginfo())")
            print("didUpdateNotificationStateFor: \(characteristic) | info: \(Utilities.instance.loginfo())")
            print("didUpdateNotificationStateFor boxInBond: \(SPBluetoothManager.shared.boxInBond) | info: \(Utilities.instance.loginfo())")
            print("didUpdateNotificationStateFor SPBluetoothManager.shared.requestPairSSID: \(SPBluetoothManager.shared.requestPairSSID) | info: \(Utilities.instance.loginfo())")
            print("didUpdateNotificationStateFor SPBluetoothManager.shared.defautlPairSSID:  \(SPBluetoothManager.shared.defautlPairSSID) | info: \(Utilities.instance.loginfo())")
            print("didUpdateNotificationStateFor SPBluetoothManager.shared.boxInBond:  \(SPBluetoothManager.shared.boxInBond) | info: \(Utilities.instance.loginfo())")
        } else {
            print("didUpdateNotificationStateFor: \(peripheral) | info: \(Utilities.instance.loginfo())")
            print("didUpdateNotificationStateFor: \(characteristic) | info: \(Utilities.instance.loginfo())")
            print("didUpdateNotificationStateFor boxInBond: \(SPBluetoothManager.shared.boxInBond) | info: \(Utilities.instance.loginfo())")
            print("didUpdateNotificationStateFor SPBluetoothManager.shared.requestPairSSID: \(SPBluetoothManager.shared.requestPairSSID) | info: \(Utilities.instance.loginfo())")
            print("didUpdateNotificationStateFor SPBluetoothManager.shared.defautlPairSSID:  \(SPBluetoothManager.shared.defautlPairSSID) | info: \(Utilities.instance.loginfo())")
            print("didUpdateNotificationStateFor SPBluetoothManager.shared.boxInBond:  \(SPBluetoothManager.shared.boxInBond) | info: \(Utilities.instance.loginfo())")
        }
        
        
        if SPBluetoothManager.shared.requestPairSSID || SPBluetoothManager.shared.defautlPairSSID{
            //if  SPBluetoothManager.shared.boxInBond == false {
                SPBluetoothManager.shared.state = .connected(peripheral)
                repeat {
                    SPBluetoothManager.shared.sendHeartBeat(peripheral, peripheral.spDesiredCharacteristic!)
                    
                    if  (SPBluetoothManager.shared.heartBeatSentCount == SPBluetoothManager.shared.heartBeatSentLimit){
                        print("SPBluetoothManager.shared.isConnected : \(SPBluetoothManager.shared.isConnected)")
                        SPBluetoothManager.shared.boxInBond = true
                        //SPBluetoothManager.shared.checkForDataStream(peripheral: peripheral)
                        //trial test for detecting if it is really streaming
                        SPBluetoothManager.shared.sendRequestProfile(peripheral, peripheral.spDesiredCharacteristic!)
                    }
                    
                } while (SPBluetoothManager.shared.heartBeatSentCount < SPBluetoothManager.shared.heartBeatSentLimit && SPBluetoothManager.shared.heartBeatSentCount != SPBluetoothManager.shared.heartBeatSentLimit)
                
                
            //}
            
        }
            
    }
    
    func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        print("\nperipheralDidUpdateRSSI | info: \(Utilities.instance.loginfo())")
        
    }
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        print("peripheralDidUpdateName: \(peripheral) | info: \(Utilities.instance.loginfo())")
        
        SPBluetoothManager.shared.didPairDevice = true
        SPBluetoothManager.shared.isPairing = true
        
        if SPBluetoothManager.shared.requestPairSSID || SPBluetoothManager.shared.defautlPairSSID{
            if peripheral.spDesiredCharacteristic != nil {
                //SPBluetoothManager.shared.changePeripheralNameHeartbeat(peripheral, peripheral.spDesiredCharacteristic!)
            }
        }
        
    }
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("\ndidModifyServices | info: \(Utilities.instance.loginfo())")
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        print("\ndidDiscoverIncludedServicesFor | info: \(Utilities.instance.loginfo())")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        
        print("\ndidDiscoverDescriptorsFor | info: \(Utilities.instance.loginfo())")
        
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        print("peripheralIsReady: \(peripheral) | info: \(Utilities.instance.loginfo())")
    }
    
}

class SPCentralManagerDelegate: NSObject, CBCentralManagerDelegate {
    static let shared = SPCentralManagerDelegate()
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let dataHelper = SPRealmHelper()
        let email = Utilities.instance.getLoggedEmail()
        
        if central.state == .poweredOn {
            // Are we transitioning from BT off to BT ready?
            
            if case .poweredOff = SPBluetoothManager.shared.state {
                // Firstly, try to reconnect:
                
                if LOGS.BUILDTYPE.boolValue == false {
                    print("centralManagerDidUpdateState state: \(SPBluetoothManager.shared.state) | info: \(Utilities.instance.loginfo())")
                } else {
                    print("centralManagerDidUpdateState state: \(SPBluetoothManager.shared.state) | info: \(Utilities.instance.loginfo())")
                }
                
                if email.isEmpty == false,
                   let peripheralIdStr = dataHelper.getDeviceConnectedIdentifier(email) as? String,
                    let peripheralId = UUID(uuidString: peripheralIdStr),
                    let previouslyConnected = central
                        .retrievePeripherals(withIdentifiers: [peripheralId])
                        .first {
                    
                    guard (SPRealmHelper().getDeviceintentionallyDisconnect() == false) else {
                        if LOGS.BUILDTYPE.boolValue == false {
                            print("centralManagerDidUpdateState user should attempt to reconnect manually | info: \(Utilities.instance.loginfo())")
                        } else {
                            print("centralManagerDidUpdateState user should attempt to reconnect manually | info: \(Utilities.instance.loginfo())")
                        }
                        return
                    }
                    
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("centralManagerDidUpdateState retrievePeripherals: \(previouslyConnected) | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("centralManagerDidUpdateState retrievePeripherals: \(previouslyConnected) | info: \(Utilities.instance.loginfo())")
                    }
                    SPBluetoothManager.shared.connect(peripheral: previouslyConnected)
                    
                   
                } else if let systemConnected = central
                    .retrieveConnectedPeripherals(withServices:
                        [BLEService_UUID]).first {
                    
                    guard (SPRealmHelper().getDeviceintentionallyDisconnect() == false) else {
                        if LOGS.BUILDTYPE.boolValue == false {
                            print("centralManagerDidUpdateState user should attempt to reconnect manually | info: \(Utilities.instance.loginfo())")
                        } else {
                            print("centralManagerDidUpdateState user should attempt to reconnect manually | info: \(Utilities.instance.loginfo())")
                        }
                        SPBluetoothManager.shared.delegate?.unableToPairWithBox()
                        return
                    }
                    
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("centralManagerDidUpdateState retrieveConnectedPeripherals: \(systemConnected) | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("centralManagerDidUpdateState retrieveConnectedPeripherals: \(systemConnected) | info: \(Utilities.instance.loginfo())")
                    }
                    SPBluetoothManager.shared.connect(peripheral: systemConnected)

                } else {
                    // Not an error, simply the case that they've never paired
                    // before, or they did a manual unpair:
                    SPBluetoothManager.shared.state = .disconnected
                    SPBluetoothManager.shared.pulse = .Disconnected
                }
            }
            
            // Did CoreBluetooth wake us up with a peripheral that was connecting?
            if case .restoringConnectingPeripheral(let peripheral) =
                    SPBluetoothManager.shared.state {
                
                let peripheralIdStr = UserDefaults.standard
                        .object(forKey: peripheralIdDefaultsKey) as? String
                
                if LOGS.BUILDTYPE.boolValue == false {
                    print("centralManagerDidUpdateState restoringConnectingPeripheral UDID: \(peripheralIdStr ?? "") | info: \(Utilities.instance.loginfo())")
                } else {
                    print("centralManagerDidUpdateState restoringConnectingPeripheral UDID: \(peripheralIdStr ?? "") | info: \(Utilities.instance.loginfo())")
                }
                
                
                guard peripheralIdStr?.isEmpty == false else {
                    SPBluetoothManager.shared.disconnect(forget: true)
                    SPBluetoothManager.shared.pulse = .Disconnected
                    SPBluetoothManager.shared.connectivityDelegate?.deviceNotInRange?()
                    return
                }
                
                SPBluetoothManager.shared.connect(peripheral: peripheral)
            }
            
            // CoreBluetooth woke us with a 'connected' peripheral, but we had
            // to wait until 'poweredOn' state:
            if case .restoringConnectedPeripheral(let peripheral) =
                    SPBluetoothManager.shared.state {
                
                if LOGS.BUILDTYPE.boolValue == false {
                    print("centralManagerDidUpdateState restoringConnectedPeripheral peripheral: \(peripheral) | info: \(Utilities.instance.loginfo())")
                } else {
                    print("centralManagerDidUpdateState restoringConnectedPeripheral peripheral: \(peripheral) | info: \(Utilities.instance.loginfo())")
                }
                
                SPBluetoothManager.shared.discoverServices(
                    peripheral: peripheral)
                
            }
            
            if case .unauthorized = SPBluetoothManager.shared.state {
                if email.isEmpty == false,
                   let peripheralIdStr: String = dataHelper.getDeviceConnectedIdentifier(email) as? String,
                    let peripheralId = UUID(uuidString: peripheralIdStr),
                    let previouslyConnected = SPBluetoothManager.shared.central
                        .retrievePeripherals(withIdentifiers: [peripheralId])
                        .first {
                    
                    guard (SPRealmHelper().getDeviceintentionallyDisconnect() == false) else {
                        if LOGS.BUILDTYPE.boolValue == false {
                            print("centralManagerDidUpdateState user should attempt to reconnect manually | info: \(Utilities.instance.loginfo())")
                        } else {
                            print("centralManagerDidUpdateState user should attempt to reconnect manually | info: \(Utilities.instance.loginfo())")
                        }
                        SPBluetoothManager.shared.delegate?.unableToPairWithBox()
                        return
                    }
                    
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("centralManagerDidUpdateState unauthorized peripheral: \(previouslyConnected) | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("centralManagerDidUpdateState unauthorized peripheral: \(previouslyConnected) | info: \(Utilities.instance.loginfo())")
                    }
                    SPBluetoothManager.shared.connect(peripheral: previouslyConnected)
                }
            }
            
            if case .unsupported = SPBluetoothManager.shared.state {
                if LOGS.BUILDTYPE.boolValue == false {
                    print("device on with unsupported state | info: \(Utilities.instance.loginfo())")
                } else {
                    print("device on with unsupported state | info: \(Utilities.instance.loginfo())")
                }
            }
            
            if case .resetting = SPBluetoothManager.shared.state {
                if LOGS.BUILDTYPE.boolValue == false {
                    print("device on with resetting state | info: \(Utilities.instance.loginfo())")
                } else {
                    print("device on with resetting state | info: \(Utilities.instance.loginfo())")
                }
            }
            
            if case .unsupported = SPBluetoothManager.shared.state {
                if LOGS.BUILDTYPE.boolValue == false {
                    print("device on with unsupported state | info: \(Utilities.instance.loginfo())")
                } else {
                    print("device on with unsupported state | info: \(Utilities.instance.loginfo())")
                }
            }
            
            if case .unknown = SPBluetoothManager.shared.state {
                if LOGS.BUILDTYPE.boolValue == false {
                    print("device on with unknown state | info: \(Utilities.instance.loginfo())")
                } else {
                    print("device on with unknown state | info: \(Utilities.instance.loginfo())")
                }
            }
            
            
        } else if central.state == .unauthorized {
            if LOGS.BUILDTYPE.boolValue == false {
                print("central state is unauthorized | info: \(Utilities.instance.loginfo())")
            } else {
                print("central state is unauthorized | info: \(Utilities.instance.loginfo())")
            }
            SPBluetoothManager.shared.state = .unauthorized
            SPBluetoothManager.shared.pulse = .Disconnected
            SPBluetoothManager.shared.delegate?.connectivityState(title: "Error", message: "Unauthorized to connect with device.", code: 3)
        } else if central.state == .unsupported {
            if LOGS.BUILDTYPE.boolValue == false {
                print("central state is unsupported | info: \(Utilities.instance.loginfo())")
            } else {
                print("central state is unsupported | info: \(Utilities.instance.loginfo())")
            }
            SPBluetoothManager.shared.state = .unsupported
            SPBluetoothManager.shared.pulse = .Disconnected
        } else if central.state == .unknown {
            if LOGS.BUILDTYPE.boolValue == false {
                print("central state is unknown | info: \(Utilities.instance.loginfo())")
            } else {
                print("central state is unknown | info: \(Utilities.instance.loginfo())")
            }
            SPBluetoothManager.shared.state = .poweredOff
            SPBluetoothManager.shared.pulse = .Disconnected
            SPBluetoothManager.shared.delegate?.connectivityState(title: "Error", message: "Unknown device error.", code: 0)
        } else if central.state == .resetting {
            if LOGS.BUILDTYPE.boolValue == false {
                print("central state is resettings | info: \(Utilities.instance.loginfo())")
            } else {
                print("central state is resettings | info: \(Utilities.instance.loginfo())")
            }
            SPBluetoothManager.shared.state = .resetting
            SPBluetoothManager.shared.pulse = .Disconnected
            SPBluetoothManager.shared.delegate?.connectivityState(title: "Error", message: "Devicec is resetting.", code: 0)
        } else if central.state == .poweredOff {
            SPBluetoothManager.shared.state = .poweredOff
            SPBluetoothManager.shared.pulse = .Disconnected
            SPBluetoothManager.shared.delegate?.connectivityState(title: "Error", message: "Device has been powered off.", code: 4)
        } else { // Turned off.
            SPBluetoothManager.shared.state = .poweredOff
            SPBluetoothManager.shared.pulse = .Disconnected
            SPBluetoothManager.shared.delegate?.connectivityState(title: "Error", message: "Device has been powered off.", code: 999)
        }
    }
    
    // Apple says: This is the first method invoked when your app is relaunched
    // into the background to complete some Bluetooth-related task.
    func centralManager(_ central: CBCentralManager,
            willRestoreState dict: [String : Any]) {
        
        if LOGS.BUILDTYPE.boolValue == false {
            print("centralManager willRestoreState | info: \(Utilities.instance.loginfo())")
        } else {
            print("centralManager willRestoreState | info: \(Utilities.instance.loginfo())")
        }
        
        let peripherals: [CBPeripheral] = dict[
            CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] ?? []
        if peripherals.count > 1 {
            if LOGS.BUILDTYPE.boolValue == false {
                print("Warning: willRestoreState called with >1 connection | info: \(Utilities.instance.loginfo())")
            } else {
                print("Warning: willRestoreState called with >1 connection | info: \(Utilities.instance.loginfo())")
            }
        }
        // We have a peripheral supplied, but we can't touch it until
        // `central.state == .poweredOn`, so we store it in the state
        // machine enum for later use.
        if let peripheral = peripherals.first {
            switch peripheral.state {
            case .connecting: // I've only seen this happen when
                // re-launching attached to Xcode
                if LOGS.BUILDTYPE.boolValue == false {
                    print("willRestoreState connecting: \(peripheral) | info: \(Utilities.instance.loginfo())")
                } else {
                    print("willRestoreState connecting: \(peripheral) | info: \(Utilities.instance.loginfo())")
                }
                if peripheral.spDesiredCharacteristic != nil {
                    SPBluetoothManager.shared.state =
                        .restoringConnectingPeripheral(peripheral)
                    
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("willRestoreState connecting state: \(peripheral) | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("willRestoreState connecting state: \(peripheral) | info: \(Utilities.instance.loginfo())")
                    }
                    
                    SPBluetoothManager.shared.sendHeartBeat(peripheral, peripheral.spDesiredCharacteristic!)

                } else {
                    SPBluetoothManager.shared.disconnect(forget: true)
                }
                
            case .connected: // Store for connection / requesting
                // notifications when BT starts.
                if peripheral.spDesiredCharacteristic != nil {
                    SPBluetoothManager.shared.state =
                        .restoringConnectedPeripheral(peripheral)
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("willRestoreState connected state: \(peripheral) | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("willRestoreState connected state: \(peripheral) | info: \(Utilities.instance.loginfo())")
                    }
                    //SPBluetoothManager.shared.sendHeartBeat(peripheral, peripheral.spDesiredCharacteristic!)
                } else {
                    SPBluetoothManager.shared.disconnect(forget: true)
                }
            default: break
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                didDiscover peripheral: CBPeripheral,
                advertisementData: [String : Any], rssi RSSI: NSNumber) {
            
            guard case .scanning = SPBluetoothManager.shared.state else { return }
            
            _ = advertisementData["kCBAdvDataLocalName"] as? String ?? ""
            let txPower = advertisementData["kCBAdvDataTxPowerLevel"] as? NSNumber ?? 0
            
            let _bleDeviceDistance = 10 ^ ((txPower.intValue - Int(truncating: RSSI)) / 20)

            if LOGS.BUILDTYPE.boolValue == false {
                print("advertisementData: \(advertisementData) | info: \(Utilities.instance.loginfo())")
                print("RSSI: \(RSSI)")
                print("bleDeviceDistance: \(_bleDeviceDistance) | info: \(Utilities.instance.loginfo())")
            } else {
                print("advertisementData: \(advertisementData) | info: \(Utilities.instance.loginfo())")
                print("RSSI: \(RSSI)")
                print("bleDeviceDistance: \(_bleDeviceDistance) | info: \(Utilities.instance.loginfo())")
            }
            
            if _bleDeviceDistance < 15 {
                let _devices = SPBluetoothManager.shared.peripherals.filter { (_peripheral) -> Bool in
                    return _peripheral.identifier == peripheral.identifier
                }

                if _devices.count == 0 {
                    
                    SPBluetoothManager.shared.advertisementData.append(advertisementData)
                    SPBluetoothManager.shared.peripherals.append(peripheral)
                    SPBluetoothManager.shared.questDevices.append(QuestDevice(deviceName: peripheral.name ?? "",
                                                                              periPheral: peripheral,
                                                                              identifier: peripheral.identifier.uuidString,
                                                                              isConnecting: false))
                }
                
            }
            
        }
    
    func centralManager(_ central: CBCentralManager,
                didConnect peripheral: CBPeripheral) {
        
        let peripheralIdStr = UserDefaults.standard
            .object(forKey: peripheralIdDefaultsKey) as? String ?? ""
        
        print("didConnect state : \(SPBluetoothManager.shared.state)")
        
        if peripheral.spDesiredCharacteristic == nil {
            
            DispatchQueue.main.async {
                SPBluetoothManager.shared.delegate?.updateDeviceConnectivity(connect: true)
            }
                SPBluetoothManager.shared.defautlPairSSID = true
                SPBluetoothManager.shared.requestPairSSID = true
                
                SPBluetoothManager.shared.isConnected = false
                SPBluetoothManager.shared.pairingDialogOpen = true
                SPBluetoothManager.shared.isPairing = true
                SPBluetoothManager.shared.heartBeatSentCount = 0
    
            if peripheralIdStr.isEmpty {
                Utilities.instance.saveDefaultValueForKey(value: true, key: pairingDefaultsKey)
            }
            
            SPBluetoothManager.shared.discoverServices(peripheral: peripheral)
        } else {
            SPBluetoothManager.shared.connectionAttempt = 0
            SPBluetoothManager.shared.heartBeatSentCount = 0
            SPBluetoothManager.shared.boxInBond = false
            
            if LOGS.BUILDTYPE.boolValue == false {
                print("Already has desired services send heartbeat | info: \(Utilities.instance.loginfo())")
                print("has service with characteristic : \(String(describing: peripheral.spDesiredCharacteristic)) | info: \(Utilities.instance.loginfo())")
                print("peripheral state : \(String(describing: peripheral.state.rawValue)) | info: \(Utilities.instance.loginfo())")
            } else {
                print("Already has desired services send heartbeat | info: \(Utilities.instance.loginfo())")
                print("has service with characteristic : \(String(describing: peripheral.spDesiredCharacteristic)) | info: \(Utilities.instance.loginfo())")
                print("peripheral state : \(String(describing: peripheral.state.rawValue)) | info: \(Utilities.instance.loginfo())")
            }
            
            SPBluetoothManager.shared.setConnected(peripheral: peripheral)
            
            guard let spCharacteristic = peripheral.spDesiredCharacteristic else {
               return
           }
            SPBluetoothManager.shared.state = .connected(peripheral)
            SPBluetoothManager.shared.sendHeartBeat(peripheral, spCharacteristic)
        }
        
    }
    
    func centralManager(_ central: CBCentralManager,
            didFailToConnect peripheral: CBPeripheral, error: Error?) {
        SPBluetoothManager.shared.cleanup()
        SPBluetoothManager.shared.disconnect(forget: true)
        SPBluetoothManager.shared.forgetPeripheral(forget: true)
        SPBluetoothManager.shared.state = .disconnected
        SPBluetoothManager.shared.boxInBond = false
        
        if let error = error {
            
            
            let errorCode = (error as NSError).code
            let errorMessage = (error as NSError).localizedDescription
            
            if LOGS.BUILDTYPE.boolValue == false {
                print("didFailToConnect \(error) | info: \(Utilities.instance.loginfo())")
                print("didFailToConnect errorCode: \(errorCode) | info: \(Utilities.instance.loginfo())")
                print("didFailToConnect errorMessag: \(errorMessage) | info: \(Utilities.instance.loginfo())")
            } else {
                print("didFailToConnect \(error) | info: \(Utilities.instance.loginfo())")
                print("didFailToConnect errorCode: \(errorCode) | info: \(Utilities.instance.loginfo())")
                print("didFailToConnect errorMessag: \(errorMessage) | info: \(Utilities.instance.loginfo())")
            }
            
             
             if errorCode == 14 {
                SPBluetoothManager.shared.boxInBond = false
                SPBluetoothManager.shared.requestPairSSID = false
                SPBluetoothManager.shared.defautlPairSSID = false
                SPBluetoothManager.shared.heartBeatSentCount = 0
                SPBluetoothManager.shared.delegate?.connectivityState(title: "Error", message: "generic.error_code_14".localize(), code: 14)
             }
            
            return
        }
    }
    
    func centralManager(_ central: CBCentralManager,
            didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        // Did our currently-connected peripheral just disconnect?
        
        guard  SPBluetoothManager.shared.boxInBond == false else {
            return
        }
        
        if SPBluetoothManager.shared.state.peripheral?.identifier ==
                peripheral.identifier {
            // IME the error codes encountered are:
            // 0 = rebooting the peripheral.
            // 6 = out of range.
            
            if let error = error,
                (error as NSError).domain == CBErrorDomain,
                let code = CBError.Code(rawValue: (error as NSError).code),
                outOfRangeHeuristics.contains(code) {
                
               
                
                print("didDisconnectPeripheral code: \(code.rawValue)")
                
                if (code.rawValue == 6) {
                    print("app just had connection timeout resume reconnect timer PulseDeviceReconnectWhenTimeout")
                    SPBluetoothManager.shared.PulseDeviceReconnectWhenTimeout.resume()
                } else {
                    print("suspend reconnect timer PulseDeviceReconnectWhenTimeout")
                    SPBluetoothManager.shared.PulseDeviceReconnectWhenTimeout.suspend()
                }
                
                // Try reconnect without setting a timeout in the state machine.
                // With CB, it's like saying 'please reconnect me at any point
                // in the future if this peripheral comes back into range'.
                
                
                if LOGS.BUILDTYPE.boolValue == false {
                    print("didDisconnectPeripheral SPBluetoothManager.shared.boxInBond : \(SPBluetoothManager.shared.boxInBond) | info: \(Utilities.instance.loginfo())")
                } else {
                    print("didDisconnectPeripheral SPBluetoothManager.shared.boxInBond : \(SPBluetoothManager.shared.boxInBond) | info: \(Utilities.instance.loginfo())")
                }
                
                guard  SPBluetoothManager.shared.boxInBond == false else {
                    
                    if outOfRangeHeuristics.contains(code) {
                        if (code == .peripheralDisconnected) { //specific for disconnect
                            if let peripheral = SPBluetoothManager.shared.state.peripheral {
                                central.cancelPeripheralConnection(peripheral)
                            }
                            SPBluetoothManager.shared.state = .disconnected
                            SPBluetoothManager.shared.pulse = .Disconnected
                            SPBluetoothManager.shared.isConnected = false
                            SPBluetoothManager.shared.isPairing = false
                            SPBluetoothManager.shared.didPairDevice = false
                            SPBluetoothManager.shared.desktopApphasPriority = false
                            PulseDataState.instance.isDeskCurrentlyBooked = false
                            SwiftEventBus.post(ViewEventListenerType.BLEConnectivityStream.rawValue, sender: self)
                            SPBluetoothManager.shared.delegate?.updateInterface()
                            SPBluetoothManager.shared.delegate?.unableToPairWithBox()

                        }
                    }
                    
                    return
                }
                DispatchQueue.main.async {
                    let state = UIApplication.shared.applicationState
                    if state == .active {
                        print("Pulse App is active | info: \(Utilities.instance.loginfo())")
                    }
                    else if state == .inactive {
                        print("Pulse App is inactive | info: \(Utilities.instance.loginfo())")
                    }
                    else if state == .background {
                        print("Pulse App is in background | info: \(Utilities.instance.loginfo())")
                    }
                }
                
                
                guard (SPRealmHelper().getDeviceintentionallyDisconnect() == false) else {
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("didDisconnectPeripheral user should attempt to reconnect manually | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("didDisconnectPeripheral user should attempt to reconnect manually | info: \(Utilities.instance.loginfo())")
                    }
                    SPBluetoothManager.shared.delegate?.unableToPairWithBox()
                    return
                }
                
                print("didDisconnectPeripheral will attempt to reconnect: \(outOfRangeHeuristics.contains(code)) | info: \(Utilities.instance.loginfo())")
                SPBluetoothManager.shared.state = .outOfRange(peripheral)
                SPBluetoothManager.shared.connect(peripheral: peripheral)
                if (SPBluetoothManager.shared.connectionAttempt < SPBluetoothManager.shared.connectionAttemptLimit && SPBluetoothManager.shared.connectionAttempt != SPBluetoothManager.shared.connectionAttemptLimit) {
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("didDisconnectPeripheral reconnect with attempt: \(SPBluetoothManager.shared.connectionAttempt) | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("didDisconnectPeripheral reconnect with attempt: \(SPBluetoothManager.shared.connectionAttempt) | info: \(Utilities.instance.loginfo())")
                    }
                    SPBluetoothManager.shared.connect(peripheral: peripheral)
                } else {
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("didDisconnectPeripheral reconnect failed, total disconnect the app | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("didDisconnectPeripheral reconnect failed, total disconnect the app | info: \(Utilities.instance.loginfo())")
                    }
                    SPBluetoothManager.shared.forgetPeripheral(forget: true)
                    SPBluetoothManager.shared.disconnect(forget: true)
                    SPBluetoothManager.shared.pulse = .Disconnected
                    SPBluetoothManager.shared.delegate?.deviceConnected()
                    SPBluetoothManager.shared.delegate?.unableToPairWithBox()
                    SPBluetoothManager.shared.state = .disconnected
                    SPBluetoothManager.shared.PulseHeartbeatReconnectTimer.suspend()
                    SPBluetoothManager.shared.PulseDeviceActivityTimer.suspend()
                    SPBluetoothManager.shared.PulseHeartbeatReconnectTimer.suspend()
                    SPBluetoothManager.shared.PulseDeviceReconnectWhenTimeout.suspend()
                    SPBluetoothManager.shared.delegate?.updateDeviceConnectivity(connect: false)
                }
                
            } else {
                // Likely a deliberate unpairing.
                
                SPBluetoothManager.shared.state = .disconnected
                SPBluetoothManager.shared.pulse = .Disconnected
                SPBluetoothManager.shared.PulseHeartbeatReconnectTimer.suspend()
                SPBluetoothManager.shared.delegate?.updateDeviceConnectivity(connect: false)
                

            }
        } else {
            SPBluetoothManager.shared.isConnected = false
            SPBluetoothManager.shared.isPairing = false
        }
    }
}

class SPPeripheralManagerDelegate: NSObject, CBPeripheralManagerDelegate {
    static let shared = SPPeripheralManagerDelegate()
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if LOGS.BUILDTYPE.boolValue == false {
            print("peripheralManagerDidUpdateState | info: \(Utilities.instance.loginfo())")
        } else {
            print("peripheralManagerDidUpdateState | info: \(Utilities.instance.loginfo())")
        }
    }
    
    
}

class Countdown {
    let timer: Timer
    
    init(seconds: TimeInterval, closure: @escaping () -> ()) {
        timer = Timer.scheduledTimer(withTimeInterval: seconds,
                repeats: false, block: { _ in
            closure()
        })
    }
    
    deinit {
        timer.invalidate()
    }
}



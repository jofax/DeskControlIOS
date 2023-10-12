//
//  AppLogController.swift
//  PulseEcho
//
//  Created by Joseph on 2021-01-21.
//  Copyright © 2021 Smartpods. All rights reserved.
//

import UIKit
//import SwiftyBeaver
import CommonCrypto
import Moya

class AppLogController: UIViewController {
    
    @IBOutlet weak var btnCommands: UIButton?
    @IBOutlet weak var btnClose: UIButton?
    @IBOutlet weak var txtLogs: UITextView?
    let scheduler = SPTimeScheduler(timeInterval: 10)
    var serverProvider: MoyaProvider<DataPushService>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtLogs?.text = readFromDocumentsFile(fileName: "sp_debug.log")
        scheduler.resume()
        
        scheduler.eventHandler = {
            print("refresh logger")
            DispatchQueue.main.async {
                self.txtLogs?.text = self.readFromDocumentsFile(fileName: "sp_debug.log")
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func onBtnActions(sender: UIButton) {
        switch sender.tag {
        case 0:
            self.dismiss(animated: true, completion: nil)
        case 1: actionOptions()
        default:
            break
        }
    }
    
    func readFromDocumentsFile(fileName:String) -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let path = documentsPath.appendingPathComponent(fileName)
        let checkValidation = FileManager.default
        var file:String

        if checkValidation.fileExists(atPath: path) {
            do {
                file = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            } catch _ {
                file = "no content on \(fileName)"
            }
        } else {
            file = "*ERROR* \(fileName) does not exist."
        }

        return file
    }
    
    func removeFile(itemName:String, fileExtension: String) {
        let fileManager = FileManager.default
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
      let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
      guard let dirPath = paths.first else {
        return
      }
      let filePath = "\(dirPath)/\(itemName).\(fileExtension)"
      do {
        try fileManager.removeItem(atPath: filePath)
      } catch let error as NSError {
        print(error.debugDescription)
      }
    }
    
//    func addLogFile() {
//        let file = FileDestination()
//        let url = try? FileManager.default.url(for: .documentDirectory,
//                                               in: .userDomainMask,
//                                               appropriateFor: nil,
//                                               create: true)
//
//        let fileURL = url?.appendingPathComponent("sp_debug.log")
//
//        file.logFileURL = fileURL
//
//        if LOGS.BUILDTYPE.boolValue == false {
//            Utilities.instance.appDelegate.log.addDestination(file)
//            print("log.addDestination(file) : \(fileURL) | info: \(Utilities.instance.loginfo())")
//        }
//    }
    
    func actionOptions() {
        
        let alert = UIAlertController(style: .actionSheet, title: "Options")
        alert.setTitle(font: UIFont(name: Constants.smartpods_font_gotham, size: Constants.smartpods_text_size_small) ?? UIFont(), color: UIColor(hexString: Constants.smartpods_gray))
        
        alert.addAction(title: "Clear Logs", style: .default) { [weak self] action in
            self?.scheduler.suspend()
            self?.removeFile(itemName: "sp_debug", fileExtension: "log")
            self?.txtLogs?.text = ""
        }
        alert.addAction(title: "Send Heartbeat", style: .default){ [weak self] action in
            if let peripheral = SPBluetoothManager.shared.state.peripheral {
                guard peripheral.spDesiredCharacteristic != nil else {
                    //log.debug("AppLogController cannot send heart beat: \(peripheral.spDesiredCharacteristic)")
                    return
                }
                SPBluetoothManager.shared.sendHeartBeat(peripheral, peripheral.spDesiredCharacteristic!)
            }
        }
        
        alert.addAction(title: "Ping Server", style: .default){ [weak self] action in
            self?.pingServer()
        }
        
        alert.addAction(title: "Desktop Data Test", style: .default){ [weak self] action in
            self?.pushDesktopAppPacket()
        }
        
        alert.addAction(title: "Mobile Data Test", style: .default){ [weak self] action in
            self?.pushMobileAppPacket()
        }
        
        alert.addAction(title: "common.cancel".localize(), style: .cancel)
        alert.show()
    }
    
    func crypttest(data: Data?, key: Data, iv: Data, option: CCOperation) -> Data? {
        guard let data = data else { return nil }

        let cryptLength = data.count + kCCBlockSizeAES128
        var cryptData   = Data(count: cryptLength)

        let keyLength = key.count
        let options   = CCOptions(kCCOptionPKCS7Padding)

        var bytesLength = Int(0)

        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes in
                    CCCrypt(option, CCAlgorithm(kCCAlgorithmAES),
                            options,
                            keyBytes.baseAddress,
                            keyLength,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress,
                            data.count,
                            cryptBytes.baseAddress,
                            cryptLength,
                            &bytesLength)
                    }
                }
            }
        }

        guard UInt32(status) == UInt32(kCCSuccess) else {
            debugPrint("Error: Failed to crypt data. Status \(status)")
            return nil
        }
        print("bytesLength : \(bytesLength)")
        print("cryptLength : \(cryptLength)")
        print("cryptData.count : \(cryptData.count)")
        print("cryptData.count : \(cryptData.count)")
        
        cryptData.removeSubrange(bytesLength..<cryptData.count)
        return cryptData
    }
    
    func pingServer() {
        
        //let key:Data = Data(base64Encoded: Constants.pingkey) ?? Data()
        //let iv: Data = Data(base64Encoded: Constants.pingiv) ?? Data()
        
        let keyBytes: [UInt8] = [52, 53, 71, 68, 56, 53, 74, 85, 52, 52, 51, 70, 50, 51, 52, 53]
        let ivBytes:[UInt8] = [103, 70, 97, 52, 51, 49, 49, 50, 51, 53, 71, 70, 52, 70, 101, 101]
        
        let key:Data = Data(bytes: keyBytes, count: keyBytes.count)
        let iv: Data = Data(bytes: ivBytes, count: ivBytes.count)
        
        
        guard key.count > 0 && iv.count > 0 else {
            print("invalid Ping key and IV")
            return
        }
        
        let encryptedPacket = Utilities.instance.aesCryptWith(data: Data(bytes: Constants.pingPacket, count: Constants.pingPacket.count),
                                                                key: key,
                                                                iv: iv,
                                                                option: CCOperation(kCCEncrypt))

        
        
        print("encryptedPingPacket: \(encryptedPacket?.array))")
        
        //var finalPacket:[UInt8] = [0, 0, 6, 29, 124]
        //finalPacket.append(contentsOf: encryptedPacket?.array.slice(start: 0, end: 15) ?? [UInt8]())
        
        var finalPacket:[UInt8] = [0, 0, 6, 29, 124]
        finalPacket.append(contentsOf: encryptedPacket?.array.slice(start: 0, end: 15) ?? [UInt8]())
        
        
        
        //let finalPacket: [UInt8] = [0, 0, 6, 155, 124, 227, 159, 105, 91, 59, 43, 17, 184, 216, 169, 100, 243, 0, 16, 57, 243]
        
        print("ping finalPacket: \(finalPacket)")
        
        self.serverProvider = MoyaProvider<DataPushService>(requestClosure: MoyaProvider<DataPushService>.endpointRequestResolver(),
                                                       session: smartpodsManager(withSSL: true),
                                                       trackInflights: true)
        
        
        self.serverProvider?.request(.pushData(Data(finalPacket))) { result in
                switch result {
                case .success(let response):
                    print("ping response.data: \(response.data.array)")
                    
                case .failure(let error):
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("ping pushData error : \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                        print("ping pushData error code : \(error.errorCode) | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("ping pushData error : \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                        print("ping pushData error code : \(error.errorCode) | info: \(Utilities.instance.loginfo())")
                    }
                }
            }
    }
    
    
    func pushDesktopAppPacket() {
        let keyBytes: [UInt8] =  [171, 168, 92, 89, 189, 184, 156, 197, 93, 149, 244, 172, 149, 164, 220, 82]
        let ivBytes:[UInt8] = [222, 244, 4, 17, 50, 55, 246, 37, 251, 67, 135, 197, 137, 161, 120, 49]
        let deskPacket: Array<UInt8> = [20, 0, 1, 0, 235, 0, 0, 0, 65, 0, 0, 0, 0, 1, 44, 0, 0, 3, 151, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 ,255]
        

        let key:Data = Data(bytes: keyBytes, count: keyBytes.count)
        let iv: Data = Data(bytes: ivBytes, count: ivBytes.count)
        
        let encryptedPacket = Utilities.instance.aesCryptWith(data: Data(deskPacket),
                                                                key: key,
                                                                iv: iv,
                                                                option: CCOperation(kCCEncrypt))
        
        var finalPacket:[UInt8] = [0, 0, 6, 29, 124]
        finalPacket.append(contentsOf: encryptedPacket?.array ?? [UInt8]())
        
        self.serverProvider = MoyaProvider<DataPushService>(requestClosure: MoyaProvider<DataPushService>.endpointRequestResolver(),
                                                       session: smartpodsManager(withSSL: true),
                                                       trackInflights: true)
        
        print("encryptedPacket desktop: \(encryptedPacket?.array)")
        
        self.serverProvider?.request(.pushData(Data(finalPacket))) { result in
                switch result {
                case .success(let response):
                    print("ping response.data: \(response.data.array)")
                    
                case .failure(let error):
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("ping pushData error : \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                        print("ping pushData error code : \(error.errorCode) | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("ping pushData error : \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                        print("ping pushData error code : \(error.errorCode) | info: \(Utilities.instance.loginfo())")
                    }
                }
            }
    }
    
    
    func pushMobileAppPacket() {
        let keyBytes: [UInt8] =  [171, 168, 92, 89, 189, 184, 156, 197, 93, 149, 244, 172, 149, 164, 220, 82]
        let ivBytes:[UInt8] = [222, 244, 4, 17, 50, 55, 246, 37, 251, 67, 135, 197, 137, 161, 120, 49]
        var deskPacket: Array<UInt8> = [20, 5, 5, 1, 44, 0, 0, 0, 0, 0, 0, 0, 0, 1, 44, 0, 0, 1]
        
        let key:Data = Data(bytes: keyBytes, count: keyBytes.count)
        let iv: Data = Data(bytes: ivBytes, count: ivBytes.count)
        
        let _packetCRC = Utilities.instance.convertDesktopCrc16(data: deskPacket).bigEndian.data.array
        
        deskPacket.append(contentsOf: _packetCRC)
        deskPacket.append(contentsOf: [255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 ,255])
        
        print("deskPacket mobile : \(deskPacket)")
        
        let encryptedPacket = Utilities.instance.aesCryptWith(data: Data(deskPacket),
                                                                key: key,
                                                                iv: iv,
                                                                option: CCOperation(kCCEncrypt))
        
        var finalPacket:[UInt8] = [0, 0, 6, 29, 124]
        finalPacket.append(contentsOf: encryptedPacket?.array ?? [UInt8]())
        
        print("finalPacket mobile : \(finalPacket)")
        
        self.serverProvider = MoyaProvider<DataPushService>(requestClosure: MoyaProvider<DataPushService>.endpointRequestResolver(),
                                                       session: smartpodsManager(withSSL: true),
                                                       trackInflights: true)
        print("encryptedPacket mobile : \(String(describing: encryptedPacket?.array))")
        
        self.serverProvider?.request(.pushData(Data(finalPacket))) { result in
                switch result {
                case .success(let response):
                    print("ping response.data: \(response.data.array)")
                    let _responseData = response.data
                    print("response push data: \(_responseData.array)")
                    
                    guard _responseData.array.count > 0 else {
                        return
                    }
                    
                    let filterPacket = _responseData.array.slice(start: 5, end: _responseData.count - 1)
                    
                    let decryptPacket = Utilities.instance.aesCryptWith(data: Data(filterPacket),
                                                                        key: key,
                                                                        iv: iv,
                                                                        option: CCOperation(kCCDecrypt))
                    
                    
                    print("push response.data decryptPacket: \(String(describing: decryptPacket?.array))")
                    
                    if let strResponse = String(bytes: decryptPacket?.array ?? [UInt8](), encoding: .ascii) {
                        print("push ascci response: \(strResponse)")
                    }
                    
                    
                case .failure(let error):
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("ping pushData error : \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                        print("ping pushData error code : \(error.errorCode) | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("ping pushData error : \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                        print("ping pushData error code : \(error.errorCode) | info: \(Utilities.instance.loginfo())")
                    }
                }
            }
    }
}

extension String {
    
    var ascii: [UInt8] {
        return unicodeScalars.map { return UInt8($0.value) }
    }
    
    var ascii2: [UInt8] {
        return [UInt8](self.data(using: .ascii)!)
    }
}

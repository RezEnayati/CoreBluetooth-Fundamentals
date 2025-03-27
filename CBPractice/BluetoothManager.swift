//
//  BluetoothManager.swift
//  CBPractice
//
//  Created by Reza Enayati on 3/26/25.
//

import Foundation

import CoreBluetooth
import SwiftUI


@Observable
class BluetoothManager: NSObject {
    
    //MARK: -Published Properties:
    var discoverdDevices = [DiscoveredDevice]()
    var isScanning = false
    var statusMessage = "Ready to Scan"
    
    private var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // Start Scanning for BLE Devices
    
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            statusMessage = "Bluetooth is not powered on"
            return
        }
        
        //Clear perivous results
        discoverdDevices.removeAll()
        
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        
        isScanning = true
        statusMessage = "Scanning for Devices..."
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        statusMessage = "Scan Complete"
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    
    // Called Whenever the BL state changes
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            statusMessage = "Bluetooth is Ready"
        case .poweredOff:
            statusMessage = "Bluetooth is turned off"
        case .resetting:
            statusMessage = "Bluetooth is resseting"
        case .unauthorized:
            statusMessage = "Bluetooth is not authorized"
        case .unsupported:
            statusMessage = "Bluetooth is not supported"
        case .unknown:
            statusMessage = "Bluetooth state is unknown"
        @unknown default:
            statusMessage = "Unkown Bluetooth state"
        }
    }
    
    //Called whenever a new peripheral is discoverd
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let newDevice = DiscoveredDevice(
            id: peripheral.identifier,
            name: peripheral.name ?? "Unknown Device",
            rssi: RSSI.intValue,
            advetismentData: advertisementData)
        
        //if the device exists already, remove it to add the updated device
        if let index = discoverdDevices.firstIndex(where: {$0.id == newDevice.id }) {
            discoverdDevices.remove(at: index)
        }
        
        discoverdDevices.append(newDevice)
        
        discoverdDevices.sort(by:  {$0.rssi > $1.rssi})
    }
}

struct DiscoveredDevice: Identifiable {
    let id: UUID
    let name: String
    let rssi: Int
    let advetismentData: [String: Any]
    
    
    // Helper computed property for UI Display of the singal strngth
    var signalStrength: String {
        if rssi >= -50 {
            return "Excellent"
        } else if rssi >= -70 {
            return "Good"
        } else if rssi >= -80 {
            return "Fair"
        } else {
            return "Poor"
        }
    }
    
    // Helper computed property for UI Display of signal strnegth with SF symbols
    var signalColor: Color {
        if rssi >= -50 {
            return Color.green
        } else if rssi >= -70 {
            return Color.yellow
        } else if rssi >= -80 {
            return Color.red
        } else {
            return Color.gray
        }
    }
    
    // Will show us the services provided by BL peripherals
    var services: String  {
        guard let services = advetismentData["kCBAdvDataServiceUUIDs"] as? [CBUUID] else {
            return "No Services advertised"
        }
        
        if services.isEmpty {
            return "No Services advertised"
        }
        
        return services.map {$0.uuidString}.joined(separator: ", ")
    }
}

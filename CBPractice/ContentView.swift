//
//  ContentView.swift
//  CBPractice
//
//  Created by Reza Enayati on 3/26/25.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    
    @State private var bluetoothManger = BluetoothManager()
    @State private var showDeviceDetails = false
    @State private var selectedDevice: DiscoveredDevice?
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                //Stat Bar
                statusBar
                
                if bluetoothManger.discoverdDevices.isEmpty {
                    
                    BlUnavailabe
                    
                } else {
                    List(bluetoothManger.discoverdDevices) { device in
                        Button {
                            selectedDevice = device
                            showDeviceDetails = true
                        } label: {
                            deviceDetailButton(for: device)
                        }
                    }
                    .searchable(text: $searchText)
                }
                
                //Scan Button
                
                Button {
                    if bluetoothManger.isScanning {
                        bluetoothManger.stopScanning()
                    } else {
                        bluetoothManger.startScanning()
                    }
                    
                } label: {
                    scanButton
                }

            }
            .navigationTitle("Bluetooth Scanner")
            .sheet(isPresented: $showDeviceDetails) {
                if let device = selectedDevice {
                    DeviceDetailView(device: device)
                }
            }
        }
    }
    
    private var statusBar: some View {
        HStack {
            Image(systemName: bluetoothManger.isScanning ? "dot.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right")
                .foregroundStyle(bluetoothManger.isScanning ? .blue : .gray)
            Text(bluetoothManger.statusMessage)
                .font(.footnote)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        
    }
    
    private var BlUnavailabe: some View {
        VStack {
            if bluetoothManger.isScanning {
                ProgressView()
                    .padding()
                Text("Searching for nearby bluetooth devices...")
            } else {
                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    .font(.system(size: 50))
                    .foregroundStyle(.gray)
                    .padding()
                Text("No Devices Found")
                    .foregroundStyle(.gray)
                Text("Tap Scan to search for Devices")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func deviceDetailButton(for device: DiscoveredDevice) -> some View{
        HStack {
            VStack(alignment: .leading) {
                Text(device.name)
                    .font(.headline)
                Text("RSSI: \(device.rssi) dBm")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            HStack{
                Circle()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(device.signalColor)
                Text(device.signalStrength)
                    .font(.caption)
            }
        }
    }
    
    private var scanButton: some View {
        HStack {
            Image(systemName: bluetoothManger.isScanning ? "stop.circle.fill": "xmark.circle.fill")
            Text(bluetoothManger.isScanning ? "Stop Scanning" : "Scan for Devices")
        }
        .frame(minWidth: 20)
        .padding()
        .background(Color.blue)
        .foregroundStyle(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
}

#Preview {
    let testDevice = DiscoveredDevice(
        id: UUID(),
        name: "Test Device",
        rssi: -50,
        advetismentData: [
            "kCBAdvDataServiceUUIDs": [CBUUID(string: "180D")],  // Heart Rate Service
            "kCBAdvDataLocalName": "Test BLE Device",
            "kCBAdvDataManufacturerData": Data([0x01, 0x02, 0x03, 0x04])
        ]
    )
    ContentView()
}

struct DeviceDetailView: View {
    
    let device: DiscoveredDevice
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    deviceInfo
                } header: {
                    Text("Device Info")
                }
                
                Section {
                    LabledContent(label: "Services", value: device.services)
                    
                    if let localName = device.advetismentData["kCBAdvDataLocalName"] as? String {
                        LabledContent(label: "Advetised Name", value: localName)
                    }
                    
                    if let manufacturerData = device.advetismentData["kCBAdvDataManufacturerData"] as? Data {
                        
                        displaymanufacturerData(for: manufacturerData)
                    }
                } header: {
                    Text("Advertisment Data")
                }

                
            }
            .navigationTitle("Device Info")
        }
    }
    
    
    private var deviceInfo: some View {
        Group {
            LabledContent(label: "Name", value: device.name)
            LabledContent(label: "ID", value: device.id.uuidString)
            LabledContent(label: "Signal Strength", value: "\(device.rssi) dBm, (\(device.signalStrength))")
        }
    }
    
    private func displaymanufacturerData(for manufacturerData: Data) -> some View {
        VStack(alignment: .leading) {
            Text("Manufacturer Data:")
                .font(.headline)
                .padding(.bottom, 5)
            Text(manufacturerData.map { String(format: "%02X", $0) }.joined(separator: " "))
                .font(.system(.footnote, design: .monospaced))
                .lineLimit(15)
        }
    }
}


struct LabledContent: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundStyle(Color.secondary)
        }
    }
}



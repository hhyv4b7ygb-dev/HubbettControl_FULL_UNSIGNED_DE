import Foundation
import CoreBluetooth

final class BLEManager: NSObject, ObservableObject {
    @Published var status: String = "Suche…"
    @Published var verbunden: Bool = false
    
    private var central: CBCentralManager!
    private var device: CBPeripheral?
    private var tx: CBCharacteristic?
    
    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: .main)
    }
    
    func senden(_ text: String) {
        guard let dev = device, let tx = tx else { return }
        if let data = (text + "\n").data(using: .utf8) {
            dev.writeValue(data, for: tx, type: .withResponse)
        }
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            status = "Scanne…"
            central.scanForPeripherals(withServices: nil, options: nil)
        case .poweredOff:
            status = "Bluetooth aus"
        default:
            status = "Status: \(central.state.rawValue)"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover p: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let name = p.name ?? (advertisementData[CBAdvertisementDataLocalNameKey] as? String) ?? ""
        if name.contains("Hubbett") || name.contains("HUBBETT") {
            device = p
            status = "Verbinde…"
            central.stopScan()
            central.connect(p, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect p: CBPeripheral) {
        verbunden = true
        status = "Verbunden"
        p.delegate = self
        p.discoverServices(nil)
    }
}

extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for s in services {
            peripheral.discoverCharacteristics(nil, for: s)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let chs = service.characteristics else { return }
        for ch in chs {
            if ch.properties.contains(.write) || ch.properties.contains(.writeWithoutResponse) { tx = ch }
        }
    }
}

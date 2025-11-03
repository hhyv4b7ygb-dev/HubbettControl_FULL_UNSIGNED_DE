import SwiftUI
import CoreMotion

struct ContentView: View {
    @StateObject private var ble = BLEManager()
    @State private var pressed: Set<String> = []
    private let motion = CMMotionManager()
    @State private var pitch: Double = 0
    @State private var roll: Double = 0
    
    var body: some View {
        VStack(spacing: 14) {
            Text("Hubbett Control").font(.title.bold())
            Text(ble.status).font(.subheadline).foregroundStyle(.secondary)
            
            gridRow("A↑","A_UP_START","A_UP_STOP", "A↓","A_DOWN_START","A_DOWN_STOP")
            gridRow("B↑","B_UP_START","B_UP_STOP", "B↓","B_DOWN_START","B_DOWN_STOP")
            gridRow("C↑","C_UP_START","C_UP_STOP", "C↓","C_DOWN_START","C_DOWN_STOP")
            gridRow("D↑","D_UP_START","D_UP_STOP", "D↓","D_DOWN_START","D_DOWN_STOP")
            gridRow("Alle↑","ALL_UP_START","ALL_UP_STOP", "Alle↓","ALL_DOWN_START","ALL_DOWN_STOP")
            
            HStack(spacing: 12) {
                actionButton("Auto‑Waage") { ble.senden("AUTO_LEVEL") }
                actionButton("Stopp", color: .red) { ble.senden("STOP") }
            }
            
            HStack(spacing: 24) {
                VStack { Text("Neigung").font(.footnote); Text(String(format: "%.1f°", pitch)).font(.headline) }
                VStack { Text("Roll").font(.footnote); Text(String(format: "%.1f°", roll)).font(.headline) }
            }.padding(.top, 6)
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .onAppear { startMotion() }
    }
    
    func startMotion() {
        guard motion.isDeviceMotionAvailable else { return }
        motion.deviceMotionUpdateInterval = 0.1
        motion.startDeviceMotionUpdates(to: .main) { data, _ in
            guard let a = data?.attitude else { return }
            pitch = a.pitch * 180 / .pi
            roll  = a.roll  * 180 / .pi
        }
    }
    
    func gridRow(_ t1:String,_ s1:String,_ e1:String,_ t2:String,_ s2:String,_ e2:String) -> some View {
        HStack(spacing: 12) {
            holdButton(t1, start: s1, end: e1)
            holdButton(t2, start: s2, end: e2)
        }
    }
    
    func holdButton(_ title:String, start:String, end:String) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(white: 0.15))
            .frame(height: 56)
            .overlay(Text(title).font(.title3.bold()))
            .simultaneousGesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !pressed.contains(title) {
                        pressed.insert(title); ble.senden(start)
                    }
                }
                .onEnded { _ in
                    pressed.remove(title); ble.senden(end)
                }
            )
    }
    
    func actionButton(_ title:String, color: Color = .primary, action:@escaping()->Void) -> some View {
        RoundedRectangle(cornerRadius: 20).strokeBorder(color, lineWidth: 2)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color(white: 0.08)))
            .frame(height: 56)
            .overlay(Text(title).font(.title3.bold()).foregroundStyle(color))
            .onTapGesture(perform: action)
    }
}

#Preview { ContentView().preferredColorScheme(.dark) }

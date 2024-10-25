import ARKit
import SwiftUI

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        arView.session.run(config)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) { }
}

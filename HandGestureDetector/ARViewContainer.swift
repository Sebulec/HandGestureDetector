import ARKit
import SwiftUI

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var sessionHandler: SessionHandler
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        arView.session.run(config)
        
        arView.session.delegate = sessionHandler
        sessionHandler.createCircleForFingers(in: arView)
        sessionHandler.arView = arView
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) { }
}

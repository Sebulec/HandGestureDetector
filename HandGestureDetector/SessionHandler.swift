import ARKit
import SwiftUI

final class SessionHandler: NSObject, ObservableObject, ARSessionDelegate {
    private var thumbTipView: UIView!
    private var indexTipView: UIView!
    
    func createCircleForFingers(in view: UIView) {
        thumbTipView = createFingerView(in: view)
        indexTipView = createFingerView(in: view)
    }
    
    private func createFingerView(in view: UIView) -> UIView {
        let finger = UIView(frame: .init(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 10, height: 10))
        
        finger.backgroundColor = .green
        finger.layer.cornerRadius = 10
        view.addSubview(finger)
        
        return finger
    }
}

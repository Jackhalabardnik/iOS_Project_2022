import SwiftUI

extension View {
    
    func popup<OverlayView: View>(is_presented: Binding<Bool>,
                                  blurRadius: CGFloat = 3,
                                  blurAnimation: Animation? = .linear,
                                  @ViewBuilder overlayView: @escaping () -> OverlayView) -> some View {
        blur(radius: is_presented.wrappedValue ? blurRadius : 0)
            .animation(blurAnimation)
            .allowsHitTesting(!is_presented.wrappedValue)
            .modifier(OverlayModifier(is_presented: is_presented, overlayView: overlayView))
    }
}



struct OverlayModifier<OverlayView: View>: ViewModifier {
    
    @Binding var is_presented: Bool
    let overlayView: OverlayView
    
    init(is_presented: Binding<Bool>, @ViewBuilder overlayView: @escaping () -> OverlayView) {
        self._is_presented = is_presented
        self.overlayView = overlayView()
    }
    
    func body(content: Content) -> some View {
        content.overlay(is_presented ? overlayView : nil)
    }
}



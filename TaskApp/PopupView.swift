import SwiftUI

struct RoundedCornersShape: Shape {
    
    let radius: CGFloat
    let corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

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
    
    func cornerRadius(radius: CGFloat, corners: UIRectCorner = .allCorners) -> some View {
        clipShape(RoundedCornersShape(radius: radius, corners: corners))
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

struct BottomPopupView<Content: View>: View {
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                
                self.content
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                    .background(Color.white)
                    .cornerRadius(radius: 16, corners: [UIRectCorner.bottomLeft, UIRectCorner.bottomRight])
            }
        }
        .animation(.easeOut)
        .transition(.move(edge: .bottom))
    }
}



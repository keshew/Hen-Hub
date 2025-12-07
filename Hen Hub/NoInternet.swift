import SwiftUI

struct NoInternet: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
 
    var isPortrait: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }
    
    var isLandscape: Bool {
        verticalSizeClass == .compact && horizontalSizeClass == .regular
    }
    
    
    var body: some View {
        VStack {
            if isPortrait {
                ZStack {
                    Image("loading")
                        .resizable()
                        .ignoresSafeArea()
                    
                    Image(.error)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 170, height: 150)
                }
            } else {
                ZStack {
                    Image("BGforNotificationsLandscape")
                        .resizable()
                        .ignoresSafeArea()
                    
                    VStack(spacing: 30) {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Image(.error)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 170, height: 150)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 10)
                    }
                }
            }
        }
    }
}

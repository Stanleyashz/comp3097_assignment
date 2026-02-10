//
//  LaunchScreenView.swift
//  SmartTask
//
//  Mockup 1 - Launch Screen - iOS 13+ Compatible
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isActive: Bool = false
    @State private var opacity: Double = 0.0
    
    var body: some View {
        Group {
            if isActive {
                TaskListView()
            } else {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        Spacer()
                        
                        // App Icon
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.blue)
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        
                        // App Name
                        Text("TaskFlow")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Focus on what matters.")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        // Team Credits
                        Text("DEVELOPED BY TEAM ALPHA")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.bottom, 40)
                    }
                    .opacity(opacity)
                }
                .onAppear {
                    withAnimation(.easeIn(duration: 1.0)) {
                        self.opacity = 1.0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
    }
}

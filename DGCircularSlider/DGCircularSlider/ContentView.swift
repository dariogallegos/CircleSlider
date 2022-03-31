//
//  ContentView.swift
//  DGCircularSlider
//
//  Created by Darío Gallegos on 28/3/22.
//

import SwiftUI

struct ContentView: View {
    
    private let size: CGFloat = UIScreen.main.bounds.width / 1.5
    private let sizeThumb: CGFloat = 40
    private let lineWidth: CGFloat = 22
    
    @State var startAngle: Double = 0
    @State var toAngle: Double = 180
    
    @State var startProgress: CGFloat = 0
    @State var toProgress: CGFloat = 0.5
    
    
    var body: some View {
        
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack {
                
                //Clock design
                ZStack {
                    
                    ForEach(1...8, id: \.self) { index in
                        Rectangle()
                            .fill(.gray)
                            .frame(width: 1.5, height: 8)
                            .offset(y: (width / 2) + 30)
                        //Position clocks 360 / 8 = 45
                            .rotationEffect(.init(degrees: Double(index) * 45))
                    }
                    
                    let texts = [12, 18, 0, 6]
                    ForEach(texts.indices, id: \.self) { index in
                        Text("\(texts[index])")
                            .font(.subheadline.italic())
                            .foregroundColor(.gray)
                            .rotationEffect(.init(degrees: Double(index) * -90))
                            .offset(y: (width / 2) + 50)
                            .rotationEffect(.init(degrees: Double(index) * 90))
                    }
                }
                
                Circle()
                    .stroke(.gray.opacity(0.1), lineWidth: lineWidth)
                //Allowin reverse swiping
                let reverseTotation = (startProgress > toProgress) ? -Double((1 - startProgress) * 360) : 0
                
                Circle()
                    .trim(from: startProgress > toProgress ? 0 : startProgress, to: toProgress + (-reverseTotation / 360))
                    .stroke(AngularGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), .blue]), center: .center),
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .rotationEffect(Angle(degrees: -90))
                    .rotationEffect(.init(degrees: reverseTotation))
                
                indicator(size: sizeThumb)
                    .rotationEffect(.init(degrees: 90))
                    .rotationEffect(.init(degrees: -startAngle))
                    .background(.white, in: Circle())
                //moving to right and rotating
                    .offset(x: width / 2)
                    .rotationEffect(.init(degrees: startAngle))
                //apply gesture
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                onDrag(value: value, fromSlider: true)
                            })
                    )
                    .rotationEffect(.init(degrees: -90))
                
                indicator(size: sizeThumb)
                //rotating image inside the circle
                    .rotationEffect(.init(degrees: 90))
                    .rotationEffect(.init(degrees: -toAngle))
                    .background(.white, in: Circle())
                //moving to right and rotating
                    .offset(x: width / 2)
                    .rotationEffect(.init(degrees: toAngle))
                //apply gesture
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                onDrag(value: value)
                            })
                    )
                    .rotationEffect(.init(degrees: -90))
            }
        }
        .frame(width: size, height: size)
    }
    
    @ViewBuilder
    func indicator(size: CGFloat) -> some View {
        Circle()
            .strokeBorder(.white, lineWidth: 2)
            .background(Circle().fill(Color("thumbColor")))
            .shadow(color: .gray.opacity(0.5), radius: 2)
            .frame(width: size, height: size)
    }
    
    
    func onDrag(value: DragGesture.Value, fromSlider: Bool = false ) {
        // Converting translation into Angle
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        
        // Removing the buttons radius
        // Button diameter = 40
        // Radius = 20
        let radians = atan2(vector.dy - (sizeThumb / 2), vector.dx - (sizeThumb / 2))
        
        // Conveting into angle
        var angle = radians * 180 / .pi
        if angle < 0 {
            angle = 360 + angle
        }
        //Progress
        let progress = angle / 360
        
        if fromSlider {
            //Update from values
            self.startAngle = angle
            self.startProgress = progress
            
        } else {
            //Update to values
            self.toAngle = angle
            self.toProgress = progress
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            ContentView()
                .previewDevice("iPhone 13 Pro")
                .preferredColorScheme(.light)
            
            ContentView()
                .previewDevice("iPhone SE (2nd generation)")
                .preferredColorScheme(.dark)
        }
        
    }
}

//
//  MainView.swift
//  UI-552
//
//  Created by nyannyan0328 on 2022/04/28.
//

import SwiftUI

struct MainView: View {
    @State var currentTab : Tab = .bookmark
    init() {
        UITabBar.appearance().isHidden = true
    }
    var body: some View {
        VStack(spacing:0){
            
            
            TabView(selection: $currentTab) {
                
                Text("A")
                    .fillBG()
                    .tag(Tab.bookmark)
                
                Text("B")
                    .fillBG()
                    .tag(Tab.time)
                
                
                Text("C")
                    .fillBG()
                    .tag(Tab.camera)
                
                
                Text("D")
                    .fillBG()
                    .tag(Tab.chat)
                
                
                Text("E")
                    .fillBG()
                    .tag(Tab.settings)
                
                
            }
            
        CustomTabBar(currentTab: $currentTab)
            
            
        }
    }
   
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CustomTabBar : View{
    
    @Binding var currentTab : Tab
    
    @State var yOffset : CGFloat = 0
    var body: some View{
        
        GeometryReader{proxy in
            
            let widht = proxy.size.width
            
            HStack{
                
                ForEach(Tab.allCases,id:\.rawValue){tab in
                    
                    Button {
                        withAnimation{
                            
                            yOffset = -60
                            currentTab = tab
                        }
                        
                        withAnimation(.easeInOut(duration: 0.1).delay(0.1)){
                            
                            yOffset = 0
                        }
                        
                        
                    } label: {
                        
                        Image(tab.rawValue)
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 30, height: 30)
                            .foregroundColor(currentTab == tab ? Color("Purple") : .gray)
                            .lCenter()
                            .scaleEffect(currentTab == tab && yOffset != 0  ? 2 : 1)
                        
                    }

                        
                }
              
                
                
            }
            .lCenter()
            
            .background(alignment:.leading){
                
                Circle()
                    
                    .fill(Color("Yellow"))
                    .frame(width: 25, height: 25)
                    .offset(x: 15, y: yOffset)
                    .offset(x: indicatorOffset(widht: widht))
            }
           
            
        }
        .frame(height: 30)
        .padding([.horizontal,.top])
        .padding(.bottom,10)
        
        
        
    }
    
    func indicatorOffset(widht : CGFloat)->CGFloat{
        
      let index = CGFloat(getIndex())
        if index == 0 {return 0}
        
        let buttonWidth =  widht / CGFloat(Tab.allCases.count)
        
        return index * buttonWidth
        
        
    }
    func getIndex()->Int{
        
        switch currentTab {
        case .bookmark:
            return 0
        case .time:
            return 1
        case .camera:
            return 2
        case .chat:
            return 3
        case .settings:
            return 4
        }
    }
}





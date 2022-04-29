//
//  SearchView.swift
//  UI-552
//
//  Created by nyannyan0328 on 2022/04/29.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @StateObject var model : LocationManager = .init()
    @State var navigationTag : String?
    var body: some View {
        VStack{
            
            HStack{
                
                Button {
                    
                } label: {
                    
                    Image(systemName: "chevron.left")
                        .font(.title.weight(.semibold))
                    
                    
                    Text("Search Location")
                        .font(.title.weight(.black))
                    
                }
                .foregroundColor(.black)

            }
            .lLeading()
            
            
            HStack{
                
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                
                TextField("Find Location Here", text: $model.searchText)
                
            }
            .padding(.vertical,10)
            .padding(.horizontal)
            .background{
                
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(.white,lineWidth: 2)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: -5, y: -5)
                 
            }
            
            if let places  = model.fetchPlaces,!places.isEmpty{
                
                List{
                    
                    ForEach(places,id:\.self){place in
                        
                        
                        Button {
                            
                            
                            if let cordinate = place.location?.coordinate{
                                
                                model.mapView.region = .init(center: cordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                                
                                model.addDraggPin(cordinate: cordinate)
                                model.updatePlaceMark(location: .init(latitude: cordinate.latitude, longitude: cordinate.longitude))
                                
                               
                                
                            }
                            navigationTag = "MAPVIEW"
                            
                        } label: {
                            
                            
                            HStack(spacing:10){
                                
                                
                                Image(systemName: "mappin.circle.fill")
                                
                                VStack(alignment: .leading, spacing: 15) {
                                    
                                    HStack(spacing:15){
                                        
                                        
                                        Text(place.country ?? "")
                                            .font(.caption.bold())
                                        
                                        
                                        Text(place.name ?? "")
                                            .font(.caption.bold())
                                        
                                        Text(place.postalCode ?? "")
                                            .font(.caption.bold())
                                        
                                        
                                        
                                        
                                    }
                                    
                                    Text(place.locality ?? "")
                                        .font(.caption.bold())
                                    
                                    
                                    
                                }
                                .lLeading()
                                
                            }
                            
                        }

                        
                    }
                    
                    
                }
                .listStyle(.plain)
                
                
            }
            
            else{
                
                
                Button {
                    
                    if let cordinate = model.userLocations?.coordinate{
                        
                        model.mapView.region = .init(center: cordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                        
                        model.addDraggPin(cordinate: cordinate)
                        model.updatePlaceMark(location: .init(latitude: cordinate.latitude, longitude: cordinate.longitude))
                        
                        navigationTag = "MAPVIEW"
                        
                    }
                    
                } label: {
                    
                    Label {
                        Text("Use Current Location")
                    } icon: {
                      
                        
                        Image(systemName: "mappin.circle.fill")
                    }
                    .foregroundColor(.green)

                }
                .lLeading()
                .padding([.top,.bottom])
                
                
            }
            
       

            
            
            
        }
        .padding()
        .maxTop()
        .background{
            
            NavigationLink(tag: "MAPVIEW", selection: $navigationTag) {
                
            mapViewSelection()
                    .environmentObject(model)
                    .navigationBarHidden(true)
                    
                
            } label: {
                
                
            }
            .labelsHidden()

        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct mapViewSelection : View{
    
    @EnvironmentObject var model : LocationManager
    
    @Environment(\.dismiss) var dissmiss
    
    @Environment(\.colorScheme) var scheme
    
    var body: some View{
        
        ZStack{
            
            MapHelper()
                .environmentObject(model)
                .ignoresSafeArea()
            
            Button {
                dissmiss()
            } label: {
                
                Image(systemName: "chevron.left")
                    .font(.title)
                
                
            }
            .padding(.leading,20)
            .maxTopLeading()
            
            if let place = model.pickedPlaceMark{
                
                VStack(spacing:15){
                    
                    Text("Confim Location")
                        .font(.largeTitle.weight(.regular))
                    
                    HStack(spacing:15){
                        
                        
                        Image(systemName: "mappin.circle.fill")
                        
                        VStack(alignment: .leading, spacing: 15) {
                            
                            Text(place.name ?? "")
                                .font(.caption.bold())
                            
                            Text(place.locality ?? "")
                                .font(.caption.bold())
                            
                            
                            
                        }
                        .lLeading()
                        
                        
                     
                        
                        
                    }
                    
                    Button {
                        
                    } label: {
                        
                        Text("Confirm Location")
                            .font(.title)
                            .padding(.vertical,15)
                            .lCenter()
                        
                            .background{
                                
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.green)
                            }
                            .overlay(alignment: .trailing) {
                                
                                
                                Image(systemName: "arrow.right")
                                    .padding(.trailing,10)
                                
                                
                                
                            }
                    }
                  
                    .foregroundColor(.white)

                    
                    
                }
                .padding()
                .background{
                    
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(scheme == .dark ? .black : .white)
                        .ignoresSafeArea()
                }
                .maxBottom()
            }

        }
        .onDisappear {
            
            model.pickedLocation = nil
            model.pickedPlaceMark = nil
            
            model.mapView.removeAnnotations(model.mapView.annotations)
        }
    }
}

struct MapHelper : UIViewRepresentable{
    
    @EnvironmentObject var model : LocationManager
    
    func makeUIView(context: Context) -> MKMapView {
        
        return model.mapView
        
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
}



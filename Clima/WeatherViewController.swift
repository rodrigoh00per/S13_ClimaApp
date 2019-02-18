//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation //This library is for the Location
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController , CLLocationManagerDelegate,ChangeCityDelegate{
    
    
  
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather";
    let appid = "a7bbbd5e82c675f805e7ae084f742024";
  
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    
    let locationManager = CLLocationManager();
      let weatherDataModel = WeatherDataModel();
    
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         
        //TODO:Set up the location manager here.
        locationManager.delegate = self; //Remember you are voluntary for use the location and the thing that manage the location is your controller
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;//define de precission of the gps
        locationManager.requestWhenInUseAuthorization(); //show a pop us for the user allows to use his location
        locationManager.startUpdatingLocation();
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    

    func getWeatherData(url:String,params:[String:String]){
        
        Alamofire.request(url, method: .get , parameters: params).responseJSON{
            response in
                if response.result.isSuccess{
                      print("Success The Weather data is here");
                    let WeatherResult: JSON = JSON(response.result.value!);
                    self.updateWeatherData(json: WeatherResult);
                }
                else{
                    print("Problem with the connection \(response.result.error!)");
                    self.cityLabel.text = "Connection Issues";
                }
            
        }
    }
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    //Este metodo nos permite poder parsear la data que ya trajimos atraves de la peticion que se hizo a  la API
    func updateWeatherData (json :JSON){

        if let tempResult = json["main"]["temp"].double {
            
            weatherDataModel.temperature = Int(tempResult - 273.15);
            weatherDataModel.city = json["name"].stringValue;
            weatherDataModel.condition = json["weather"][0]["id"].intValue;
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition);
            
            
              updateUIWithWeatherData();
        }
        else{
            cityLabel.text = "Weather Unavailable";
        }
    
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    //ESTA FUNCION ACTUALIZA TANTO LOS LABELS COMO LA IMAGEN
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModel.city;
        temperatureLabel.text = String(weatherDataModel.temperature);
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName);
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1 ];
        if location.horizontalAccuracy > 0 {
            //Con esto le decimos oye
            // si tienes una localizacion  pues  parale
            locationManager.stopUpdatingLocation();
            locationManager.delegate = nil;//esta linea se pone en caso de que querramos que solo nos traiga la ultima localizacion
            print("La longitud es  \(location.coordinate.longitude)  y su latitud es   \(location.coordinate.latitude)");
            
            let latitude:String = String(location.coordinate.latitude);
            let longitude:String = String(location.coordinate.longitude);
            

            let params :[String:String] = ["lat":latitude,"lon":longitude,"appid":appid]
            
          
            getWeatherData(url: WEATHER_URL,params: params);
            
          
            
            
            
            
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error);
        cityLabel.text = "Location Unavailable";
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    //ya se esta cumpliendo con el contrato
    func userEnteredANewCityName(city: String) {
        print(city);
        let params :[String:String] = ["q":city,"appid":appid];
        self.getWeatherData(url: self.WEATHER_URL, params: params);
    }
    

    
    //Write the PrepareForSegue Method here
    //este metodo se ejecuta cuando hacemos la accion para hacer le cambio de pantall
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "changeCityName"){
         
            
        let destinationVC = segue.destination as! ChangeCityViewController; //AQUI LE DECIMOS AQUI  VA A SER DE TAL CLASE
            
            destinationVC.delegate = self; //AQUI NOSOTROS YA LE DECIMOS OYE YO SOY APTO PARA MANEJAR ESTA PARTE
            
            
        }
    }
    
    
    
}



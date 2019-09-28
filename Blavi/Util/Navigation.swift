import UIKit
import MapKit
class Navigaiton: CLLocationManager{
    override init() {
        super.init()
    }
    func getCurrentLocation(target: UIViewController)->CLLocation?{
        guard let Current_Location = self.location else{
            let alert = UIAlertController(title: "위치확인 오류", message: "현재 위치를 확인할 수 없습니다.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "확인", style: .cancel)
            alert.addAction(ok)
            target.present(alert, animated: true)
            return nil
        }
        return Current_Location
    }
}

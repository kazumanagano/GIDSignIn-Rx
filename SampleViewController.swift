
 import UIKit
 import RxSwift
 import GoogleSignIn
 
 class SampleViewController: UIViewController {
 	private let disposeBag = DisposeBag()
  
 	override func viewDidLoad() {
        super.viewDidLoad()

        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().rx.signInSilent.asObservable()
                .subscribe(onNext: { user in
                    print("username: \(user.profile!.name!), email: \(user.profile!.email!)")
                })
                .disposed(by: disposeBag)
        } else {
            GIDSignIn.sharedInstance().rx.signIn.asObservable()
                .subscribe(onNext: { user in
                    print("username: \(user.profile!.name!), email: \(user.profile!.email!)")
                })
                .disposed(by: disposeBag) 
        }
           
      }
 }
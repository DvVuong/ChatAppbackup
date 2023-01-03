//
//  RxPresenter.swift
//  ChatAppDemo
//
//  Created by BeeTech on 03/01/2023.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase
protocol  RxPresenterDelegate: NSObject {
    func didValidateEmail(_ bool: Bool, result: String)
}


class RxPresenter {
    private weak var view: RxPresenterDelegate?
    private let chr: String = "Hello RxSwift"
    private let disposeBag = DisposeBag()
    var subject = PublishSubject<String>()
    var error = PublishSubject<String>()
    private var users = [User]()
    let db = Firestore.firestore()
    init(with view: RxPresenterDelegate) {
        self.view = view
        
        
        
        subject.map {(self.validateEmail($0))}.subscribe {[weak self] valipar in
            if ((valipar.element?.0) != nil) {
                self?.error.onNext(valipar.element?.1 ?? "")
            }
        }.disposed(by: disposeBag)
        
    }
    
    
    
    func fecthDataFromFirebase() -> Observable<[User]> {
        return Observable.create { observable in
            self.db.collection("user").addSnapshotListener{(snapShot, error) in
                if error != nil {return}
                guard let data = snapShot?.documents else {return}
                let user = data.map({User(dict: $0.data())})
                //print(user)
                observable.onNext(user)
                observable.onCompleted()
            }
            return Disposables.create()
        }
    }
    func validateEmail(_ email: String)  -> (Bool, String){
        if email.isEmpty {
            return (false, "Email can not empty")
        }
        return (true, "")
    }
    
    
}

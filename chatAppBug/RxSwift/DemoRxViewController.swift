//
//  DemoViewController.swift
//  ChatAppDemo
//
//  Created by BeeTech on 03/01/2023.
//

import UIKit
import RxCocoa
import RxSwift

final class DemoRxViewController: UIViewController {
    
    static func instance() -> DemoRxViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RxViewController") as! DemoRxViewController
        return vc
    }
    
    @IBOutlet private weak var tableview: UITableView!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var lbError: UILabel!
    private lazy var prester = RxPresenter(with: self)
    private let disposeBag = DisposeBag()

    let ios = 1
    let android = 2
    let flutter = 3
    let sequence = 0..<3
    override func viewDidLoad() {
        super.viewDidLoad()
       onBind()
        beingEditingTextField()
        prester.error.subscribe {[weak self] error in
            self?.lbError.text = error
        }.disposed(by: disposeBag)
        //}
        // Do any additional setup after loading the view.
        //prester.createNewCollection()
//        let observable1 = Observable<Int>.just(ios)
//        observable1.subscribe { (value) in
//            if let value = value.element {
//                print("observable1",value)
//            }
//            
//        }.disposed(by: DisposeBag())
//        let observable2 = Observable.of([ios, flutter, android])
//        observable2.subscribe { (value) in
//            if let value = value.element {
//                print("observable2",value)
//            }
//        }.disposed(by: DisposeBag())
//        
//        let observable3 = Observable<[Int]>.from(optional: [ios, flutter, android])
//        observable3.subscribe {(value) in
//            if let value = value.element {
//                print("observable3",value)
//            }
//        }.disposed(by: DisposeBag())
//        
//        let observable4 = Observable<Int>.just(ios)
//        observable4.subscribe(onNext: {(value) in
//            print(value)
//        } , onError: {error in
//            print(error.localizedDescription)
//        }, onCompleted: {
//            print("Completed")
//        }).disposed(by: disposeBag)
//        
//        var intertor = sequence.makeIterator()
//        while let n = intertor.next() {
//            print("n", n)
//        }
//        let observable = Observable<Void>.empty()
//
//            observable.subscribe(
//              onNext: { element in
//                print(element)
//            },
//              onCompleted: {
//                print("Completed")
//              }
//            )
                
    }
    
    func onBind() {
        prester.fecthDataFromFirebase().subscribe { user in
            let observable = Observable.of(user)
            observable.bind(to: self.tableview.rx.items(cellIdentifier: "RxCell", cellType: RxCell.self)) {
                (index, element, cell) in
               cell.updateUI(element)
        
            }.disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
        
    }
    
    func beingEditingTextField() {
        textField.addTarget(self, action: #selector(handDleTextField(_:)), for: .editingChanged)
//        textField.rx.controlEvent(.editingChanged).asObservable().subscribe { [weak self] _ in
//            self?.prester.validateEmail(self?.textField.text ?? "")
//        }.disposed(by: disposeBag)
        
    }
    
    @objc func handDleTextField(_ textField: UITextField) {
        prester.subject.onNext(textField.text ?? "")
    }
}


extension DemoRxViewController: RxPresenterDelegate {
    func didValidateEmail(_ bool: Bool, result: String) {
        print("asd")
    }
    
        
}

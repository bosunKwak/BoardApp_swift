//
//  ComposeViewController.swift
//  BoardApp_swift
//
//  Created by 곽보선 on 2022/03/12.
//

import UIKit

class ComposeViewController: UIViewController {

    var editTarget: Memo?
    var originalMemoContent: String?
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)

    }
    
    @IBOutlet weak var memoTextView: UITextView!
    @IBAction func save(_ sender: Any) {
        
        guard let memo = memoTextView.text, memo.count > 0
        else{
            alert(message: "메모를 입력하세요")
            return
        }
        
//        let newMemo = Memo(content: memo)
//        Memo.dummyMemoList.append(newMemo)
       
        if let target = editTarget{
            target.content = memo
            DataManager.shared.saveContext()
            NotificationCenter.default.post(name: ComposeViewController.memoDidChange, object: nil)
        }else{
            DataManager.shared.addNewMemo(memo)
            NotificationCenter.default.post(name: ComposeViewController.newMemoDidInsert, object: nil)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let memo = editTarget{
            navigationItem.title = "메모 편집"
            memoTextView.text = memo.content
            originalMemoContent = memo.content
        }else{
            navigationItem.title = "새 메모"
            memoTextView.text = ""
        }
        // Do any additional setup after loading the view.
        
        memoTextView.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.presentationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.presentationController?.delegate = nil
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ComposeViewController: UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        if let original = originalMemoContent, let edited = textView.text{
//            isModalInPresentation = original != edited
            if #available(iOS 13.0, *){
                isModalInPresentation = original != edited
            }else{
                
            }
        }
    }
}

extension ComposeViewController: UIAdaptivePresentationControllerDelegate{
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        let alert = UIAlertController(title: "알림", message: "편집할 내용을 저장할까요?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default){ [weak self](action) in self?.save(action)}
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel){[weak self] (action) in self?.close(action)}
        alert.addAction(cancelAction)
        
        present(alert, animated:true, completion: nil)
    }
}


extension ComposeViewController{
    static let newMemoDidInsert = Notification.Name(rawValue: "newMemoDidInsert")
    static let memoDidChange = Notification.Name(rawValue: "memoDidChange")
}

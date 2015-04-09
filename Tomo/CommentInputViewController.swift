import UIKit

class CommentInputViewController: BaseViewController {

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.textView.becomeFirstResponder()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notification
    
    func keyboardWillShow(notification: NSNotification) {
        if let dic = notification.userInfo {
            if let keyboardFrame = dic[UIKeyboardFrameEndUserInfoKey]?.CGRectValue() {
                if let duration = dic[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
                    self.bottomSpace.constant = keyboardFrame.height
                    
                    UIView.animateWithDuration(duration, animations: { () -> Void in
                        self.view.layoutIfNeeded()
                    })
                }
            }
        }
    }
    
    func keyboardDidHide(notification: NSNotification) {
        if let dic = notification.userInfo {
            if let duration = dic[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
                self.bottomSpace.constant = 0
                
                UIView.animateWithDuration(duration, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
     }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

import UIKit

protocol ContactDetailViewControllerDelegate: class {
    func add(_ contact: Contact)
    func remove(_ contact: Contact)
}

final class ContactDetailViewController: UIViewController {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var firstNameTextField: ContactDetailTextField!
    @IBOutlet private weak var lastNameTextField: ContactDetailTextField!
    @IBOutlet private weak var phoneTextField: ContactDetailTextField!
    @IBOutlet private weak var emailTextField: ContactDetailTextField!
    @IBOutlet private weak var streetTextField: ContactDetailTextField!
    @IBOutlet private weak var apartmentTextField: ContactDetailTextField!
    @IBOutlet private weak var cityTextField: ContactDetailTextField!
    @IBOutlet private weak var stateTextField: ContactDetailTextField!
    @IBOutlet private weak var zipcodeTextField: ContactDetailTextField!
    @IBOutlet private weak var emergencyContactLabel: ContactDetailLabel!
    @IBOutlet private weak var emergencyContactSwitch: UISwitch!
    @IBOutlet private weak var removeButton: RoundButton!
    
    private var model: ContactDetailModel!
    private weak var delegate: ContactDetailViewControllerDelegate!
    private var activeTextField: UITextField?
    
    private static let viewCornerRadius = 10
    private static let pickerTextFieldIcon = "chevron.right"
    private static let pickerDoneButtonText = "Done"
    private static let removeButtonText = "Delete Contact"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initGestureRecognizers()
        initNotificationObservers()
        initViewProperties()
        initViewContents()
    }
    
    override func viewDidLayoutSubviews() {
        prettifyViews()
    }
    
    @IBAction func firstNameChanged(_ sender: UITextField) {
        model.updateContact(value: sender.text, for: InputField.firstName)
    }
    
    @IBAction func lastNameChanged(_ sender: UITextField) {
        model.updateContact(value: sender.text, for: InputField.lastName)
    }
    
    @IBAction func phoneChanged(_ sender: UITextField) {
        model.updateContact(value: sender.text, for: InputField.phone)
    }
    
    @IBAction func emailChanged(_ sender: UITextField) {
        model.updateContact(value: sender.text, for: InputField.email)
    }
    
    @IBAction func streetChanged(_ sender: UITextField) {
        model.updateContact(value: sender.text, for: InputField.street)
    }
    
    @IBAction func apartmentChanged(_ sender: UITextField) {
        model.updateContact(value: sender.text, for: InputField.apartment)
    }
    
    @IBAction func cityChanged(_ sender: UITextField) {
        model.updateContact(value: sender.text, for: InputField.city)
    }
    
    @IBAction func zipcodeChanged(_ sender: UITextField) {
        model.updateContact(value: sender.text, for: InputField.zipcode)
    }
    
    @IBAction func emergencyContactChanged(_ sender: UISwitch) {
        model.updateContact(value: sender.isOn.description, for: InputField.emergency)
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        delegate.add(model.contact)
    }
    
    @IBAction func removeTapped(_ sender: RoundButton) {
        delegate.remove(model.contact)
    }
    
    func setup(model: ContactDetailModel, delegate: ContactDetailViewControllerDelegate) {
        self.model = model
        self.delegate = delegate
    }
    
    private func prettifyViews() {
        let topLeftRightCorners: UIRectCorner = [.topLeft, .topRight], bottomLeftRightCorners: UIRectCorner = [.bottomLeft, .bottomRight]
        let cornerRadius = CGFloat(ContactDetailViewController.viewCornerRadius)
        
        firstNameTextField.roundCorners(corners: topLeftRightCorners, radius: cornerRadius)
        lastNameTextField.roundCorners(corners: bottomLeftRightCorners, radius: cornerRadius)
        
        phoneTextField.roundCorners(corners: topLeftRightCorners, radius: cornerRadius)
        emailTextField.roundCorners(corners: bottomLeftRightCorners, radius: cornerRadius)
        
        streetTextField.roundCorners(corners: topLeftRightCorners, radius: cornerRadius)
        zipcodeTextField.roundCorners(corners: bottomLeftRightCorners, radius: cornerRadius)
        
        emergencyContactLabel.roundCorners(corners: [topLeftRightCorners, bottomLeftRightCorners], radius: cornerRadius)
    }
    
    private func initNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func initGestureRecognizers() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewTouched))
        scrollView.addGestureRecognizer(recognizer)
        
        scrollView.gestureRecognizers?.forEach {
            $0.delaysTouchesBegan = true
        }
    }
    
    private func initViewProperties() {
        initTextFieldDelegates()
        initTextFieldKeyboardTypes()
    }
    
    private func initViewContents() {
        initStaticContent()
        initDynamicContent()
    }
    
    private func initTextFieldDelegates() {
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        phoneTextField.delegate = self
        emailTextField.delegate = self
        streetTextField.delegate = self
        apartmentTextField.delegate = self
        cityTextField.delegate = self
        stateTextField.delegate = self
        zipcodeTextField.delegate = self
    }
    
    private func initTextFieldKeyboardTypes() {
        firstNameTextField.keyboardType = InputField.firstName.keyboardType
        lastNameTextField.keyboardType = InputField.lastName.keyboardType
        phoneTextField.keyboardType = InputField.phone.keyboardType
        emailTextField.keyboardType = InputField.email.keyboardType
        streetTextField.keyboardType = InputField.street.keyboardType
        apartmentTextField.keyboardType = InputField.apartment.keyboardType
        cityTextField.keyboardType = InputField.city.keyboardType
        stateTextField.keyboardType = InputField.state.keyboardType
        zipcodeTextField.keyboardType = InputField.zipcode.keyboardType
    }
    
    private func initStaticContent() {
        firstNameTextField.placeholder = InputField.firstName.rawValue
        lastNameTextField.placeholder = InputField.lastName.rawValue
        phoneTextField.placeholder = InputField.phone.rawValue
        emailTextField.placeholder = InputField.email.rawValue
        streetTextField.placeholder = InputField.street.rawValue
        apartmentTextField.placeholder = InputField.apartment.rawValue
        cityTextField.placeholder = InputField.city.rawValue
        stateTextField.placeholder = InputField.state.rawValue
        zipcodeTextField.placeholder = InputField.zipcode.rawValue
        
        // bug: text changes position of auto-layout constraint when set programmatically
        //emergencyContactLabel.text = InputField.emergency.rawValue
        
        removeButton.setTitle(ContactDetailViewController.removeButtonText, for: .normal)
    }
    
    private func initDynamicContent() {
        firstNameTextField.text = model.getInputText(for: InputField.firstName)
        lastNameTextField.text = model.getInputText(for: InputField.lastName)
        phoneTextField.text = model.getInputText(for: InputField.phone)
        emailTextField.text = model.getInputText(for: InputField.email)
        streetTextField.text = model.getInputText(for: InputField.street)
        apartmentTextField.text = model.getInputText(for: InputField.apartment)
        cityTextField.text = model.getInputText(for: InputField.city)
        
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 300, width: view.frame.width, height: 300))
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: ContactDetailViewController.pickerDoneButtonText, style: UIBarButtonItem.Style.done, target: self, action: #selector(pickerDone))
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false
        toolBar.sizeToFit()
        toolBar.setItems([spaceButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        stateTextField.inputView = pickerView
        stateTextField.inputAccessoryView = toolBar
        stateTextField.rightViewMode = .always
        
        let image = UIImage(systemName: ContactDetailViewController.pickerTextFieldIcon)
        image?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .lightGray
        stateTextField.rightView = imageView
        
        stateTextField.text = model.getInputText(for: InputField.state)
        pickerView.selectRow(model.getStateOptionIndex(), inComponent: 0, animated: true)
        
        zipcodeTextField.text = model.getInputText(for: InputField.zipcode)
        emergencyContactSwitch.isOn = model.getEmergencyFlag()
        
        removeButton.isEnabled = !model.contact.isEmpty
    }
    
    @objc func scrollViewTouched() {
        view.endEditing(true)
    }
    
    @objc func pickerDone() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let activeTextField = activeTextField else { return }
        
        let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: view).maxY
        let topOfKeyboard = view.frame.height - keyboardSize.height
        
        if bottomOfTextField > topOfKeyboard {
            view.frame.origin.y = -keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
}

extension ContactDetailViewController: ContactDetailModelDelegate {
    
    func save(isEnabled: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = isEnabled
    }
    
}

extension ContactDetailViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
      
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension ContactDetailViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let displayValue = model.stateOptions[row].0
        let storedValue = model.stateOptions[row].1
        
        stateTextField.text = storedValue
        model.updateContact(value: displayValue, for: InputField.state)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let displayValue = model.stateOptions[row].0
        
        return displayValue
    }
    
}

extension ContactDetailViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return model.stateOptions.count
    }
    
}

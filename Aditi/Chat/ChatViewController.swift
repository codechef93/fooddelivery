//
//  ChatViewController.swift
//  Aditi
//
//  Created by macbook on 05/05/2020.
//  Copyright © 2020 Shezu. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView


class ChatViewController: MessagesViewController, MessagesDataSource {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var messageList: [Message] = []
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    var channel : Channel!
    lazy var viewModel = ChatViewModel(delegate: self, channelId: channel.id)
    
    override func viewWillAppear(_ animated: Bool) {
        let bbi = UIBarButtonItem(image:  UIImage(named: "arrow_back"), style: .plain, target: self, action: #selector(popAndMarkRead))
        navigationItem.backBarButtonItem = bbi
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageCollectionView()
        configureMessageInputBar()
//        title = memberType() == .customer ? "客戶服務" : "管理员"
        title = memberType() == .customer ? "客戶服務" : "客戶服務"
        viewModel.observeMessages()
        #if Admin
        addExitButton()
        #endif
    }
    
    func addExitButton(){
//        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 44))
//        btn.setImage(UIImage(named: "exit"), for: .normal)
//        btn.addTarget(self, action: #selector(endChat), for: .touchUpInside)
        let bbi = UIBarButtonItem(image: UIImage(named: "exit"), style: .plain, target: self, action: #selector(endChat))
        navigationItem.rightBarButtonItem = bbi
    }
    @objc func endChat() {
        let channelId = channel.id
        let alert = UIAlertController(title: NSLocalizedString("endSession", comment: ""), message: NSLocalizedString("endSessionMsg", comment: ""), preferredStyle: .alert)
        let yes = UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .destructive) { [weak self] (action) in
            if AppDelegate.noInternet() {return}
            UIApplication.showLoader()
            channelsCol.document(channelId).updateData(["active":false]) { (err) in
                if let e = err {
                    UIApplication.showError(message: e.localizedDescription, delay: 1)
                }else{
                    UIApplication.showSuccess(message: Messages.sessionEnded, delay: 1)
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
        let no = UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .default) {(_) in}
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func popAndMarkRead(){
        channelsCol.document(channel.id).updateData(["read":true])
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.placeholder = "在此處輸入消息"
        messageInputBar.inputTextView.tintColor = .white
        messageInputBar.inputTextView.textColor = .white
        messageInputBar.sendButton.setTitleColor(.white, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.red.withAlphaComponent(0.3),
            for: .highlighted
        )
        messageInputBar.backgroundView.backgroundColor = Constants.navBarColor
        messageInputBar.sendButton.title = "發送"
    }
    
    
    // MARK: - MessagesDataSource
    
    func currentSender() -> SenderType {
        return User.shared!
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
//        if indexPath.row == 0 && indexPath.section == 0 { return nil }
//        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let msg = messageList.first(where: { $0.id == message.messageId })!
        if msg.msgType == .firstMsg { return nil}

        let name = msg.senderName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    func isFromCurrentSender(message: MessageType) -> Bool {
        let mm = message as! Message
        return mm.senderID == currentSender().senderId
    }
}

// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        print("Image tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }

    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }
    
    

}

// MARK: - MessageLabelDelegate

extension ChatViewController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }

    func didSelectHashtag(_ hashtag: String) {
        print("Hashtag selected: \(hashtag)")
    }

    func didSelectMention(_ mention: String) {
        print("Mention selected: \(mention)")
    }

    func didSelectCustom(_ pattern: String, match: String?) {
        print("Custom data detector patter selected: \(pattern)")
    }

}

// MARK: - MessageInputBarDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

        // Here we can parse for which substrings were autocompleted
        let attributedText = messageInputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in

            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }

        guard let text = messageInputBar.inputTextView.text else {return}
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()

        // Send button activity animation
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.sendMessage(message: text)
            self?.messageInputBar.sendButton.stopAnimating()
            self?.messageInputBar.inputTextView.placeholder = "在此處輸入消息"
        }
    }

}

extension ChatViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .white
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        let msg = messageList.first(where: { $0.id == message.messageId })!
//        if msg.msgType == .firstMsg {
//            return .lightGray
//        }
        return isFromCurrentSender(message: message) ? Constants.goldenColor : Constants.navBarColor
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let msg = messageList.first(where: { $0.id == message.messageId })!
        if msg.msgType == .firstMsg {
             return .bubble
        }
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let mm = message as! Message
        if mm.senderID ==  channel.member.id {
            let avatar = Avatar(image: UIImage(named: "member"), initials: "")
            avatarView.set(avatar: avatar)
            let msg = messageList.first(where: { $0.id == mm.messageId })!
            if msg.msgType == .firstMsg {
                avatarView.alpha = 0
            }
            avatarView.backgroundColor = .clear
        }else{
            let avatar = Avatar(image: UIImage(named: "admin"), initials: "initials")
            avatarView.set(avatar: avatar)
            avatarView.backgroundColor = .clear
            let msg = messageList.first(where: { $0.id == mm.messageId })!
            
            if msg.msgType == .firstMsg {
                avatarView.alpha = 0
            }
        }
    }
    
    // MARK: - Location Messages

    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }

}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 17
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messagePadding(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        let msg = messageList.first(where: { $0.id == message.messageId })!
        if msg.msgType == .firstMsg {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 100)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension ChatViewController: ChatViewModelDelegate {
    func addMessages(msgs: [Message]) {
        self.messageList.append(contentsOf: msgs)
        self.messageList.sort(by: { $0.sentDate < $1.sentDate })
        messagesCollectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
            self.messagesCollectionView.scrollToBottom(animated: true)
            UIApplication.hideLoader()
        })
    }
}

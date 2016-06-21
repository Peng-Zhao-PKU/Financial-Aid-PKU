//
//  FormOptionTableViewController.swift
//  FinancialAid
//
//  Created by GaoChengliang on 16/5/19.
//  Copyright © 2016年 pku. All rights reserved.
//

import UIKit
import MobileCoreServices
import DKImagePickerController
import SVProgressHUD

class FormOptionTableViewController: UITableViewController {

    // Inited from prepare for segue
    var form: Form!
    var image: UIImage?
    var options = [Int]()

    var tableViewCellIdentifiers = ["FillFormTableViewCell", "PDFTableViewCell", "UploadImageTableViewCell"]

    private struct Constants {
        static let HelpSegueIdentifier = "FormGuideSegue"
        static let FillFormSegueIdentifier = "FormFillSegue"
        static let UploadImageSegueIdentifier = "UploadImageSegue"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        title = form.name
        if form.isStepFill {
            options.append(0)
        }
        if form.isStepPdf {
            options.append(1)
        }
        if form.isStepUpload {
            options.append(2)
        }
        if form.isStepHelp {
            let barItem = UIBarButtonItem(image: UIImage(named: "FillFormGuide"),
                                          style: .Done, target: self,
                                          action: #selector(FormOptionTableViewController.formHelp))
            self.navigationItem.rightBarButtonItem = barItem
        }
    }

    func formHelp() {
        performSegueWithIdentifier(Constants.HelpSegueIdentifier, sender: self)
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            tableViewCellIdentifiers[options[indexPath.row]], forIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if options[indexPath.row] == 1 {
            ContentManager.sharedInstance.getPDF("\(form.ID)", email: User.sharedInstance.email) {
                (error) in
                if let error = error {
                    if case NetworkErrorType.NetworkUnreachable(_) = error {
                        SVProgressHUD.showErrorWithStatus(
                            NSLocalizedString("Network timeout",
                                comment: "network timeout or interruptted")
                        )
                    } else if case NetworkErrorType.NetworkWrongParameter(_, let errno) = error {
                        if errno == 201 {
                            SVProgressHUD.showErrorWithStatus(
                                NSLocalizedString("You have not filled the form",
                                    comment: "form not filled")
                            )
                        } else if errno == 203 {
                            SVProgressHUD.showErrorWithStatus(
                                NSLocalizedString(
                                    "Email address is not valid, please update in personal center",
                                    comment: "email address is not valid")
                            )
                        } else {
                            SVProgressHUD.showErrorWithStatus(
                                NSLocalizedString("Server error occurred",
                                    comment: "unknown error")
                            )
                        }
                    }
                } else {
                    SVProgressHUD.showSuccessWithStatus(
                        NSLocalizedString("The PDF is sent to your email address", comment: "Get PDF success")
                    )
                }
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       // guard let fwvc = segue.destinationViewController as? FormWebViewController else { return }
        guard let segueIdentifer = segue.identifier else { return }
        switch segueIdentifer {
        case Constants.HelpSegueIdentifier:
            if let fwvc = segue.destinationViewController as? FormWebViewController {
                fwvc.title = NSLocalizedString("Tips", comment: "tips for filling the form")
                fwvc.url = NetworkManager.sharedInstance.relativeURL(form.helpPath)
            }
        case Constants.FillFormSegueIdentifier:
            if let fwvc = segue.destinationViewController as? FormWebViewController {
                fwvc.title = NSLocalizedString("Fill form", comment: "fill the form")
                fwvc.url = NetworkManager.sharedInstance.relativeURL(form.fillPath)
            }
        case Constants.UploadImageSegueIdentifier:
            if let uivc = segue.destinationViewController as? UploadImageCollectionViewController {
                uivc.formID = form.ID
            }
        default:
            break
        }
    }
}

import UIKit
import UniformTypeIdentifiers
import Utility

/// Static factory for view controllers.
@MainActor struct ViewControllerFactory {
    
    static func makeAuthorization(withSuccessHandler success: @escaping () -> ()) -> AuthorizationController {
        let storyboard = UIStoryboard(name: "Authorization", bundle: nil)
        
        guard let controller = storyboard.instantiateInitialViewController() as? AuthorizationController else {
            fatalError("Could not instantiate controller.")
        }

        controller.didAuthorizeHandler = success
        controller.modalPresentationStyle = .formSheet
        controller.isModalInPresentation = true

        return controller
    }
    
    static func makeEditor(
        with source: VideoSource,
        previewImage: UIImage?,
        delegate: EditorViewControllerDelegate?
    ) -> EditorViewController {
        
        let storyboard = UIStoryboard(name: "Editor", bundle: nil)
        let videoController = VideoController(source: source, previewImage: previewImage)
        
        guard let controller = storyboard.instantiateInitialViewController(creator: {
            EditorViewController(videoController: videoController, delegate: delegate, coder: $0)
        }) else { fatalError("Could not instantiate controller.") }
        
        return controller
    }
    
    static func makeAbout(withDelegate delegate: AboutViewControllerDelegate?) -> UIViewController {
        let storyboard = UIStoryboard(name: "About", bundle: nil)
        
        guard let navigationController = storyboard.instantiateInitialViewController() as? UINavigationController,
              let controller = navigationController.topViewController as? AboutViewController
        else {
            fatalError("Could not instantiate controller.")            
        }
        
        controller.delegate = delegate
        return navigationController
    }
    
    static func makePurchase() -> UIViewController {
        let storyboard = UIStoryboard(name: "Purchase", bundle: nil)
        
        guard let controller = storyboard.instantiateInitialViewController() as? PurchaseViewController else {
            fatalError("Could not instantiate controller.")
        }
        
        controller.configureCompactSheetPresentation()
        return controller
    }
    
    static func makeFilePicker(withDelegate delegate: UIDocumentPickerDelegate?) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.movie],
            asCopy: true
        )
        
        picker.shouldShowFileExtensions = true
        picker.delegate = delegate
        return picker
    }
    
    /// A picker configured to record videos if the device can record videos, otherwise `nil`.
    ///
    /// If the preferred camera is not available, falls back to `.rear`.
    static func makeCamera(
        with preferredCamera: UIImagePickerController.CameraDevice,
        delegate: UIImagePickerController.Delegate? = nil
    ) -> UIImagePickerController? {
        
        guard UIImagePickerController.canRecordVideos else { return nil }
        
        let camera = UIImagePickerController.isCameraDeviceAvailable(preferredCamera)
            ? preferredCamera
            : .rear
        
        let picker = UIImagePickerController()
        
        picker.delegate = delegate
        picker.mediaTypes = [UTType.movie.identifier]
        picker.sourceType = .camera
        picker.cameraCaptureMode = .video
        picker.cameraDevice = camera
        picker.videoQuality = .typeHigh
        
        picker.modalPresentationStyle = .fullScreen
        
        return picker
    }
}

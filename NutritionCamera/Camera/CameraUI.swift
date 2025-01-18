//
//  CameraUI.swift
//  NutritionCamera
//
//  Created by Ryan Klein on 12/1/24.
//  Originally taken from https://developer.apple.com/documentation/vision/locating-and-displaying-recognized-text
//


import SwiftUI

struct CameraUI: View {
    @State var camera = Camera()
    @State var didSetup = Bool()

    @Binding var path: NavigationPath

    var body: some View {
        ZStack(alignment: .bottom) {
            CameraPreview(camera: $camera)
                .task {
                    /// If the app has access to the camera, set up and display a live capture preview.
                    if await camera.checkCameraAuthorization() {
                        didSetup = camera.setup()
                    /// If the app doesn't have access, dismiss the camera and display an error.
                    } else {
                        path.append("error")
                    }
                    
                    if !didSetup {
                        print("Camera setup failed.")
                        path.append("error")
                    }
                }
                .ignoresSafeArea()

            cameraControls
            
        }
    }

    @ViewBuilder var cameraControls: some View {
        /// Show the `Capture` button if the user hasn't already captured a photo.
        if !camera.hasPhoto {
            Button {
                camera.capturePhoto()
            } label: {
                ZStack {
                    Circle()
                        .stroke(.white, lineWidth: 2)
                        .frame(width: 70)

                    Circle()
                        .fill(.white)
                        .frame(width: 60)
                }
            }
            .buttonStyle(CaptureButtonStyle())
        /// Show the `Done` button after the user captures a photo.
        } else {
            Button("Done") {
                let imageDataContainer = ImageDataContainer(imageData: camera.photoData!)
                path = NavigationPath()
                path.append(imageDataContainer)
            }
            .buttonStyle(DoneButtonStyle())
        }
    }
}

struct DoneButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(Color.white)
            .foregroundStyle(.black)
            .font(.title2)
            .clipShape(Capsule())
    }
}

struct CaptureButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct ImageDataContainer: Hashable {
    let imageData: Data
}


//
//  EachTabView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct EachTabView: View {
    @Binding var showImageStocker: Bool
    @Binding var mainCategoryIds: [MainCategoryId]
    @Binding var workSpace: [ImageFile]
    @Binding var fileUrl: URL
    @Binding var plistCategoryName: String
    @Binding var targetSubCategoryIndex: [Int]
    @State var moveToWorkSpace = false
    @State var showImagePicker2 = false
    @State var isTargeted1 = false
    @State var isTargetedIndex1 = -1
    @State var isTargeted2 = false
    @State var isTargetedIndex2 = -1
    @State var targetImageFile = ""
    @State var showImageView = false
    let sheetId = 2
    let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 2)
    let subColumns2 = Array(repeating: GridItem(.fixed(185), spacing: 5), count: 2)
        
    var body: some View {
        ScrollView {
            ForEach(mainCategoryIds.indices) { mainCategoryIndex in
                ForEach(mainCategoryIds[mainCategoryIndex].items.indices) { subCategoryIndex in
                    if mainCategoryIndex == targetSubCategoryIndex[0] && subCategoryIndex == targetSubCategoryIndex[1] {
                        VStack(spacing: 5) {
                            HStack {
                                Button {
                                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                        print("Camera is available")
                                        showImagePicker2.toggle()
                                    } else {
                                        print("Camara is not available")
                                    }
                                } label: {
                                    Image(systemName: "camera")
                                        .frame(width: 70, height: 30)
                                        .background(LinearGradient(gradient: Gradient(colors: [.indigo]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .foregroundColor(Color.white)
                                        .cornerRadius(10)
                                        .padding(.leading)
                                }
                                .sheet(isPresented: $showImagePicker2) {
                                    ImagePickerView(sheetId: sheetId, showImagePicker: $showImagePicker2, mainCategoryIds: $mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: $workSpace, fileUrl: fileUrl)
                                }
                                Spacer()
                                Button {
                                } label: {
                                    Text("To WorkSpace")
                                        .frame(width: 170, height: 30)
                                        .background(moveToWorkSpace ? .orange : subCategoryIndex % 2 == 0 ? .brown.opacity(0.8) : .indigo.opacity(0.8))
                                        .foregroundColor(Color.white)
                                    
                                        .dropDestination(for: String.self) { indexs, location in
                                            let arr: [String] = indexs.first!.components(separatedBy: ":")
                                            var indexs1: [String] = []
                                            indexs1.append(arr[0])
                                            var indexs2: [String] = []
                                            indexs2.append(arr[1])
                                            if URL(string: indexs2[0])!.lastPathComponent.first == "@" {
                                            } else {
                                                ZipManager.moveImagesFromPlistToWorkSpace(images: indexs1, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: &workSpace)
                                                if workSpace.count >= 2 {
                                                    CategoryManager.moveItemFromLastToFirst(image: ImageFileId(id: workSpace.count - 1, imageFile: ImageFile(imageFile: indexs1.first!)), workSpace: &workSpace)
                                                }
                                                ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                            }
                                            return true
                                        } isTargeted: { isTargeted in
                                            moveToWorkSpace = isTargeted
                                        }
                                }
                                Spacer()
                                Button {
                                    showImageStocker = false
                                } label: {
                                    Image(systemName: "xmark")
                                        .frame(width: 30, height: 30)
                                        .background(Color.orange)
                                        .foregroundColor(Color.white)
                                        .cornerRadius(10)
                                        .padding(.trailing)
                                }
                            }
                        }
                        VStack(spacing:5) {
                            VStack {
                                Text(plistCategoryName.replacingOccurrences(of: "_", with: " / "))
                                    .frame(maxWidth: .infinity)
                                    .background(subCategoryIndex % 2 == 0 ? LinearGradient(gradient: Gradient(colors: [.clear, .indigo.opacity(0.2), .indigo.opacity(0.2), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [.clear, .brown.opacity(0.2), .brown.opacity(0.2), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .foregroundColor(subCategoryIndex % 2 == 0 ? .indigo : .brown).bold()
                                Text("Category: " + mainCategoryIds[mainCategoryIndex].mainCategory)
                                    .frame(maxWidth: .infinity)
                                    .background(subCategoryIndex % 2 == 0 ? LinearGradient(gradient: Gradient(colors: [.clear, .indigo.opacity(0.8), .indigo.opacity(0.8), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [.clear, .brown.opacity(0.8), .brown.opacity(0.8), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .foregroundColor(.white)
                            }
                            Text(mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].subCategory)
                            if mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].countStoredImages == 0 {
                                LazyVGrid(columns: subColumns2) {
                                    ZStack{
                                        Text("Take photo\n        or\nMove here")
                                            .frame(width: 180, height: 135)
                                            .foregroundColor(.white)
                                            .background(.gray.opacity((0.3)))
                                            .cornerRadius(10)
                                            .border(.indigo, width: isTargeted1 ? 3 : .zero)
                                            .dropDestination(for: String.self) { indexs, location in
                                                let arr: [String] = indexs.first!.components(separatedBy: ":")
                                                var indexs1: [String] = []
                                                indexs1.append(arr[0])
                                                var indexs2: [String] = []
                                                indexs2.append(arr[1])
                                                if URL(string: indexs2[0])!.lastPathComponent.first == "@" {
                                                    ZipManager.moveImagesFromWorkSpaceToPlist(images: indexs1, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: &workSpace)
                                                    ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                }
                                                return true
                                            } isTargeted: { isTargeted in
                                                self.isTargeted1 = isTargeted
                                            }
                                    }
                                    Rectangle()
                                        .frame(width: 180, height: 135)
                                        .foregroundColor(.white)
                                }
                            }
                            LazyVGrid(columns: subColumns2) {
                                ForEach(CategoryManager.convertIdentifiable(imageFiles: mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images)) { imageFileId in
                                    if let uiimage = UIImage(contentsOfFile: imageFileId.imageFile.imageFile) {
                                        Image(uiImage: uiimage)
                                            .resizable()
                                            .frame(width: uiimage.size.width >= uiimage.size.height ? 180 : 135, height: uiimage.size.width >= uiimage.size.height ? 135 : 180)
                                            .cornerRadius(10)
                                            .border(.indigo, width: isTargeted1 && imageFileId.id == isTargetedIndex1 ? 3 : .zero)
                                            .onTapGesture(count: 2) {
                                                CategoryManager.moveItemFromLastToFirst(image: imageFileId, workSpace: &mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images)
                                                ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                            }
                                            .onTapGesture(count: 1) {
                                                showImageView = true
                                                self.targetImageFile = imageFileId.imageFile.imageFile
                                            }
                                            .draggable(String(imageFileId.id) + ":" + imageFileId.imageFile.imageFile) {
                                                Image(uiImage: uiimage).border(.secondary)
                                            }
                                            .dropDestination(for: String.self) { indexs, location in
                                                let arr: [String] = indexs.first!.components(separatedBy: ":")
                                                var indexs1: [String] = []
                                                indexs1.append(arr[0])
                                                var indexs2: [String] = []
                                                indexs2.append(arr[1])
                                                if URL(string: indexs2[0])!.lastPathComponent.first == "@" {
                                                    ZipManager.moveImagesFromWorkSpaceToPlist(images: indexs1, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: &workSpace)
                                                    ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                } else {
                                                    CategoryManager.reorderItems(image: imageFileId, indexs: indexs1, workSpace: &mainCategoryIds[mainCategoryIndex].items[subCategoryIndex].images)
                                                    ZipManager.savePlist(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                                }
                                                return true
                                            } isTargeted: { isTargeted in
                                                self.isTargeted1 = isTargeted
                                                self.isTargetedIndex1 = imageFileId.id
                                            }
                                            .fullScreenCover(isPresented: $showImageView) {
                                                ImageView(showImageView: $showImageView, imageFile: targetImageFile)
                                            }
                                    }
                                }
                            }
                        }
                        VStack {
                            Text("WorkSpace (drag & drop)")
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(gradient: Gradient(colors: [.clear, .gray.opacity(0.5), .gray.opacity(0.5), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .foregroundColor(.white)
                            Text("Move to top (double tap)")
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(gradient: Gradient(colors: [.clear, .gray.opacity(0.5), .gray.opacity(0.5), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .foregroundColor(.white)
                        }
                        LazyVGrid(columns: columns, spacing: 5) {
                            ForEach(CategoryManager.convertIdentifiable(imageFiles: workSpace)) { imageFileId in
                                if let uiimage = UIImage(contentsOfFile: imageFileId.imageFile.imageFile) {
                                    Image(uiImage: uiimage)
                                        .resizable()
                                        .frame(width: uiimage.size.width >= uiimage.size.height ? 180 : 135, height: uiimage.size.width >= uiimage.size.height ? 135 : 180)
                                        .cornerRadius(10)
                                        .border(.indigo, width: isTargeted2 && imageFileId.id == isTargetedIndex2 ? 3 : .zero)
                                        .onTapGesture(count: 2) {
                                            CategoryManager.moveItemFromLastToFirst(image: imageFileId, workSpace: &workSpace)
                                        }
                                        .onTapGesture(count: 1) {
                                            showImageView = true
                                            self.targetImageFile = imageFileId.imageFile.imageFile
                                        }
                                        .draggable(String(imageFileId.id) + ":" + imageFileId.imageFile.imageFile) {
                                            Image(uiImage: uiimage).border(.secondary)
                                        }
                                        .dropDestination(for: String.self) { indexs, location in
                                            let arr: [String] = indexs.first!.components(separatedBy: ":")
                                            var indexs1: [String] = []
                                            indexs1.append(arr[0])
                                            var indexs2: [String] = []
                                            indexs2.append(arr[1])
                                            if URL(string: indexs2[0])!.lastPathComponent.first == "@" {
                                                CategoryManager.reorderItems(image: imageFileId, indexs: indexs1, workSpace: &workSpace)
                                            } else {
                                                ZipManager.moveImagesFromPlistToWorkSpace(images: indexs1, mainCategoryIds: &mainCategoryIds, mainCategoryIndex: mainCategoryIndex, subCategoryIndex: subCategoryIndex, workSpace: &workSpace)
                                                if workSpace.count >= 2 {
                                                    CategoryManager.moveItemFromLastToFirst(image: ImageFileId(id: workSpace.count - 1, imageFile: ImageFile(imageFile: indexs1.first!)), workSpace: &workSpace)
                                                }
                                                ZipManager.savePlistAndZip(fileUrl: fileUrl, mainCategoryIds: mainCategoryIds)
                                            }
                                            return true
                                        } isTargeted: { isTargeted in
                                            self.isTargeted2 = isTargeted
                                            self.isTargetedIndex2 = imageFileId.id
                                        }
                                        .fullScreenCover(isPresented: $showImageView) {
                                            ImageView(showImageView: $showImageView, imageFile: targetImageFile)
                                        }

                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


/*
 struct EachTabView_Previews: PreviewProvider {
 static var previews: some View {
 TabView1()
 }
 }
 */

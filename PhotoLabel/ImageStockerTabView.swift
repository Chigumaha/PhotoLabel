//
//  ImageStockerTabView.swift
//  PhotoLabel
//
//  Created by tomworker on 2023/06/11.
//

import SwiftUI

struct ImageStockerTabView: View {
    @Binding var showImageStocker: Bool
    @Binding var mainCategoryIds: [MainCategoryId]
    @Binding var workSpace: [ImageFile]
    @Binding var fileUrl: URL
    @Binding var plistCategoryName: String
    @Binding var targetSubCategoryIndex: [Int]
    @State var selectedTag = 2
    
    var body: some View {
        TabView(selection: $targetSubCategoryIndex[1]) {
            ForEach(mainCategoryIds[targetSubCategoryIndex[0]].items.indices) {subCategoryIndex in
                EachTabView(showImageStocker: $showImageStocker, mainCategoryIds: $mainCategoryIds, workSpace: $workSpace, fileUrl: $fileUrl, plistCategoryName: $plistCategoryName, targetSubCategoryIndex: .constant([targetSubCategoryIndex[0], subCategoryIndex])).tag(subCategoryIndex)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea()
    }
}

//
//  FileImportView.swift
//  recdr
//
//  Created by Patrick on 08.12.23.
//

import SwiftUI
import AudioKit

struct FileImportView: View {
    @State private var showFileChooser = false

    var body: some View {
        Button("Import Audio File") {
            showFileChooser = true
        }
        .fileImporter(
            isPresented: $showFileChooser,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: false
        ) { result in
            switch result {
                case .success(let url):
                    // Process the selected file
                    print("Imported File URL: \(url)")
                case .failure(let error):
                    print("File import error: \(error)")
            }
        }
    }
}


#Preview {
    FileImportView()
}

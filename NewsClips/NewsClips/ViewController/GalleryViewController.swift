//
//  ViewController.swift
//  NewsClips
//
//  Created by Kumaresh on 17/04/24.
//

import UIKit


class GalleryViewController: UIViewController {
    
    let viewModel: GalleryViewModel = GalleryViewModel()
    private let imageLoadingManager = ImageLoadingManager()
    var gallerList:GalleryModel = []
    @IBOutlet weak var interNetView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingBgView: UIView!
    @IBOutlet weak var loaderView: UIActivityIndicatorView!
    var prefetchedIndices = Set<Int>()
    let totalRecords = 390
    let batchSize = 30
    var currentPage = 1
    override func viewDidLoad()  {
        super.viewDidLoad()
        loadingBgView.isHidden = true
        collectionView.isHidden = true
        self.collectionView.register(UINib(nibName: "GalleryCell", bundle: nil), forCellWithReuseIdentifier: "GalleryCell")
        self.collectionView.register(UINib(nibName: "NoInternetCell", bundle: nil), forCellWithReuseIdentifier: "NoInternetCell")
        getGalleryListFromServer()
    }
    func getGalleryListFromServer(){
        loadingBgView.isHidden = false
        Task {
            if Reachbility().isConnectedToNetwork() {
                self.fetchDataForPage(page: currentPage)
                await MainActor.run {
                    self.collectionView.isHidden = false
                    self.interNetView.isHidden = true
                    self.loadingBgView.isHidden = true
                }
            }else{
                await MainActor.run {
                    self.collectionView.isHidden = true
                    self.interNetView.isHidden = false
                    self.loadingBgView.isHidden = true
                }
            }
        }
    }
    
    @IBAction func btnRetryConnection(_ sender: Any) {
        getGalleryListFromServer()
    }
    
    func fetchDataForPage(page: Int) {
        let totalPages = Int(ceil(Double(totalRecords) / Double(batchSize)))
        guard page <= totalPages else {
            print("All records fetched")
            return
        }
        
        let offset = (page - 1) * batchSize
        
        Task {
            do {
                if(Reachbility().isConnectedToNetwork()){
                    let images = try await viewModel.getImageListFromServer(limit: 30, offset: offset)
                    gallerList.append(contentsOf: images)
                    await MainActor.run {
                        self.collectionView.reloadData()
                    }
                }
            } catch {
                print("Error fetching images: \(error)")
            }
        }
    }
    
    func loadNextPage() {
        currentPage += 1
        fetchDataForPage(page: currentPage)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

extension GalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallerList.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Check if the displayed cell is the last cell
        if indexPath.row == gallerList.count - 1{
            loadNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        let galleryThumb = gallerList[indexPath.row].thumbnail
        let imgPath = "\(galleryThumb?.domain ?? "")/\(galleryThumb?.basePath ?? "")/0/\(galleryThumb?.key ?? "")"
        
        Task {
            if let image =  await imageLoadingManager.loadImage(from: imgPath,fileKeyName: galleryThumb?.id ?? "image") {
                let croppedImage = image.centerCrop(toSize: cell.imgThumbnail.bounds.size)
                DispatchQueue.main.async {
                    cell.imgThumbnail.image = croppedImage
                    cell.lblError.isHidden = true
                }
            }else{
                DispatchQueue.main.async {
                    cell.lblError.isHidden = false
                }
            }
            
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let imageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ImageViewController") as? ImageViewController {
            Task {
                let galleryThumb = gallerList[indexPath.row].thumbnail
                do {
                    if let image = try await imageLoadingManager.loadImageFromDisk(filename: galleryThumb?.id ?? "image") {
                        imageVC.image = image
                        self.present(imageVC, animated: true)
                    }
                }catch {
                    print("image failed for load from disk: \(galleryThumb?.id ?? "")")
                }
            }
        }
        
        
    }
}

extension GalleryViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth =   collectionView.frame.size.width / 3 - 5
        return CGSize(width: cellWidth, height: cellWidth)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension GalleryViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // Prefetch images for the given indexPaths
        for indexPath in indexPaths {
            guard indexPath.row < gallerList.count else { continue }
            
            // Check if the image is already set for this index
            guard !prefetchedIndices.contains(indexPath.row) else { continue }
            
            let galleryThumb = gallerList[indexPath.row].thumbnail
            let imgPath = "\(galleryThumb?.domain ?? "")/\(galleryThumb?.basePath ?? "")/0/\(galleryThumb?.key ?? "")"
            if let url = URL(string: imgPath) {
                Task {
                    if let image = await (imageLoadingManager.loadImage(from: url.absoluteString, fileKeyName: url.lastPathComponent) as UIImage??) {
                        DispatchQueue.main.async {
                            self.prefetchedIndices.insert(indexPath.row)
                            
                            // Set image only if the cell is still visible and image is not set yet
                            if let cell = collectionView.cellForItem(at: indexPath) as? GalleryCell, cell.imgThumbnail.image != UIImage(named: "placholder_image") {
                                cell.imgThumbnail.image = image
                                cell.lblError.isHidden = true
                            }
                        }
                    } else {
                        // Prefetch failed
                        print("Prefetching image failed for URL: \(url)")
                    }
                }
            }
        }
    }
}



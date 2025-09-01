//
//  TopSearchVC.swift
//  SCIMBO
//
//  Created by Radheshyam Yadav on 26/08/25.
//  Copyright © 2025 Pickzon Inc. All rights reserved.
//

import UIKit
import Kingfisher

class TopSearchVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var srchTxt:String = ""
    private var isDataLoading = false
    private var topArray = [WallPostModel]()
    private var emptyView:EmptyList?
    private var isDataMoreAvailable = true
    private var pageNo = 1
    var delegate:SearchPostSelectedDelegate?

    //MARK: Controllers life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = PinterestLayout()
        layout.delegate = self
        collectionView.collectionViewLayout = layout
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ImageCell", bundle: nil),
                                forCellWithReuseIdentifier: "ImageCell")
        getTopPostApi()
        NotificationCenter.default.addObserver(self, selector:
                                            #selector(self.topSelectedTabIndex(notification:)),
                                           name: NSNotification.Name(rawValue: "topSelectedTabIndex"), object: nil)
        }
        
        
        
        @objc func topSelectedTabIndex(notification: Notification) {
            
            
            if  let response = notification.userInfo as? Dictionary<String, Any> {
                
                if let newToSearch = response["searchText"] as? String{
                   
                    if srchTxt == newToSearch{
                        
                    }else{
                        srchTxt = newToSearch
                        self.pageNo = 1
                        self.getTopPostApi()
                    }
                }
            }
        }
        //MARK: Api methods
    func getTopPostApi(){
        
        if pageNo == 1{
            self.topArray.removeAll()
            self.collectionView.reloadData()
        }
        
       // let param:NSDictionary  = ["keyword":srchTxt,"pageNumber":pageNo]
        
        let strUrl = Constant.sharedinstance.feed_top_post + "?pageNumber=\(pageNo)&keyword=\(srchTxt)"
       
        URLhandler.sharedinstance.makeCall(url:strUrl, param: nil, methodType: .get, completionHandler: {(responseObject, error) ->  () in
  
            if(error != nil)
            {
                // Themes.sharedInstance.RemoveactivityView(View: self.view)
                // self.view.makeToast(message: Constant.sharedinstance.ErrorMessage , duration: 3, position: HRToastActivityPositionDefault)
                print(error ?? "defaultValue")
                self.isDataLoading = false
                
            }else{
                let result = responseObject! as NSDictionary
                let status = result["status"] as? Int16 ?? 0
                //let message = result["message"] as? String ?? ""
                
                if status == 1{
                    
                    let data = result.value(forKey: "payload") as? NSArray ?? []
                    for d in data
                    {
                        self.topArray.append(WallPostModel(dict: d as? NSDictionary ?? [:]))
                    }
                    self.emptyView?.isHidden = (self.topArray.count > 0) ? true : false
                    self.isDataMoreAvailable = (data.count > 5) ? true : false
                    self.pageNo = self.pageNo + 1
                    DispatchQueue.main.async {
                        self.collectionView.reloadWithoutAnimation()
                        self.collectionView.collectionViewLayout.invalidateLayout()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.isDataLoading = false
                    }
                }else{
                    self.isDataLoading = false
                }
            }
        })
    }
}


extension TopSearchVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let objWallPost = topArray[indexPath.item]
       
        if objWallPost.sharedWallData == nil {
            
            if let urlStr = objWallPost.thumbUrlArray.first {
                
                if checkMediaTypes(strUrl:urlStr) == 3{
                    cell.imgVwIcon.image = UIImage(named: "clipSelColor")
                }else{
                    cell.imgVwIcon.image = UIImage(named: "rectanglePortraitAngled")
                }

                
                cell.imageView.kf.setImage(with: URL(string: urlStr.trimmingLeadingAndTrailingSpaces()), placeholder: PZImages.dummyCover, options: [.processor(DownsamplingImageProcessor(size: cell.imageView.frame.size)),.scaleFactor(UIScreen.main.scale),.cacheOriginalImage], progressBlock: nil) {response in
                    
                    /*switch response {
                       case .success(let value):
                        if objWallPost.cachedSize == nil { // store size first time
                            self.topArray[indexPath.item].cachedSize = value.image.size
                               DispatchQueue.main.async {
                                   collectionView.collectionViewLayout.invalidateLayout()
                               }
                           }
                       case .failure:
                           break
                       }*/
                }
                
            }
        }else{
            if let urlStr = objWallPost.sharedWallData?.thumbUrlArray.first {
                
                if checkMediaTypes(strUrl:urlStr) == 3{
                    cell.imgVwIcon.image = UIImage(named: "clipSelColor")
                }else{
                    cell.imgVwIcon.image = UIImage(named: "rectanglePortraitAngled")
                }
                
                cell.imageView.kf.setImage(with: URL(string: urlStr.trimmingLeadingAndTrailingSpaces()), placeholder:PZImages.dummyCover, options: [.processor(DownsamplingImageProcessor(size: cell.imageView.frame.size)),.scaleFactor(UIScreen.main.scale),.cacheOriginalImage], progressBlock: nil) {response in
                    
                  /*  switch response {
                    case .success(let value):
                        if objWallPost.cachedSize == nil { // store size first time
                            self.topArray[indexPath.item].cachedSize = value.image.size
                            DispatchQueue.main.async {
                                collectionView.collectionViewLayout.invalidateLayout()
                            }
                        }
                    case .failure:
                        break
                    }
                    */
                    
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if self.isDataLoading == false && indexPath.item >= (topArray.count - 2) {
            isDataLoading = true
            self.getTopPostApi()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //delegate?.searchItemSelected(selObj: topArray[indexPath.item], type: .top)

        let vc = StoryBoard.main.instantiateViewController(withIdentifier: "WallPostViewVC") as! WallPostViewVC
        vc.selRowIndex = indexPath.item
        vc.arrwallPost = topArray
        vc.controllerType = .isFromRandomMedia
        vc.hashTag = srchTxt
        vc.pageNo = pageNo
        vc.title = "Posts"
        (AppDelegate.sharedInstance.navigationController?.topViewController)?.pushView(vc, animated: true)

    }
}


extension TopSearchVC: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        heightForPhotoAt indexPath: IndexPath,
                        with width: CGFloat) -> CGFloat {
        
        return CGFloat(150 + (indexPath.item % 3) * 50)

        
        /*let objWallPost = topArray[indexPath.item]
        
        if let size = objWallPost.cachedSize {
            // Already cached → calculate height
            let aspectRatio = size.height / size.width
            return width * aspectRatio
        }
        
        // No size yet → return a default height
        return width * 1.3*/
    }
}





protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView,
                        heightForPhotoAt indexPath: IndexPath,
                        with width: CGFloat) -> CGFloat
}

class PinterestLayout: UICollectionViewLayout {
    weak var delegate: PinterestLayoutDelegate?
    
    private let numberOfColumns = 2
    private let cellPadding: CGFloat = 4
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        guard cache.isEmpty, let collectionView = collectionView else { return }
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let photoWidth = columnWidth - cellPadding * 2
            let photoHeight = delegate?.collectionView(collectionView,
                                                       heightForPhotoAt: indexPath,
                                                       with: photoWidth) ?? 180
            let height = cellPadding * 2 + photoHeight
            let frame = CGRect(x: xOffset[column],
                               y: yOffset[column],
                               width: columnWidth,
                               height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            column = column < (numberOfColumns - 1) ? column + 1 : 0
        }
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        cache.removeAll()
        contentHeight = 0
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}

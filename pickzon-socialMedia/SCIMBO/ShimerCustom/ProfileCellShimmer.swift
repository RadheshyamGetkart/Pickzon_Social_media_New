import UIKit
import ShimmerView

class ProfileCellShimmer: UIView, ShimmerReplicatorViewCell {
    @IBOutlet weak var thumbnailBannerView: ShimmerView!
    @IBOutlet weak var thumbnailView: ShimmerView!
    @IBOutlet weak var firstLineView: ShimmerView!
    @IBOutlet weak var secondLineView: ShimmerView!
    @IBOutlet weak var thirdLineView: ShimmerView!
    @IBOutlet weak var thirdLinePostCountView: ShimmerView!
    @IBOutlet weak var thirdLineFollowingCountView: ShimmerView!
    @IBOutlet weak var thirdLineFollowCountView: ShimmerView!
    @IBOutlet weak var thirdLineTabView: ShimmerView!
    @IBOutlet weak var itemView1: ShimmerView!
    @IBOutlet weak var itemView2: ShimmerView!
    @IBOutlet weak var itemView3: ShimmerView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        thumbnailView.layer.cornerRadius = thumbnailView.frame.size.height/2.0
        thumbnailView.clipsToBounds = true
        thumbnailView.layer.borderWidth = 5.0
        thumbnailView.layer.borderColor = UIColor.white.cgColor
    }
    
    func startAnimating() {
        thumbnailView.startAnimating()
        firstLineView.startAnimating()
        secondLineView.startAnimating()
        thirdLineView.startAnimating()
        thumbnailBannerView.startAnimating()
        thirdLinePostCountView.startAnimating()
        thirdLineFollowingCountView.startAnimating()
        thirdLineFollowCountView.startAnimating()
        thirdLineTabView.startAnimating()
        
        itemView1.startAnimating()
        itemView2.startAnimating()
        itemView3.startAnimating()

    }
    
    func stopAnimating() {
        thumbnailView.stopAnimating()
        firstLineView.stopAnimating()
        secondLineView.stopAnimating()
        thirdLineView.stopAnimating()
        thumbnailBannerView.stopAnimating()
        thirdLinePostCountView.stopAnimating()
        thirdLineFollowingCountView.stopAnimating()
        thirdLineFollowCountView.stopAnimating()
        thirdLineTabView.stopAnimating()
        itemView1.stopAnimating()
        itemView2.stopAnimating()
        itemView3.stopAnimating()
    }
}

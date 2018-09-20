//
//  OFAAppImagesViewController.swift
//  CleverBabyTestApp
//
//  Created by Administrator on 5/31/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFAAppImagesViewController: UIPageViewController,UIPageViewControllerDataSource {

    var arrPagePhoto: NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.perform(#selector(self.getData), with: nil, afterDelay: 3.0)
        
    }
    
    func getData(){
        arrPagePhoto = arrayPreviewImages
        
        self.dataSource = self
        
        self.setViewControllers([getViewControllerAtIndex(0)] as [UIViewController], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
    }
    // MARK:- UIPageViewControllerDataSource Methods
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        let pageContent: OFAPageViewImagesViewController = viewController as! OFAPageViewImagesViewController
        
        var index = pageContent.pageIndex
        
        if ((index == 0) || (index == NSNotFound))
        {
            return nil
        }
        
        index -= 1;
        return getViewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        let pageContent: OFAPageViewImagesViewController = viewController as! OFAPageViewImagesViewController
        
        var index = pageContent.pageIndex
        
        if (index == NSNotFound)
        {
            return nil;
        }
        
        index += 1;
        if (index == arrPagePhoto.count)
        {
            return nil;
        }
        return getViewControllerAtIndex(index)
    }
    
    // MARK:- Other Methods
    func getViewControllerAtIndex(_ index: NSInteger) -> OFAPageViewImagesViewController
    {
        // Create a new view controller and pass suitable data.
        let pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewImage") as! OFAPageViewImagesViewController
        
        pageContentViewController.strPhotoName = "\(arrPagePhoto[index])"
        pageContentViewController.pageIndex = index
        
        return pageContentViewController
    }
}

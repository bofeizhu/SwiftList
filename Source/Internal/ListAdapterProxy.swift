//
//  ListAdapterProxy.swift
//  SwiftList
//
//  Created by Bofei Zhu on 7/30/18.
//  Copyright © 2018 Bofei Zhu. All rights reserved.
//

// MARK: - UIScrollViewDelegate
/// Pass on methods to a UIScrollViewDelegate and a UICollectionViewDelegate
extension ListAdapter: UIScrollViewDelegate {
    // MARK: Responding to Scrolling and Dragging
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let scrollViewDelegateMethod = scrollViewDelegate?.scrollViewDidScroll(_:) {
            scrollViewDelegateMethod(scrollView)
        } else if let collectionViewDelegateMethod =
            collectionViewDelegate?.scrollViewDidScroll(_:) {
            collectionViewDelegateMethod(scrollView)
        }
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let scrollViewDelegateMethod = scrollViewDelegate?.scrollViewWillBeginDragging(_:) {
            scrollViewDelegateMethod(scrollView)
        } else if let collectionViewDelegateMethod =
            collectionViewDelegate?.scrollViewWillBeginDragging(_:) {
            collectionViewDelegateMethod(scrollView)
        }
    }

    public func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let scrollViewDelegateMethod =
            scrollViewDelegate?.scrollViewWillEndDragging(_:withVelocity:targetContentOffset:) {
            scrollViewDelegateMethod(scrollView, velocity, targetContentOffset)
        } else if let collectionViewDelegateMethod =
            collectionViewDelegate?.scrollViewWillEndDragging(_:withVelocity:targetContentOffset:) {
            collectionViewDelegateMethod(scrollView, velocity, targetContentOffset)
        }
    }

    public func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool) {
        if let scrollViewDelegateMethod =
            scrollViewDelegate?.scrollViewDidEndDragging(_:willDecelerate:) {
            scrollViewDelegateMethod(scrollView, decelerate)
        } else if let collectionViewDelegateMethod =
            collectionViewDelegate?.scrollViewDidEndDragging(_:willDecelerate:) {
            collectionViewDelegateMethod(scrollView, decelerate)
        }
    }

    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if let scrollViewDelegateMethod =
            scrollViewDelegate?.scrollViewShouldScrollToTop(_:) {
            return scrollViewDelegateMethod(scrollView)
        } else if let collectionViewDelegateMethod =
            collectionViewDelegate?.scrollViewShouldScrollToTop(_:) {
            return collectionViewDelegateMethod(scrollView)
        }
        // If the delegate doesn’t implement this method, true is assumed.
        return true
    }

    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        if let scrollViewDelegateMethod = scrollViewDelegate?.scrollViewDidScrollToTop(_:) {
            scrollViewDelegateMethod(scrollView)
        } else if let collectionViewDelegateMethod =
            collectionViewDelegate?.scrollViewDidScrollToTop(_:) {
            collectionViewDelegateMethod(scrollView)
        }
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if let scrollViewDelegateMethod =
            scrollViewDelegate?.scrollViewWillBeginDecelerating(_:) {
            scrollViewDelegateMethod(scrollView)
        } else if let collectionViewDelegateMethod =
            collectionViewDelegate?.scrollViewWillBeginDecelerating(_:) {
            collectionViewDelegateMethod(scrollView)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let scrollViewDelegateMethod =
            scrollViewDelegate?.scrollViewDidEndDecelerating(_:) {
            scrollViewDelegateMethod(scrollView)
        } else if let collectionViewDelegateMethod =
            collectionViewDelegate?.scrollViewDidEndDecelerating(_:) {
            collectionViewDelegateMethod(scrollView)
        }
    }

    // MARK: Managing Zooming
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if let scrollViewDelegateMethod = scrollViewDelegate?.viewForZooming(in:) {
            return scrollViewDelegateMethod(scrollView)
        } else if let collectionViewDelegateMethod = collectionViewDelegate?.viewForZooming(in:) {
            return collectionViewDelegateMethod(scrollView)
        }
        return nil
    }

    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        if let scrollViewDelegateMethod =
            scrollViewDelegate?.scrollViewWillBeginZooming(_:with:) {
            scrollViewDelegateMethod(scrollView, view)
        } else if let collectionViewDelegateMethod =
            collectionViewDelegate?.scrollViewWillBeginZooming(_:with:) {
            collectionViewDelegateMethod(scrollView, view)
        }
    }

    public func scrollViewDidEndZooming(
        _ scrollView: UIScrollView,
        with view: UIView?,
        atScale scale: CGFloat) {
        if let scrollViewDelegateMethod =
            scrollViewDelegate?.scrollViewDidEndZooming(_:with:atScale:) {
            scrollViewDelegateMethod(scrollView, view, scale)
        } else if let collectionViewDelegateMethod =
            collectionViewDelegate?.scrollViewDidEndZooming(_:with:atScale:) {
            collectionViewDelegateMethod(scrollView, view, scale)
        }
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let scrollViewDelegateMethod =
            scrollViewDelegate?.scrollViewDidZoom(_:) {
            scrollViewDelegateMethod(scrollView)
        } else if let collectionViewDelegateMethod =
            collectionViewDelegate?.scrollViewDidZoom(_:) {
            collectionViewDelegateMethod(scrollView)
        }
    }

    // MARK: Responding to Scrolling Animations
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let scrollViewDelegateMethod =
            scrollViewDelegate?.scrollViewDidEndScrollingAnimation(_:) {
            scrollViewDelegateMethod(scrollView)
        } else if let collectionViewDelegateMethod =
            collectionViewDelegate?.scrollViewDidEndScrollingAnimation(_:) {
            collectionViewDelegateMethod(scrollView)
        }
    }

    // MARK: Responding to Inset Changes
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        guard #available(iOS 11.0, *) else { return }
        if let scrollViewDelegateMethod =
            scrollViewDelegate?.scrollViewDidChangeAdjustedContentInset(_:) {
            scrollViewDelegateMethod(scrollView)
        } else if let collectionViewDelegateMethod =
            collectionViewDelegate?.scrollViewDidChangeAdjustedContentInset(_:) {
            collectionViewDelegateMethod(scrollView)
        }
    }
}

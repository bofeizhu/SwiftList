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
    @available(iOS 11.0, *)
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        if let scrollViewDelegateMethod =
            scrollViewDelegate?.scrollViewDidChangeAdjustedContentInset(_:) {
            scrollViewDelegateMethod(scrollView)
        } else if let collectionViewDelegateMethod =
            collectionViewDelegate?.scrollViewDidChangeAdjustedContentInset(_:) {
            collectionViewDelegateMethod(scrollView)
        }
    }
}

// MARK: - UICollectionViewDelegate
/// Pass on methods to a UICollectionViewDelegate
extension ListAdapter {
    // MARK: Managing the Selected Cells
    public func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        if let method = collectionViewDelegate?.collectionView(_:shouldSelectItemAt:) {
            return method(collectionView, indexPath)
        }
        // If you do not implement this method, the default return value is true.
        return true
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        shouldDeselectItemAt indexPath: IndexPath
    ) -> Bool {
        if let method = collectionViewDelegate?.collectionView(_:shouldDeselectItemAt:) {
            return method(collectionView, indexPath)
        }
        // If you do not implement this method, the default return value is true.
        return true
    }

    // MARK: Managing Cell Highlighting
    public func collectionView(
        _ collectionView: UICollectionView,
        shouldHighlightItemAt indexPath: IndexPath
    ) -> Bool {
        if let method = collectionViewDelegate?.collectionView(_:shouldHighlightItemAt:) {
            return method(collectionView, indexPath)
        }
        // If you do not implement this method, the default return value is true.
        return true
    }

    // MARK: Handling Layout Changes
    public func collectionView(
        _ collectionView: UICollectionView,
        transitionLayoutForOldLayout fromLayout: UICollectionViewLayout,
        newLayout toLayout: UICollectionViewLayout
    ) -> UICollectionViewTransitionLayout {
        if let method =
            collectionViewDelegate?.collectionView(_:transitionLayoutForOldLayout:newLayout:) {
            return method(collectionView, fromLayout, toLayout)
        }
        // If your delegate does not implement this method, the collection view creates a standard
        // `UICollectionViewTransitionLayout` object and uses that object to manage the transition.
        return UICollectionViewTransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint
    ) -> CGPoint {
        if let method =
            collectionViewDelegate?.collectionView(_:targetContentOffsetForProposedContentOffset:) {
            return method(collectionView, proposedContentOffset)
        }
        return proposedContentOffset
    }

    // Managing Actions for Cells
    public func collectionView(
        _ collectionView: UICollectionView,
        shouldShowMenuForItemAt indexPath: IndexPath
    ) -> Bool {
        if let method = collectionViewDelegate?.collectionView(_:shouldShowMenuForItemAt:) {
            return method(collectionView, indexPath)
        }
        // If you do not implement this method, the default return value is true.
        return true
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        canPerformAction action: Selector,
        forItemAt indexPath: IndexPath,
        withSender sender: Any?
    ) -> Bool {
        if let method =
            collectionViewDelegate?.collectionView(_:canPerformAction:forItemAt:withSender:) {
            return method(collectionView, action, indexPath, sender)
        }
        // If you do not implement this method, the default return value is true.
        return true
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        performAction action: Selector,
        forItemAt indexPath: IndexPath,
        withSender sender: Any?) {
        if let method =
            collectionViewDelegate?.collectionView(_:performAction:forItemAt:withSender:) {
            method(collectionView, action, indexPath, sender)
        }
    }

    // Managing Focus in a Collection View
    public func collectionView(
        _ collectionView: UICollectionView,
        canFocusItemAt indexPath: IndexPath
    ) -> Bool {
        if let method = collectionViewDelegate?.collectionView(_:canFocusItemAt:) {
            return method(collectionView, indexPath)
        }
        // If you do not implement this method, the default return value is true.
        return true
    }

    public func indexPathForPreferredFocusedView(
        in collectionView: UICollectionView
    ) -> IndexPath? {
        if let method = collectionViewDelegate?.indexPathForPreferredFocusedView(in:) {
            return method(collectionView)
        }
        return nil
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext
    ) -> Bool {
        if let method = collectionViewDelegate?.collectionView(_:shouldUpdateFocusIn:) {
            return method(collectionView, context)
        }
        // If you do not implement this method, the default return value is true.
        return true
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        didUpdateFocusIn context: UICollectionViewFocusUpdateContext,
        with coordinator: UIFocusAnimationCoordinator) {
        if let method = collectionViewDelegate?.collectionView(_:didUpdateFocusIn:with:) {
            method(collectionView, context, coordinator)
        }
    }

    @available(iOS 11.0, *)
    public func collectionView(
        _ collectionView: UICollectionView,
        shouldSpringLoadItemAt indexPath: IndexPath,
        with context: UISpringLoadedInteractionContext
    ) -> Bool {
        if let method = collectionViewDelegate?.collectionView(_:shouldSpringLoadItemAt:with:) {
            return method(collectionView, indexPath, context)
        }
        // If you do not implement this method, the default return value is true.
        return true
    }
}

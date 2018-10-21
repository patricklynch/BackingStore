# ![BackingStore Logo](logo-backing-store.png)

A set of components that model some data which is to be displayed in a `UICollectionView` or `UITableView`.  When that data changes, these components automatically calculate the changes necessary to perform a smooth, performant batch update.  This includes inserted sections, inserted index paths, deleted sections, deleted indexpaths and moved indx paths.  What this means is that you never have to call reloadData() ever again, and every change you make to the contents of a table or collection view will be perfectly animated. Pretty cool, ain't it?

[![CI Status](https://img.shields.io/travis/patricklynch/BackingStore.svg?style=flat)](https://travis-ci.org/patricklynch/BackingStore)
[![Version](https://img.shields.io/cocoapods/v/BackingStore.svg?style=flat)](https://cocoapods.org/pods/BackingStore)
[![License](https://img.shields.io/cocoapods/l/BackingStore.svg?style=flat)](https://cocoapods.org/pods/BackingStore)
[![Platform](https://img.shields.io/cocoapods/p/BackingStore.svg?style=flat)](https://cocoapods.org/pods/BackingStore)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

BackingStore is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'BackingStore'
```

## Benefits
Using `BackingStore` provides a huge boost for performance, for the user experience and for the developer experience, too.  Since table and collection view contents are not being needlessly reloaded by otherwise unregulated calls to `redloadData()`, the scrolling and rendering performance is improved.  The batch update animations employed also allow users to understand their own interaction with the data being displayed, as well as transitions between states such as those involved in loading, pagination and showing errors.

Without `BackingStore`, developers who wish for table view or collection view updates to be animated and performant would be required to manually calculate and queue batch updates, and most importantly, to ensure that batch updates do not overlap each other.  Not only is this code hard to main, it's often the cause of pesky crashes that are hard to debug.  Ever seen one of these?

> Invalid update: invalid number of items in section 0. The number of items contained in an existing section after the update (1) must be equal to the number of items contained in that section before the update (1), plus or minus the number of items inserted or deleted from that section (1 inserted, 0 deleted) and plus or minus the number of items moved into or out of that section (0 moved in, 0 moved out).

When `BackingStore` is used *properly* this error is impossible.  If you do still see it, it usually means that some data type you are storing in a `BackingStore` instance does not conform to `Hashable` or that its `Hashable` conformance provides a `hashValue` that is not unique enough.  More on that later.

## Typical Setup Steps 

### Create a dedicated "data source" class
This will provide the implementation of `UICollectionViewDataSource` or `UITableViewDataSource`.  This class will also contain the `BackingStore` instance.  This puts together the two important logical concepts of providing views to display—`UICollectionViewDataSource` or `UITableViewDataSource`—and a representation of the data that is being displayed with those views—`BackingStore`. This is also better coding practice than adding all "data source" code to a subclass of `UIViewController` which typically contains (too many) other responsibilities.

```swift
class MyDataSource: NSObject, UITableViewDataSource {
 
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	fatalError("Nothing to do just yet.")
    }
}
```

### Create a `SectionType`
`BackingStore` is a generic class that uses a generic type `SectionType` to uniquely identify each section to be displayed in a table or collection view.  You must therefore define a type for this purpose which must conform to `Hashable` and `Comparable` in order to satisfy the contraints on the generic `SectionType`.  An enum with a raw type of `Int` will satisfy this automatically and is the typical use case. 

```swift
enum MySectionType: Int {
    case title, description, actions
}
``` 

However, if you will only be displaying one section, it is not required to create a type to be used as `BackingStore`s generic `SectionType`.  There exists a type which already serves this purpose called `SingleSectionType`.  `BackingStore` comes with an extended API that simplifies many of its primary functions for implementations that use `SingleSectionType` in order to be more convenient and create cleaner call sites for these simple cases.

### Create a `BackingStore` instance
Now that you have a `SectionType` created (or if you'll be using `SingleSectionType`), you can create a `BackingStore` instance on your data source class.

For multiple sections:
```swift
let backingStore = BackingStore<MySectionType>()
```

For single sections sections:
```swift
let backingStore = BackingStore<MySectionType>()
```

### Confirm Data Source to `BackingStoreDataSource`
`BackingStoreDataSource` is a protocol that defines and object that can fit into this group of interrated components (which includes `BackingStore`) in order to allow batch updates to be executed once they are calculated by `BackingStore`.  It's requirements are simple, but essential to the functioning of this interrated logic.  Our `UITableViewDataSource` implementation defined above will also serve as the `BackingStoreDataSource` implementation.

```Swift
class MyDataSource: NSObject, UITableViewDataSource, BackingStoreDataSource {

    // MARK: - BackingStoreDataSource
    
    var backingStoreView: BackingStoreView?

    func decorate(cell: UIView, at indexPath: IndexPath, animated: Bool) {
        if let cell = cell as? MyCell {
            cell.title = myData.localizedTitle
            cell.backgroundColor = .white
            cell.addDropShadow()
        }
    }

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myData.count
    }
}
```
As shown above, one of the main ideas of `SelfUdpatingDataSource` is the separation between *dequeing* and *decoration*.  In the normal table or collection view setup, these steps are usually done all at once as part of the data source's normal lifecycle:

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! MyCell
    cell.title = myData.localizedTitle
    cell.backgroundColor = myData.isEnabled ? .white : .gray
    return cell
}
```

In this example, the *dequeing* happens when the code decides what kind of cell to create for the provided `indexPath`.  It uses the `dequeueReusableCell(withIdentifier:for:)` method to create this cell, and at the end of the function it is returned to the caller in order to be displayed in the table view.  The *decoration* happens in the lines between where properties of the cell are set according to the data that the cell will represent.  The blank, recently-dequeued cell is "decorated" to become the right cell for the data at  `indexPath`.

Separating these two phases is important so that they can be done independently.  The benefit of this is that cells can be re-decorated while they are visible and not be dequeued again.  If something in the data model changes that requires the cell to visually update, it's not necessary to dequeu a new cell and completely reconfigure it, but rather just a simple (and more performant) decoration.

### Connect the Datasource and its Delegate

In vanilla uses of `UICollectionView` and `UITableView` there is one important connection that must be made between the collection view and the data source: Setting the backingStoreView.  When using `BackingStore` there are two connections that have to be made: (1) Set your data source as the `dataSource` of the table view, and (2) set the table view as the backingStoreView of your data source.
```
dataSource.backingStoreView = collectionView
collectionView.dataSource = dataSource
```

`BackingStoreView` exists only so that `UICollectionView` and `UITableView` can be extended with methods that can queue batch updates.  The structure of these updates and the input to the API of `BackingStoreView` matches the output of `BackingStore`.  In our setup, the `BackingStoreDataSource` that we've created contains a `BackingStoreView` instance as well as a `BackingStore` instance and will   oversee the connetion between these subcomponents.

6) Call `dataSource.backingStore.setInitial(items:, dataSource:)` function with the `dataSource` itself and items that you wish to populate your screen with.


## Author

patricklynch, pdlynch@gmail.com

## License

BackingStore is available under the MIT license. See the LICENSE file for more info.

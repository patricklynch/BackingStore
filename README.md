# ![BackingStore Logo](logo-backing-store.png)

[![CI Status](https://img.shields.io/travis/patricklynch/BackingStore.svg?style=flat)](https://travis-ci.org/patricklynch/BackingStore)
[![Version](https://img.shields.io/cocoapods/v/BackingStore.svg?style=flat)](https://cocoapods.org/pods/BackingStore)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)]
[![License](https://img.shields.io/cocoapods/l/BackingStore.svg?style=flat)](https://cocoapods.org/pods/BackingStore)
[![Platform](https://img.shields.io/cocoapods/p/BackingStore.svg?style=flat)](https://cocoapods.org/pods/BackingStore)
[![Language](https://img.shields.io/badge/swift-4.2-orange.svg)](https://developer.apple.com/swift)

`BackingStore` is a framework that automatically handles perfect batch updates in table views and collection views.  This is accomplished by providing a method of storing a section-based data model set that is to be displayed in a `UICollectionView` or `UITableView`.  When that data is updated, it automatically calculates a diff between old and new in the form of inserted sections, inserted index paths, deleted sections, deleted indexpaths and moved index paths.  It then automatically applies this diff to a `UITableView` or `UICollectionView` instance to perform a smooth, performant batch update.  What this means is that you never have to call `reloadData()` ever again, and every change you make to the contents of a table or collection view will be perfectly animated. Pretty cool, ain't it?

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.  The example project demonstrates how to build a basic table view using a `BackingStore` instance and its associated components.  It loads data asynchronously from [JSONPlaceholder](https://jsonplaceholder.typicode.com/)—a fake online REST API for testing and prototyping.  It then provides some actions that you can take to change the contents of the table view.  These changes then trigger to appropriate batch updates and the contents of the able view changes with nice animation.  The code snippets used throughout this README.md come from the sample project.

## Installation

To install using CocoaPods, add the following to your project Podfile:
```ruby
pod 'BackingStore'
```
To install using Carthage, add the following to your project Cartfile:
```ruby
github "patricklynch/BackingStore"
```

## Benefits
Using `BackingStore` provides a huge boost for performance, the user experience and the developer experience, too.  Scrolling and rendering performance is improved since table view and collection view contents are not being needlessly reloaded by otherwise unregulated calls to `redloadData()`.  The user experience is improved because the batch update animations employed by `BackingStore` allow users to understand their own interaction with the data being displayed.  This is great for apps that require transitions between states such as those involved in loading, pagination and showing errors.  And ithout `BackingStore` or something like it, developers who wish for table view or collection view updates to be animated and performant would be required to manually calculate and queue batch updates.  When doing so, it's imperative (and difficult) to ensure that batch updates do not overlap each other.  Not only is this code hard to write and maintain, it's often the cause of pesky crashes that are hard to debug.  Perhaps you'ave had to deal with this error before:

> Invalid update: invalid number of items in section 0. The number of items contained in an existing section after the update (1) must be equal to the number of items contained in that section before the update (1), plus or minus the number of items inserted or deleted from that section (1 inserted, 0 deleted) and plus or minus the number of items moved into or out of that section (0 moved in, 0 moved out).

When `BackingStore` is used properly, this error is impossible.  If you do still see it, it usually means that some data type you are storing in a `BackingStore` instance does not conform to `Hashable` or that its `Hashable` conformance provides a `hashValue` that is not unique enough.  More on that later.

## Typical Setup Steps 

### Create a Data Source
Just like usual, this will provide the implementation of `UICollectionViewDataSource` or `UITableViewDataSource`.  In this example, we're going to display _todos_ in a table view that are loaded from this url:https://jsonplaceholder.typicode.com/todos.

```swift
class TodoDataSource: NSObject, UITableViewDataSource {

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
`BackingStore` is a generic class that uses a type `SectionType` to uniquely identify each section to be displayed in a table or collection view.  You must therefore define a type for this purpose which must conform to `Hashable` and `Comparable` in order to satisfy the contraints on the generic `SectionType`.  In this example, we'll have two sections for our _toods_ that are separated by completed and not completed.

```swift
enum SectionType: Int {
    case notCompleted, completed

    static func < (lhs: SectionType, rhs: SectionType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
``` 
If the number of sections is dynamic—i.e. not fixed at compile time—use an enum with an associated value to provide the conformance to `Comparable`.  This allows many sections identified by the case `group` plus the `index` associated value.  For example, if there are many of some kind of "group" what you wish to display, you could create a section type like so:

```swift
enum MySectionType: Int {
	case group(index: Int)
	
	static func < (lhs: SectionType2, rhs: SectionType2) -> Bool {
		switch (lhs, rhs) {
		case (.group(let lhsIndex), .group(let rhsIndex)):
			return lhsIndex < rhsIndex
		}
	}
}
```

However, if you will only be displaying one single section, it is not even required to create a type to be used as `BackingStore`s generic `SectionType`.  There exists a type which already serves this purpose called `SingleSectionType`.  `BackingStore` comes with an extended API that simplifies many of its primary functions for implementations that use `SingleSectionType` in order to be more convenient.  Use of a multi-section `SectionType` as well as `SingleSectionType` are demonstrated below.

### Create a `BackingStore` instance
Now that you have a `SectionType` created (or if you'll be using `SingleSectionType`), we can create a `BackingStore` instance as a stored property.  You can put this on your view controller, your data source, or whever you like.  As we'll see shortly, the only important thing is that each component has the right references to other components.  Otherwise, you may customize the sturcture to the needs of your application.

For multiple sections:
```swift
let backingStore = BackingStore<MySectionType>()
```

For single sections sections:
```swift
let backingStore = BackingStore<SingleSectionType>()
```

### Create a `BackingStoreDecorator`
`BackingStoreDecorator` is a protocol that defines an objet which decorates the cells in a table view or collection view.  It's part of a key design of this framework which is the idea is the decoupling between _dequeuing_ and _decorating_.  In a traditional implementaiton fo `UITableViewDataSource`, these two tasks are done at the same time in the `tableView(_:cellForForAt:)` function.

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // Dequeue
    let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! MyCell

    // Decorate
    let myData = myDataArray[indexPath.row]
    cell.title = myData.localizedTitle
    cell.backgroundColor = .white
    cell.addDropShadow()

    return cell
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	return myDataArray.count
}
```

Compare that with the implenention below when the data source also conforms to `BackingStoreDataSource`, which requires an implementation for the `decorate(cell:at:)` function:
```swift
class MyDataSource: NSObject, UITableViewDataSource, BackingStoreDecorator {

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue
        if backingStore.item(at: indexPath) is DescriptionData {
            cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)

        } else if backingStore.item(at: indexPath) is Action {
            cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath)
        } else {
            fatalError("Unsupported data type")
        }
        
        // Ask decorate to decorate newly-dequeued cell
        decorate(cell: cell, at: indexPath)
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return backingStore.sectionCount
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return backingStore.section(at: section)?.itemCount ?? 0
    }

    // MARK: - BackingStoreDecorator

    func decorate(cell: UIView, at indexPath: IndexPath, animated: Bool) {
        if let cell = cell as? DescriptionCell,
            let data = backingStore.item(at: indexPath) as? DescriptionData {

                // Decorate
                cell.title = data.localizedText
                cell.backgroundColor = .white
                cell.addDropShadow()

            } else if let cell = cell as? ActionCell,
                let action = backingStore.item(at: indexPath) as? Action {

                // Decorate
                cell.title = action.localizedText
                cell.isEnabled = action.isEnabled
        }
    }
}
```

In this example, the *dequeing* still happens in `tableView:cellForRow:atIndexPath:` where the code only decides what kind of cell to create and then passes it to the decorator.  The actual *decorating* happens in the decoator's implementation of `decorate(cell:at:)` in which of each cell are set according to the data that the cell will represent.  Separating these two phases is important so that they can be done independently.  The benefit of this is that cells can be re-decorated while they are visible and not be dequeued again as when reloaded with `reloadData()`. 

### Set References Between Components

In usual uses of `UICollectionView` and `UITableView` the `dataSource` property must be set with the intended `UITableViewDataSource` or `UICollectionViewDataSource` objects.  When using `BackingStore` there are two connections that have to be made: (1) Set your data source as the `dataSource` of the table view, and (2) set the table view as the `backingStoreView` of your data source.

```swift
backingStore.view = tableView
backingStore.decorator = dataSource
tableView.dataSource = dataSource
```

`BackingStoreView` exists only so that `UICollectionView` and `UITableView` can be extended with methods that can queue batch updates.  The structure of these updates and the input to the API of `BackingStoreView` matches the output of `BackingStore`.  In our setup, the `BackingStoreDataSource` that we've created contains a `BackingStoreView` instance as well as a `BackingStore` instance and will oversee the connetion between these subcomponents.

### Update the Visible Items
`BackingStore` will not queue any batch updates until it is updated with the data that should be displayed.  This is done through an "update" funciton where you can provide all at once everything that should be displayed:

```swift
class MyDataSource: NSObject, UITableViewDataSource, BackingStoreDataSource {

	let dataService = MyDataService()

	func loadData() {
		dataService.loadData() { [weak self] result in
			guard let result = result else { return }
			
			self?.backingStore.update(
				itemsForSections: [
					.description: [result.description],
					.actions: result.actions
				],
				dataSource: self
			)
		}
	}
}
```

## Author

Patrick Lynch: pdlynch@gmail.com

## License

`BackingStore` is available under the MIT license. See the LICENSE file for more info.

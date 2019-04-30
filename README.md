Architecture - SOA in **SOLID** and **DRY** principles.

**SOA** contains three levels, Presentation Layer, Service Layer and Core Layer.

Presentation layer made as view controllers and presenters. Presenters are business layer of view and work with Service Layer only.

ViewControllers only handle gestures and draw views.

Frameworks - **Core Data**, **multipeer connectivity**.

Core data used in bunch with **Fetch Result Contoller** in Presenters witch implement DataSourse functional for UITableViews.

Core data was build in stack with chain of three contexts. Two in private queue and one of the main queue.

Any types of request to Core Data wrapped up to **generic** functions. So I can used its to any **NSManagedObjects** in project. 

MultiPeer made for only 8 users for session and has codebale protocol for PeerId. He’s rule how displayName decode and encode to ID and Name of User.

Messages sending as **JSON** bunches. For **codable** messages responds MessageStruct witch can init Message Entiti of Core Data or been inited from it.

There is one feature you can set as avatar some cat or made or use any photo from library. **API**: [api.thecatapi.com](http://api.thecatapi.com).

Network Layer implement abstract fabric to requests and parsers to any type of API. All what need to do is made a entitys implements Iparser protocol for Parser and IrequestProtocol for requests and use only one RequestSender entity in project.

Presenter with collection view of cats download images in async by **Operation Queue.**


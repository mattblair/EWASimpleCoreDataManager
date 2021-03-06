# EWASimpleCoreDataManager

_Note to anyone who stumbles across this:_ I wouldn't recommend using this for your own projects yet. Or maybe ever.

This is an assemblage of code I've used in projects in the past, most of which predates the rise of CocoaPods. I've pushed it to github to make it easy for me to integrate it into some other public projects I've created.

I have particular use cases where this works well for me, and I just haven't taken the time (yet) to evaluate and integrate some of the other more advanced Core Data-related projects listed below.

There are also some JSON and GeoJSON helper methods included in the main Core Data singleton class. I put them there for convenience because I frequently populate Core Data from JSON sources. It might make sense to split these off at some point, too.

This class and category are just as complicated as I need them to be for several of my projects, but no more complicated than that. They're not suited to doing any significant number of datastore writes in production. If you are storing lots of user or run-time generated data in Core Data, you definitely want to explore the projects listed below, or roll your own, so that you aren't doing all that on the main thread.

If you do find this useful for some reason, let me know or send pull requests – maybe I'll clean it up, and release a new one. Meanwhile, consider this a piece of internal code that has a double-life as example code.

Also note: the UI is is not implemented at all. I might get to that someday.

## Other Core Data Projects 
I haven't eveluated any of these yet, but they each seemed to merit further study:

<https://github.com/danielctull/DCTCoreDataStack>

<https://github.com/peymano/DVCoreDataFinders>

<https://github.com/franciscojrp/FRPCoreDataManager>

<https://github.com/lafosca/LFSCoreData>

## Further Reading:

<http://nshipster.com/core-data-libraries-and-utilities/>

<http://www.objc.io/issue-4/index.html>
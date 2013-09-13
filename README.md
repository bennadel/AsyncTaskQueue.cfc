
# AsyncTaskQueue.cfc

by [Ben Nadel][1] (on [Google+][2])

ColdFusion threads are awesome because they allow you to run tasks in parallel.
This is a particularly excellent optimization for set-it and forget-it style 
tasks. However, there are some thread limitations to be aware of. Specifically,
ColdFusion Standard has a concurrent thread limit of 10. If you launch more 
than 10 threads, they start to get queued. If you're executing non-essential
tasks, it doesn't much matter; but, your non-essential tasks can end up 
blocking tasks with a higher business priority.

To work within this constraint, I created the AsyncTaskQueue.cfc. This is a 
ColdFusion component that processes a queue of tasks using a single CFThread. 
So, rather than spawning a separate thread for each low-priority task, the 
AsyncTaskQueue.cfc spawns one thread and processes the low-priority tasks, in
serial, in the context of the single thread.

While it can be called on its own, I had envisioned the AsyncTaskQueue.cfc 
as being extended. It has one public method that allows tasks to be added to 
the internal queue:

* addTask( callback, callbackArguments ) :: Void

You provide the queue with a callback function and an optional set of arguments
to be used when invoking the callback function. This task then gets queued and
flushed within a single CFThread tag.


[1]: http://www.bennadel.com
[2]: https://plus.google.com/108976367067760160494?rel=author
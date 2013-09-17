<cfscript>
component
	output = false
	hint = "I provide the infrastructure for filling and flushing an asynchronous task queue inside of a single CFThread."
	{

	// I return the initialized component.
	public any function init() {
		// I hold the task items to be processed.
		variables.taskQueue = [];

		// We need a globally unique ID in order to create unqiuely named locks and threads.
		// This will avoid name collissions and ColdFusion errors.
		variables.taskQueueID = lcase( createUUID() );

		// The queue will be processed in an asynchronous thread. To ensure that thread
		// names do not collide, we need to generate a unique thread name every timet that
		// we spawn a new thread (since it may or may not be within a single page request).
		variables.asyncTaskThreadIndex = 1;
		variables.asyncTaskThreadName = getNewAsyncThreadName();

		// I determine if there is an active thread running, processing the queue.
		variables.isThreadRunning = false;

		// To ensure that all the interactions are thread safe, queue and thread touch-points
		// must be sychronized.
		variables.asyncTaskLockName = getAsyncTaskLockName();
		variables.asyncTaskLockTimeout = 30;

		return( this );
	}


	// ---
	// PUBLIC METHODS.
	// ---


	// I add the given task (callback) to the internal queue, using the optional arguments
	// at invocation time.
	public void function addTask(
		required any taskMethod,
		any taskArguments = structNew()
		) {

		lock
			name = variables.asyncTaskLockName
			timeout = variables.asyncTaskLockTimeout
			{

			addNewTaskItem( arguments.taskMethod, arguments.taskArguments );

			// If we already have a thread running, then just let it do it's thing - we've
			// added the task item, it will be flushed eventually.
			if ( variables.isThreadRunning ) {
				return;
			}

			variables.isThreadRunning = true;

			thread
				action = "run"
				name = variables.asyncTaskThreadName
				priority = "low"
				{
				var taskItem = "";
				var isQueueEmpty = false;
				var isQueueFull = false;

				do {
					lock
						name = variables.asyncTaskLockName
						timeout = variables.asyncTaskLockTimeout
						{

						taskItem = getNextTaskItem();
					}

					while ( structKeyExists( local, "taskItem" ) ) {

						try {

							taskItem.taskMethod( argumentCollection = taskItem.taskArguments );

						} catch ( any error ) {

							// TODO: Track errors...

						}

						lock
							name = variables.asyncTaskLockName
							timeout = variables.asyncTaskLockTimeout
							{

							taskItem = getNextTaskItem();

						}

					} // END: While.

					lock
						name = variables.asyncTaskLockName
						timeout = variables.asyncTaskLockTimeout
						{

						isQueueEmpty = ! arrayLen( variables.taskQueue );
						isQueueFull = ! isQueueEmpty;

						// If the queue is empty, then we want to flag the thread as having
						// finished executing; however, since the same page request may add more
						// items to the queue, we need to make sure that our next queue has a
						// uniquely-named thread.
						if ( isQueueEmpty ) {
							variables.isThreadRunning = false;
							variables.asyncTaskThreadName = getNewAsyncThreadName();
						}
					}

				} while ( isQueueFull );

			} // END: Thread.

		} // END: Lock.

	}


	// ---
	// PRIVATE METHODS.
	// ---


	// I push the given task onto the queue. The task arguments can be either an array of
	// ordered arguments; or, a collection of named arguments.
	private void function addNewTaskItem(
		required any taskMethod,
		required any taskArguments
		) {

		// If the arguments were passed as ordered arguments, convert the ordered arguments
		// into a named collection so that we can invoke the task method with a uniform syntax,
		// using the argumentsCollection.
		if ( isArray( arguments.taskArguments ) ) {
			arguments.taskArguments = convertArgumentsArrayToCollection( arguments.taskArguments );
		}

		arrayAppend(
			variables.taskQueue,
			{
				taskMethod = arguments.taskMethod,
				taskArguments = arguments.taskArguments
			}
		);
	}


	// I convert the given ordered arguments array into a proper named arguments collection.
	private struct function convertArgumentsArrayToCollection(
		required array argumentsArray
		) {
		var argumentsCollection = getEmptyArgumentsCollection();
		var i = 1;

		for ( i = 1 ; i <= arrayLen( arguments.argumentsArray ) ; i++ ) {
			argumentsCollection[ i ] = arguments.argumentsArray[ i ];
		}

		return( argumentsCollection );
	}


	// I get the name for the named lock that synchronizes some of the task-queue touch points.
	private string function getAsyncTaskLockName() {
		return( "lock-#variables.taskQueueID#" );
	}


	// I return a new, empty instance of the special Arguments object which has special behavior
	// that allows for both key and index access.
	private any function getEmptyArgumentsCollection() {
		return( arguments );
	}


	// I get a new, unique thread name for the task processor.
	// --
	// NOTE: This incrementation does NOT need to be thread-safe since this method is always
	// called from withing
	private string function getNewAsyncThreadName() {
		// NOTE: We are using the explicit "variables." scope here so that the value doesn't
		// get stored in the thread-local scope (which seems to happen if omitted).
		var index = ++variables.asyncTaskThreadIndex;

		return( "thread-#variables.taskQueueID#-#index#" );
	}


	// I get the next task in FIFO (First-In, First-Out) order. If the task queue is empty, the
	// return value is null.
	private any function getNextTaskItem() {
		var taskItem = "";
		if ( arrayLen( variables.taskQueue ) ) {
			taskItem = variables.taskQueue[ 1 ];

			arrayDeleteAt( variables.taskQueue, 1 );

			return( taskItem );
		}
	}

}
</cfscript>

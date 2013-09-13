<cfscript>

component
	extends = "lib.AsyncTaskQueue"
	output = false
	hint = "I download remote images to a given downloads directory."
	{

	// I initialize the downloader task queue.
	public any function init( required string downloadsDirectory ) {

		super.init();

		variables.downloadsDirectory = downloadsDirectory;

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	// I add the download task to the internal, asynchronous queue.
	public void function download( required string imageUrl ) {

		addTask( executeDownload, [ imageUrl ] );

	}


	// ---
	// PRIVATE METHODS.
	// ---


	// I execute the actual download task (inside a CFThread).
	private void function executeDownload( required string imageUrl ) {

		var downloadRequest = new Http(
			url = imageUrl,
			method = "get",
			getasbinary = "yes",
			path = downloadsDirectory,
			file = getFileFromPath( imageUrl )
		);
		
		downloadRequest.send();

	}

}

</cfscript>
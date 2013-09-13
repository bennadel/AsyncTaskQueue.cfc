<cfscript>

component
	output = false
	hint = "I define the application settings and event handlers."
	{

	// Define the application settings.
	this.name = hash( getCurrentTemplatePath() );
	this.applicationTimeout = createTimeSpan( 0, 0, 10, 0 );
	this.sessionManagement = false;

	// Get the various directories needed for mapping.
	this.directory = getDirectoryFromPath( getCurrentTemplatePath() );
	this.projectDirectory = ( this.directory & "../" );

	// Map the library so we can instantiate components.
	this.mappings[ "/lib" ] = "#this.projectDirectory#lib/";

	// Map the downloads directory for file IO.
	this.mappings[ "/downloads" ] = "#this.directory#downloads/";


	// I handle the application initialization.
	public boolean function onApplicationStart() {

		// Cache an instance of the downloader so that all requests are accessing
		// the same instance of the task queue.
		application.downloader = new Downloader( expandPath( "/downloads/" ) );

		return( true );

	}


	// I handle the request initialization.
	public boolean function onRequestStart() {

		if ( structKeyExists( url, "init" ) ) {

			onApplicationStart();

		}

		return( true );

	}

}

</cfscript>
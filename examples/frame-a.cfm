<cfscript>

	// Frame A - download targets.
	application.downloader.download( "http://farm7.staticflickr.com/6083/6155175814_135ca09ce7_z.jpg" );
	application.downloader.download( "http://farm7.staticflickr.com/6201/6156567563_7bb3fa8db7_z.jpg" );

	// Frame B - download targets.
	// application.downloader.download( "http://farm3.staticflickr.com/2164/2241424019_a1eed40dfc.jpg" );
	// application.downloader.download( "http://farm7.staticflickr.com/6169/6151770695_b3d18553cb_z.jpg" );

	// Output the collection of CFThreads that were generated during this page request.
	// If the Downloader was already "churning", then no new threads will have been generated.
	writeDump(
		var = cfthread,
		label = "Threads In Page Request (FRAME-A)" 
	);

</cfscript>
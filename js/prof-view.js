function toggle( className, displayState ) {
	var elements = document.getElementsByClassName( className )
	for ( var i = 0; i < elements.length; i++ ) {
		elements[ i ].style.display = displayState;
	}
}
const params = ( new URL( location ) )
	.searchParams;
if ( params.get( 'viewas' ) === "prof" ) {
	toggle( 'nottoprint', 'none' );
	toggle( 'profview', 'block' );
}

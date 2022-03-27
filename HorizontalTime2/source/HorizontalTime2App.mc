using Toybox.Application as App;
using Toybox.Lang as Lang;
using Toybox.WatchUi as Ui;

class HorizontalTime2App extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new HorizontalTime2View() ] as Array<Views or InputDelegates>;
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        Ui.requestUpdate();
    }

}

function getApp() as HorizontalTime32pp {
    return Application.getApp() as HorizontalTime2App;
}
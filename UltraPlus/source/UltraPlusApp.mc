import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

var gAppSettings;
var gSettingsChanged = false;

class UltraPlusApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
        $.gAppSettings = Application.getApp();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new UltraPlusView() ];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        $.gSettingsChanged = true;
        $.gAppSettings = Application.getApp();
        WatchUi.requestUpdate();
    }

}

function getApp() as UltraPlusApp {
    return Application.getApp() as UltraPlusApp;
}
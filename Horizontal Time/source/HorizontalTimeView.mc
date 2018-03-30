using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.ActivityMonitor as Act;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Application as App;

class HorizontalTimeView extends Ui.WatchFace {

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }
	
	function renderDate() {
		// Get date
		var now = Time.now();
		var info = Calendar.info(now, Time.FORMAT_LONG);
        var dateString = Lang.format("$1$ $2$ $3$", [info.day_of_week.substring(0, 3).toUpper(), info.month.toUpper(), info.day]);
        var dateView = View.findDrawableById("DateLabel");
        dateView.setText(dateString);
	}
	
	function renderStats() {
		// Get battery life and steps
		var stats = Sys.getSystemStats();
		var batteryStatus = stats.battery;
		var battView = View.findDrawableById("StatsLabel");
		var stepStats = Act.getInfo();
    		var steps = stepStats.steps;
		var percentage = (stats.battery).toNumber();
		// concatenate battery and steps
		battView.setText(percentage.toString()+"%"+" | "+steps);
	}
	
	function renderConnected(dc) {
		var isConnected = Sys.getDeviceSettings().phoneConnected;
		
		if (isConnected) {
			// render the bluetooth logo - use pixels for better fidelity
			dc.setColor(Gfx.COLOR_DK_GRAY,Gfx.COLOR_BLACK);
			dc.drawLine(154, 176, 154, 188);
			dc.drawPoint(155, 177); 
			dc.drawPoint(156, 178); 
			dc.drawPoint(157, 179);
			dc.drawPoint(156, 180);
			dc.drawPoint(155, 181);
			dc.drawPoint(155, 182);
			dc.drawPoint(156, 183);
			dc.drawPoint(157, 184);
			dc.drawPoint(156, 185);
			dc.drawPoint(155, 186);
			
			dc.drawPoint(152, 179);
			dc.drawPoint(153, 180);
			dc.drawPoint(152, 183);
			dc.drawPoint(153, 182);
		} 
	}
	
	function drawHour(utc) {
		// Define hour variables and calculate the hours
        var hourStringLess2 = checkH(utc,-2);
        var hourStringLess1 = checkH(utc,-1); 
        var hourString = checkH(utc,0);
        var hourStringPlus1 = checkH(utc,1);
        var hourStringPlus2 = checkH(utc,2);
		
		// Define the layout labels
        var hrL2 = View.findDrawableById("HourLabelL2");
        var hrL1 = View.findDrawableById("HourLabelL1");
        var hr;
        var hrP1 = View.findDrawableById("HourLabelP1");
        var hrP2 = View.findDrawableById("HourLabelP2");
        
        // Set values for layout items
        hrL1.setText(hourStringLess1);
        hrL2.setText(hourStringLess2);
        hrP1.setText(hourStringPlus1);
        hrP2.setText(hourStringPlus2);
        
        // Set the correct layout item based on time
        if (hourString.toFloat() > 9 && hourString.toFloat() < 20) {
        	hr = View.findDrawableById("HourLabel");
        	hr.setText("");
        	hr = View.findDrawableById("HourLabelAlt");
			hr.setText(hourString);
        } else {
        	hr = View.findDrawableById("HourLabelAlt");
        	hr.setText("");
        	hr = View.findDrawableById("HourLabel");
			hr.setText(hourString);
        }
	}
	
	function drawMinutes(utc) {
		// Define minute variables and calculate the minutes
        var minuteStringLess3 = checkM(utc,-3);
        var minuteStringLess2 = checkM(utc,-2);
        var minuteStringLess1 = checkM(utc,-1);
        var minuteString = checkM(utc,0);
        var minuteStringPlus1 = checkM(utc,1);
        var minuteStringPlus2 = checkM(utc,2);
        var minuteStringPlus3 = checkM(utc,3);
        
        // Define minute label
        var mnL3 = View.findDrawableById("MinuteLabelL3");
        var mnL2 = View.findDrawableById("MinuteLabelL2");
        var mnL1 = View.findDrawableById("MinuteLabelL1");
        var mn = View.findDrawableById("MinuteLabel");
        var mnP1 = View.findDrawableById("MinuteLabelP1");
        var mnP2 = View.findDrawableById("MinuteLabelP2");
        var mnP3 = View.findDrawableById("MinuteLabelP3");
        
        // Set values for layout items
        mnL3.setText(minuteStringLess3);
        mnL2.setText(minuteStringLess2);
        mnL1.setText(minuteStringLess1);
        mnP1.setText(minuteStringPlus1);
        mnP2.setText(minuteStringPlus2);
        mnP3.setText(minuteStringPlus3);
        
        // Set the correct layout item based on time
        if (minuteString.toFloat() > 9 && minuteString.toFloat() < 20) {
        	mn = View.findDrawableById("MinuteLabel");
			mn.setText("");
        	mn = View.findDrawableById("MinuteLabelAlt");
			mn.setText(minuteString);
        } else {
        	mn = View.findDrawableById("MinuteLabelAlt");
			mn.setText("");
        	mn = View.findDrawableById("MinuteLabel");
			mn.setText(minuteString);
        }
	}
	
	function checkH(utc,modifier) {
		var extraTime = new Time.Duration(60*60*modifier);
		var newUTC = utc.add(extraTime);
		var newUTCVal = newUTC.value();
		var date = Calendar.info(newUTC,Time.FORMAT_SHORT);
		return Lang.format("$1$",[date.hour.format("%02d")]);
	}
	
	function checkM(utc,modifier) {
		var extraTime = new Time.Duration(60*modifier);
		var newUTC = utc.add(extraTime);
		var newUTCVal = newUTC.value();
		var date = Calendar.info(newUTC,Time.FORMAT_SHORT);
		return Lang.format("$1$",[date.min.format("%02d")]);
	}
	
    //! Update the view
    function onUpdate(dc) {
        // Define the current time and hour
        var utc = Time.now();
        var app = App.getApp();
          
		drawHour(utc);
		drawMinutes(utc);
		renderDate();
		renderStats();
		
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        renderConnected(dc);
        
        //Sys.println("Display Size:" + dc.getWidth()+"x"+dc.getHeight());
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep(dc) {
    	Ui.requestUpdate(); //request that onUpdate() method be called for the current View
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    	Ui.requestUpdate(); //request that onUpdate() method be called for the current View
    }
    
    function onSettingsChanged(dc) {
		var bgColor = App.getApp().getProperty("BG_COLOR");
	        // handleYourColorChangesHere(color);
			dc.setColor(Gfx.COLOR_DK_GREEN,Gfx.COLOR_ORANGE);
			dc.fillCircle(109, 109, 109);
		Ui.requestUpdate();
	}
}

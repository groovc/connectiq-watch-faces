using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.ActivityMonitor as Act;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;

class HorizontalTimeView extends Ui.WatchFace {
	var theDC;
    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

	// Ensure all minutes are between 00-59 
	function checkMinute(num, modifier) {
		// If the computed amount is less than zero then start at 60
		if (num+modifier < 0) {
			num = 60;
		}

		// If the computed amount is greater than 59 then start at -1
		if (num+modifier > 59) {
			num = -1;
		}
		
		// Return a 2-digit number string
		return Lang.format("$1$",[(num+modifier).format("%02d")]);
	}
	
	// Ensure all hours are between 0-23
	function checkHour(num, modifier) {
		// If the computed amount is less than zero then start at 24
		if (num+modifier < 0) {
			num = 24;
		}

		// If the computed amount is greater than 23 then start at -1
		if (num+modifier > 23) {
			num = -1;
		}

		// Return a 2-digit number string
		return Lang.format("$1$",[(num+modifier).format("%02d")]);
	}
	
	function renderHour(time) {
		var hours = time.hour;
		// Define hour variables and calculate the hours
        var hourString = checkHour(hours,0);
        var hourStringLess1 = checkHour(hours,-1); 
        var hourStringLess2 = checkHour(hours,-2);
        var hourStringPlus1 = checkHour(hours,1);
        var hourStringPlus2 = checkHour(hours,2);
        
        // Define the layout labels
        var hr;
        var hrL1 = View.findDrawableById("HourLabelL1");
        var hrL2 = View.findDrawableById("HourLabelL2");
        var hrP1 = View.findDrawableById("HourLabelP1");
        var hrP2 = View.findDrawableById("HourLabelP2");
        
        // Set values for layout items
        hrL1.setText(hourStringLess1);
        hrL2.setText(hourStringLess2);
        hrP1.setText(hourStringPlus1);
        hrP2.setText(hourStringPlus2);
        
        // Set the correct layout item based on time
        if (hours > 9 && hours < 20) {
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
	
	function renderMinutes(time) {
		var minutes = time.min.format("%.2d").toNumber();
		// Define minute variables and calculate the minutes
		var minuteString = checkMinute(minutes,0);
        var minuteStringLess1 = checkMinute(minutes,-1);
        var minuteStringLess2 = checkMinute(minutes,-2);
        var minuteStringLess3 = checkMinute(minutes,-3);
        var minuteStringPlus1 = checkMinute(minutes,1);
        var minuteStringPlus2 = checkMinute(minutes,2);
        var minuteStringPlus3 = checkMinute(minutes,3);
        
        // Define minute label
		var mn = View.findDrawableById("MinuteLabel");
        var mnL1 = View.findDrawableById("MinuteLabelL1");
        var mnL2 = View.findDrawableById("MinuteLabelL2");
        var mnL3 = View.findDrawableById("MinuteLabelL3");
        var mnP1 = View.findDrawableById("MinuteLabelP1");
        var mnP2 = View.findDrawableById("MinuteLabelP2");
        var mnP3 = View.findDrawableById("MinuteLabelP3");
        
        // Set values for layout items
        mnL1.setText(minuteStringLess1);
        mnL2.setText(minuteStringLess2);
        mnL3.setText(minuteStringLess3);
        mnP1.setText(minuteStringPlus1);
        mnP2.setText(minuteStringPlus2);
        mnP3.setText(minuteStringPlus3);
        
        // Set the correct layout item based on time
        if (minutes > 9 && minutes < 20) {
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
	
    //! Update the view
    function onUpdate(dc) {
        // Define the current time and hour
        var clockTime = Sys.getClockTime();      
        theDC = dc;
        
        renderHour(clockTime);
        renderMinutes(clockTime);
		renderDate();
		renderStats();
		
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        renderConnected(dc);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep(dc) {
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}

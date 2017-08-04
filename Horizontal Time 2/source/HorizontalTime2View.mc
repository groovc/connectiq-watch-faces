using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.ActivityMonitor as Act;
using Toybox.SensorHistory;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Lang as Lang;
using Toybox.Application as App;

class HorizontalTime2View extends Ui.WatchFace {
	var screen_width,
	 	screen_height,
	 	globalDateString,
	 	customFontHour = null,
	 	customFontMinute = null,
	 	customFontXTiny = null,
	 	myDivider;
	
	// add Activity.Info
	// currentHeartRate
	// averageHeartRate
	// maxHeartRate
	 	
    function initialize() {
        WatchFace.initialize();
        myDivider = new Rez.Drawables.Divider();
    }

    // Load your resources here
    function onLayout(dc) {
    		//get screen dimensions
		screen_width = dc.getWidth();
		screen_height = dc.getHeight();
		
		customFontHour = Ui.loadResource(Rez.Fonts.customFontPrimary);
		customFontMinute = Ui.loadResource(Rez.Fonts.customFontSecondary);
		customFontXTiny = Ui.loadResource(Rez.Fonts.customFontXTiny);
    
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }
	
	function renderTime(dc,utc) {
		// Get the current time and format it correctly
        var timeFormat = "$1$$2$";
        var clockTime = Sys.getClockTime();
        var hours = clockTime.hour;
        var minutes = clockTime.min;
        
        if (!Sys.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }
        
		// Set the time values     
        var hourString = hours.format("%02d");
        var minuteString = minutes.format("%02d");
        var hourStringL1 = formatHour(utc,-1); 
        var hourStringP1 = formatHour(utc,1); 
        var hourStringL2 = formatHour(utc,-2);
        var hourStringP2 = formatHour(utc,2); 
        var minuteStringL1 = formatMinutes(utc,-1); 
        var minuteStringP1 = formatMinutes(utc,1); 
        var minuteStringL2 = formatMinutes(utc,-2); 
        var minuteStringP2 = formatMinutes(utc,2); 
        var minuteStringL3 = formatMinutes(utc,-3); 
        var minuteStringP3 = formatMinutes(utc,3); 
        
        // Grab the views
        var viewHour = View.findDrawableById("HourLabel");      
        var viewMinutes = View.findDrawableById("MinuteLabel");
        var viewHourL1 = View.findDrawableById("HourLabelL1");
        var viewHourP1 = View.findDrawableById("HourLabelP1");
        var viewHourL2 = View.findDrawableById("HourLabelL2");
        var viewHourP2 = View.findDrawableById("HourLabelP2");
        var viewMinuteL1 = View.findDrawableById("MinuteLabelL1");
        var viewMinuteP1 = View.findDrawableById("MinuteLabelP1"); 
        var viewMinuteL2 = View.findDrawableById("MinuteLabelL2");
        var viewMinuteP2 = View.findDrawableById("MinuteLabelP2");
        var viewMinuteL3 = View.findDrawableById("MinuteLabelL3");
        var viewMinuteP3 = View.findDrawableById("MinuteLabelP3");
        
        // Update the colors and time views 
        viewHour.setColor(App.getApp().getProperty("HourColor"));
        viewHour.setText(hourString);
        
        viewMinutes.setColor(App.getApp().getProperty("MinutesColor"));
        viewMinutes.setText(minuteString);
        
        viewHourL1.setColor(App.getApp().getProperty("TimeSecondaryColor"));
        viewHourL1.setText(hourStringL1);
        viewHourP1.setColor(App.getApp().getProperty("TimeSecondaryColor"));
        viewHourP1.setText(hourStringP1);
        viewMinuteL1.setColor(App.getApp().getProperty("TimeSecondaryColor"));
        viewMinuteL1.setText(minuteStringL1);
        viewMinuteP1.setColor(App.getApp().getProperty("TimeSecondaryColor"));
        viewMinuteP1.setText(minuteStringP1);
        
        viewHourL2.setColor(App.getApp().getProperty("TimeTertiaryColor"));
        viewHourL2.setText(hourStringL2);
        viewHourP2.setColor(App.getApp().getProperty("TimeTertiaryColor"));
        viewHourP2.setText(hourStringP2);
        viewMinuteL2.setColor(App.getApp().getProperty("TimeTertiaryColor"));
        viewMinuteL2.setText(minuteStringL2);
        viewMinuteP2.setColor(App.getApp().getProperty("TimeTertiaryColor"));
        viewMinuteP2.setText(minuteStringP2);
        viewMinuteL3.setColor(App.getApp().getProperty("TimeTertiaryColor"));
        viewMinuteL3.setText(minuteStringL3);
        viewMinuteP3.setColor(App.getApp().getProperty("TimeTertiaryColor"));
        viewMinuteP3.setText(minuteStringP3);
	}

	function renderDate(dc) {
		// Get date
		var today = Calendar.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateString = Lang.format(
	        	"$1$ $2$ $3$",
	        	[
	        		today.day_of_week.toUpper(),
	        		today.month.toUpper(),
	        		today.day
	        	]
        );
        var dateView = View.findDrawableById("DateLabel");
        dateView.setColor(App.getApp().getProperty("DateColor"));
        dateView.setText(dateString);
        // Pass this along for later
        globalDateString = dateString;
	}
		
	function renderStats() {
		var statsView = View.findDrawableById("StatsLabel");
		// Get battery life
		var stats = Sys.getSystemStats();
		var batteryStatus = stats.battery;
		var percentage = (stats.battery).toNumber();
		var layoutType = App.getApp().getProperty("StatsLayout");
		
		statsView.setColor(App.getApp().getProperty("StatsColor"));
		
		switch (layoutType) {
			case 0:
				statsView.setText(percentage.toString()+"%");
			break;
			case 1:
				// Get steps
				var stepStats = Act.getInfo();
	    			var steps = stepStats.steps;
	    			// concatenate battery and steps
				statsView.setText(percentage.toString()+"%"+" | "+steps);
			break;
			case 2:
				// get a HeartRateIterator object; oldest sample first
				if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getHeartRateHistory)) {
					var hrIterator = Act.getHeartRateHistory(null, false);
					var previous = hrIterator.next();                                   // get the previous HR
					var lastSampleTime = null;                                          // get the last
					var displayRate;		
					
				    var sample = hrIterator.next();
				    if (null != sample) {                                           // null check
				        if (sample.heartRate != Act.INVALID_HR_SAMPLE    // check for invalid samples
				            && previous.heartRate
				            != Act.INVALID_HR_SAMPLE) {
				                lastSampleTime = sample.when;
				                // System.println("Previous: " + previous.heartRate);  // print the previous sample
				                // System.println("Sample: " + sample.heartRate);      // print the current sample
				                displayRate = sample.heartRate;
				                statsView.setText(percentage.toString()+"%"+" | "+ displayRate + " HR");
				        }
				    }
			    } else {
			    		statsView.setText(percentage.toString()+"%"+" | "+"No HR");
			    }
			    
			break;
			default:
			// if all else fails
				statsView.setText(percentage.toString()+"%");
			break;
		}
	}
	
	function renderDivider(dc) {
		var dateView = View.findDrawableById("DateLabel");
		// Get the dimensions of the date string to determine length of divider
		// Longest String is THURS JUL 28
		var dvDim = dc.getTextDimensions(globalDateString, Gfx.FONT_SYSTEM_XTINY);
		// Grab the width of the date string
		var dvWidth = dvDim[0];
		// Grab the height of the date string
		var dvHeight = dvDim[1];
		// Grab the Y coordinate of the date view
		var dvLocationY = dateView.locY;
		var padding = 0;
		// Calculate the X coordinate of the divider based on center of the screen less 1/2 the string width
		var dividerX = (screen_width/2) - (dvWidth/2);
		// Calculate the Y coordinate of the divider based on where the date string is and its height
		var dividerY = dvHeight + dvLocationY + padding;
		
		// Grab the color from the properties
		dc.setColor(App.getApp().getProperty("DividerColor"), Gfx.COLOR_TRANSPARENT);
		// Setup the rectangle/divider
		dc.fillRectangle(dividerX, dividerY, dvWidth, 1);
		// Draw it to the screen
		myDivider.draw(dc);
	}
	
	// This function uses UTC Time so that hours stay within 0-23
	function formatHour(utc, modifier) {
		var extraTime = new Time.Duration(60*60*modifier);
		var newUTC = utc.add(extraTime);
		var newUTCVal = newUTC.value();
		var date = Calendar.info(newUTC,Time.FORMAT_SHORT);
		
		// Handle the weird use cases of using 12 hour time display
		if (!Sys.getDeviceSettings().is24Hour) {
            // Display 12 at 0 o'clock            
            if (date.hour == 0) {
        			date.hour = 12;
        		}
        		// Subtract 12 so numbers you don't see UTC numbers
            if (date.hour > 12) {
            		date.hour = date.hour - 12;          		
            } 
            return Lang.format("$1$",[date.hour.format("%02d")]);
        } else {
        		return Lang.format("$1$",[date.hour.format("%02d")]);
        	}
	}
	
	// This function uses UTC time so that the minutes stay within 0-59
	function formatMinutes(utc,modifier) {
		var extraTime = new Time.Duration(60*modifier);
		var newUTC = utc.add(extraTime);
		var newUTCVal = newUTC.value();
		var date = Calendar.info(newUTC,Time.FORMAT_SHORT);
		return Lang.format("$1$",[date.min.format("%02d")]);
	}
	
    // Update the view
    function onUpdate(dc) {
		var utc = Time.now();
		
		// Render the date
		renderDate(dc);
		// Render the stats
		renderStats();	
		// Render the time
        renderTime(dc,utc);
        
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc); 
        
        // Render the divider
        renderDivider(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}

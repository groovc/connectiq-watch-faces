using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.ActivityMonitor as Act;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;

class OutsideInView extends Ui.WatchFace {

    //! Constants
    const BAR_THICKNESS = 3;
    const ARC_MAX_ITERS = 300;

    //! Class vars
    var fast_updates = true;
    var device_settings;
    var width;
	var height;
	var center_x;
	var center_y;
	var minute_radius;
	var hour_radius;
	var minute_width;
	var hour_width;
	var second_width;
	var font;
	var myTimer;
    
	//! Load your resources here
    function onLayout(dc) {
        device_settings = Sys.getDeviceSettings();
        width = dc.getWidth();
    	height = dc.getHeight();
    	center_x = dc.getWidth()/2;
        center_y = dc.getHeight()/2;
        
        minute_radius = 7/8.0 * center_x;
        hour_radius = 2.7/3.0 * minute_radius;
        
        minute_width = 5;
        hour_width = 5;
        second_width = 1;
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
    }
    
    //! Update the view
    function onUpdate(dc) {	
       
        // Days of month lookup - February is close enough.
        var days_per_month = [ 0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ];
        var font_ofst = BAR_THICKNESS - dc.getFontHeight(Gfx.FONT_TINY) + 4;

        // Set background color
        dc.clear();
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());

        var x = dc.getWidth() / 2;
        var y = dc.getHeight() / 2;
        
        // Current Steps and Attempted Steps
		var activity = Act.getInfo();
    	var currentSteps = activity.steps;
    	var targetSteps = (activity.stepGoal+"f").toFloat();
    	
    	// add temporary steps
    	if (currentSteps == 0) {
    		// currentSteps = 1000;
    	}
    	
    	// Draw tick marks
		var watchFace = new Rez.Drawables.WatchFace();
		watchFace.draw(dc);
    	
    	// Draw the empty line
    	drawArc(dc, x, y, 109, 2 * Math.PI, Gfx.COLOR_DK_GRAY);
    	// Draw the fill line on top of it
    	drawArc(dc, x, y, 109, (currentSteps / targetSteps) * 2 * Math.PI, Gfx.COLOR_BLUE);
    	
    	// Draw hour/minute hands
    	drawTime(dc);
    	
    	// Draw center area
		dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
		dc.fillCircle(x, y, 65);
		
		// Draw date area
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.fillCircle(68, 68, 21);

        // Get date information
		var now = Time.now();
		var clockTime = Sys.getClockTime();
		var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%.2d")]);
        
		var info = Calendar.info(now, Time.FORMAT_LONG);
        //var dateString = Lang.format("$1$ $2$ $3$", [info.day_of_week.substring(0, 3).toUpper(), info.month.toUpper(), info.day]);
        var dateString = Lang.format("$1$", [info.day]);
        var monthString = Lang.format("$1$", [info.month.toUpper()]);
        var dayString = Lang.format("$1$", [info.day_of_week.substring(0, 3).toUpper()]);
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.drawText(68, 48, Gfx.FONT_TINY, dateString, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(68, 63, Gfx.FONT_XTINY, monthString, Gfx.TEXT_JUSTIFY_CENTER);
        // draw the time in the middle
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, 80, Gfx.FONT_NUMBER_MEDIUM, timeString, Gfx.TEXT_JUSTIFY_CENTER);
  		// draw day
        dc.drawText(x, 64, Gfx.FONT_XTINY, dayString, Gfx.TEXT_JUSTIFY_CENTER);

		// Draw battery
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    	dc.drawRectangle(100, 146, 20, 10);
    	dc.fillRectangle(120, 149, 1, 4);
    	var stats = Sys.getSystemStats();
		var batteryStatus = stats.battery;
		var battLife = batteryStatus / 100 * 16;
		dc.fillRectangle(102, 148, battLife, 6);

        // If updates
        if( fast_updates ) {
        }
    }
    
    //! This is a generic function to draw the hands on the screen 
    function drawHand(dc, angle, length, width)
    {
        // Map out the coordinates of the watch hand
        var coords = [ [-(width/2),0], [-(width/2), -length], [width/2, -length], [width/2, 0] ];
        var result = new [4];
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        // Transform the coordinates
        for (var i = 0; i < 4; i += 1)
        {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin);
            var y = (coords[i][0] * sin) + (coords[i][1] * cos);
            result[i] = [ centerX+x, centerY+y];
        }

        // Draw the polygon
        dc.fillPolygon(result);
    }
    
    function drawTime(dc) {
    	var clockTime = Sys.getClockTime();
        var now = Time.now();
        var hour = clockTime.hour;
        var minute = clockTime.min;
        var second = clockTime.sec;
        
    	// draw the hour
        hour = ( ( ( clockTime.hour % 12 ) * 60 ) + clockTime.min );
        hour = hour / (12 * 60.0);
        hour = hour * Math.PI * 2;
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        drawHand(dc, hour, hour_radius, hour_width);
        
        // draw the minute
		minute = ( clockTime.min / 60.0) * Math.PI * 2;
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        drawHand(dc, minute, minute_radius, minute_width);
        
        // Draw the inner circle
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.fillCircle(center_x, center_y, 7);
        dc.setColor(Gfx.COLOR_WHITE,Gfx.COLOR_BLACK);
        dc.drawCircle(center_x, center_y, 7);
        dc.drawCircle(center_x, center_y, 8);
    }
    
    
    //! Borrowed from https://github.com/CodyJung/connectiq-apps
    //! Fast (but kind of bad-looking) arc drawing.
    //! From http://stackoverflow.com/questions/8887686/arc-subdivision-algorithm/8889666#8889666
    //! TODO: Once we have drawArc, use that instead.
    function drawArc(dc, cent_x, cent_y, radius, theta, color) {
        dc.setColor( color, Gfx.COLOR_WHITE);
        var iters = ARC_MAX_ITERS * ( theta / ( 2 * Math.PI ) );
        var dx = 0;
        var dy = -radius;
        var ctheta = Math.cos(theta/(iters - 1));
        var stheta = Math.sin(theta/(iters - 1));

        dc.fillCircle(cent_x + dx, cent_y + dy, BAR_THICKNESS);

        for(var i=1; i < iters; ++i) {
            var dxtemp = ctheta * dx - stheta * dy;
            dy = stheta * dx + ctheta * dy;
            dx = dxtemp;
            dc.fillCircle(cent_x + dx, cent_y + dy, BAR_THICKNESS);
        }
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    }

    //! Right now we don't get another onUpdate when we go to sleep
    //! but for now, we can call requestUpdate ourselves
    function onEnterSleep( ) {
        fast_updates = false;
        Ui.requestUpdate();
    }

    function onExitSleep( ) {
        fast_updates = true;
    }

}

import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Weather;

class UltraPlusView extends WatchUi.WatchFace {
    var screen_width,
	 	screen_height,
        customIcons = null,
        weatherIcons = null,
        screenShape,
		aodMask,
        faceBG,
		maskRandomizer,
        accentColor,
        themeSelection,
        uiPrimaryColor,
        uiSecondaryColor,
        uiTertiaryColor,
        uiHashColor,
        fontFace,
        arcLabelFontSize,
        dayOfWeekFontSize,
        hourFontSize,
        circleFontSize,
        dataFontSize,
        displayUTC,
        hourMarkers,
		inLowPower = false,
		canBurnIn = false;	

    function initialize() {
        WatchFace.initialize();
        screenShape = System.getDeviceSettings().screenShape;
        var screenSize = System.getDeviceSettings().screenWidth;

        // Check if device requires burn in protection and set flag
		if (System.getDeviceSettings() has :requiresBurnInProtection) {
			canBurnIn = System.getDeviceSettings().requiresBurnInProtection;
			// check for real
			if (canBurnIn) {
				aodMask = WatchUi.loadResource(Rez.Drawables.AODMask); // load mask
				maskRandomizer = 0; // init mask position
			}        	
        }

        // Set The Font and Default Styles
        fontFace = "RobotoCondensedBold";
        // Change font for Venu 3
        if (Graphics.getVectorFont({:face=>["RobotoCondensedBold"], :size=>30}) == null) {
            fontFace = "RobotoRegular";   
        }

        // Set Font Sizes
        arcLabelFontSize = 16;
        dayOfWeekFontSize = 28;
        circleFontSize = 30;
        dataFontSize = 36;
        hourFontSize = 18;

        // Change Font Size based on Screen Size
        switch (screenSize) {
            case true:
                
            break;
            case 360:
                arcLabelFontSize = arcLabelFontSize*0.75;
                dayOfWeekFontSize = dayOfWeekFontSize*0.75;
                circleFontSize = circleFontSize*0.75;
                dataFontSize = dataFontSize*0.75;
                hourFontSize = hourFontSize*0.75;
            break;
            case 390:
                arcLabelFontSize = arcLabelFontSize*0.875;
                dayOfWeekFontSize = dayOfWeekFontSize*0.875;
                circleFontSize = circleFontSize*0.875;
                dataFontSize = dataFontSize*0.875;
                hourFontSize = hourFontSize*0.875;
            break;
            case 454:
                arcLabelFontSize = arcLabelFontSize*1.125;
                dayOfWeekFontSize = dayOfWeekFontSize*1.125;
                circleFontSize = circleFontSize*1.125;
                dataFontSize = dataFontSize*1.125;
                hourFontSize = hourFontSize*1.25;
            break;
            default:
                // Set Font Sizes
                arcLabelFontSize = 16;
                dayOfWeekFontSize = 28;
                circleFontSize = 30;
                dataFontSize = 36;
                hourFontSize = 18;
            break;
        }
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        // get screen dimensions
		screen_width = dc.getWidth();
		screen_height = dc.getHeight();

        // get custom font icons
        customIcons = WatchUi.loadResource(Rez.Fonts.customIcons);
        weatherIcons = WatchUi.loadResource(Rez.Fonts.weatherIcons);

        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var hourHand;
        var minuteHand;
        var secondHand;

        // Get the current time and format it correctly
        var clockTime = System.getClockTime();
        accentColor = Application.getApp().getProperty("AccentColor");
        // determine which layout to draw and initialize UI colors
        themeSelection = Application.getApp().getProperty("ThemeSelection");
        displayUTC = Application.getApp().getProperty("DisplayUTCTime");
        hourMarkers = Application.getApp().getProperty("HourMarkers");
        uiHashColor = 0x555555;

        // Render background based on theme preference
        switch (themeSelection) { 
            case true:
            break;
            case 0:
                if (inLowPower && canBurnIn) {
                    faceBG = WatchUi.loadResource(Rez.Drawables.FaceBG);
                } else {
                    faceBG = WatchUi.loadResource(Rez.Drawables.FaceBGW);
                }
                uiPrimaryColor = Graphics.COLOR_BLACK; 
                uiSecondaryColor = Graphics.COLOR_WHITE;
                uiTertiaryColor = Graphics.COLOR_WHITE;
            break;
            case 1:
                faceBG = WatchUi.loadResource(Rez.Drawables.FaceBG);
                uiPrimaryColor = Graphics.COLOR_WHITE;      
                uiSecondaryColor = Graphics.COLOR_BLACK;
                uiTertiaryColor = Graphics.COLOR_WHITE;  
            break;
            default:
            break;
        }
        
        // shift the mask around to prevent burn-in
		if (maskRandomizer == 0) {
			maskRandomizer = 1;
		} else {
			maskRandomizer = 0;
		}

        if (inLowPower && canBurnIn) {
            // do AOD display (<10% 3 minutes max)
			View.onUpdate(dc);

            // Draw the background bitmap
            dc.drawBitmap(0, 0, faceBG);

            // Draw the hash marks
            switch (hourMarkers) { 
            case true:
            break;
            case 0:
                drawHashMarks(dc);
            break;
            case 1:
                drawNumbersAndHashMarks(dc);
            break;
            case 2:
                drawNumbersOnlyMarks(dc);
            break;
            default:
                drawHashMarks(dc);
            break;
            }

            // Draw the hour. Convert it to minutes and compute the angle.
            hourHand = (((clockTime.hour % 12) * 60) + clockTime.min);
            hourHand = hourHand / (12 * 60.0);
            hourHand = hourHand * Math.PI * 2;
            drawHourHand(dc, hourHand);
            
            // Draw the minute
            minuteHand = (clockTime.min / 60.0) * Math.PI * 2;
            drawMinuteHand(dc, minuteHand);

            // Draw Seconds Hand Circle
            // Outer arbor
            dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(screen_width / 2, screen_height / 2, 9);
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(screen_width / 2, screen_height / 2, 8);

            // draw the mask at the new offset
            dc.drawBitmap(maskRandomizer, 0, aodMask);
        } else {
            // Draw the full experience
            // Call the parent onUpdate function to redraw the layout
            View.onUpdate(dc);
            // Draw the background bitmap
            dc.drawBitmap(0, 0, faceBG);

            // Draw the hash marks
            switch (hourMarkers) { 
            case true:
            break;
            case 0:
                drawHashMarks(dc);
            break;
            case 1:
                drawNumbersAndHashMarks(dc);
            break;
            case 2:
                drawNumbersOnlyMarks(dc);
            break;
            default:
                drawHashMarks(dc);
            break;
            }
            // Draw heart rate
            drawHeartRate(dc);
            // Draw Weather
            drawWeather(dc);
            // Draw Days of the Week
            drawDayOfWeek(dc);
            // Draw bluetooth line if connected
		    drawBluetooth(dc);
            // Draw Body Battery Arc
            drawBodyBatteryArc(dc);
            // Draw Battery Arc
            drawBatteryArc(dc);
            // Draw Steps Arc
            drawStepsArc(dc);
            // Draw Data Arc
            drawDataArc(dc);
            
            // Draw the hour. Convert it to minutes and compute the angle.
            hourHand = (((clockTime.hour % 12) * 60) + clockTime.min);
            hourHand = hourHand / (12 * 60.0);
            hourHand = hourHand * Math.PI * 2;
            drawHourHand(dc, hourHand);
            
            // Draw the minute
            minuteHand = (clockTime.min / 60.0) * Math.PI * 2;
            drawMinuteHand(dc, minuteHand);

            // Draw the second
            dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
            secondHand = (clockTime.sec / 60.0) * Math.PI * 2;
            //secondTail = secondHand - Math.PI;
            drawSecondHand(dc, secondHand);

            // Draw Seconds Hand Circle
            // Outer arbor
            dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(screen_width / 2, screen_height / 2, 9);
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(screen_width / 2, screen_height / 2, 8);
            // Inner arbor
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(screen_width / 2, screen_height / 2, 1);
            dc.setColor(accentColor,Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(screen_width / 2, screen_height / 2, 1);
        }        
        // for debugging layout
        // drawReferenceLines(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        // entering high power mode
		// switch to default view
		inLowPower = false;
		WatchUi.requestUpdate();  
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        // entering low power mode
		// perhaps render alternate version of watch face
		inLowPower = true;
		WatchUi.requestUpdate();  
    }

    // Draw the body battery arc
    // @param dc Device context
    private function drawBodyBatteryArc(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var font = Graphics.getVectorFont({:face=>[fontFace], :size=>arcLabelFontSize});
        var arcLength = 60;
        var arcWidth = 10;
        var arcDataAngle = 103;
        var arcLabelAngle = 177;
        var arcLabel = WatchUi.loadResource(Rez.Strings.BodyArcTitle);
        var justification = Graphics.TEXT_JUSTIFY_LEFT;
        var arcDataString = getBodyBatteryString(); 
        var arcData = getBodyBattery();

        // Set width of the arc line width
        dc.setPenWidth(arcWidth);
        // draw arc background color
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(width/2, height/2, (height/2.35) - (arcWidth/2.35), Graphics.ARC_CLOCKWISE, 165, 105);
        // draw arc labels
        dc.setColor(uiPrimaryColor, Graphics.COLOR_TRANSPARENT);
        dc.drawRadialText(width/2, height/2, font, arcDataString, justification, arcDataAngle, (height/2.425) - (arcWidth/2.425), Graphics.ARC_COUNTER_CLOCKWISE);
        dc.drawRadialText(width/2, height/2, font, arcLabel, justification, arcLabelAngle, (height/2.425) - (arcWidth/2.425), Graphics.ARC_COUNTER_CLOCKWISE);
        // display the current percentage of body battery remaining
        if(getBodyBattery() != null) {
            dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(width/2, height/2, (height/2.35) - (arcWidth/2.35), Graphics.ARC_CLOCKWISE, 165, 165-(arcLength * arcData/100));
        }
    }

    // Draw the device battery arc
    // @param dc Device context
    private function drawBatteryArc(dc) {
        var width= dc.getWidth();
        var height = dc.getHeight();
        var font = Graphics.getVectorFont({:face=>[fontFace], :size=>arcLabelFontSize});
        var arcLength = 60;
        var arcWidth = 10;
        var arcDataAngle = 13;
        var arcLabelAngle = 87;
        var arcLabel = WatchUi.loadResource(Rez.Strings.BatteryArcTitle);
        var justification = Graphics.TEXT_JUSTIFY_LEFT;
        var arcDataString = getBattery().toNumber().toString()+"%"; 
        var arcData = getBattery();

        // Set width of the arc line width
        dc.setPenWidth(arcWidth);
        // draw arc background color
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(width/2, height/2, (height/2.35) - (arcWidth/2.35), Graphics.ARC_CLOCKWISE, 75, 15);
        // draw arc labels
        dc.setColor(uiPrimaryColor, Graphics.COLOR_TRANSPARENT);
        dc.drawRadialText(width/2, height/2, font, arcDataString, justification, arcDataAngle, (height/2.425) - (arcWidth/2.425), Graphics.ARC_COUNTER_CLOCKWISE);
        dc.drawRadialText(width/2, height/2, font, arcLabel, justification, arcLabelAngle, (height/2.425) - (arcWidth/2.425), Graphics.ARC_COUNTER_CLOCKWISE);
        // display the current percentage of body battery remaining
        if(getBattery() != null) {
            dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(width/2, height/2, (height/2.35) - (arcWidth/2.35), Graphics.ARC_COUNTER_CLOCKWISE, 15, 15+(arcLength * arcData/100));
        }
    }

    // Draw the steps arc
    // @param dc Device context
    private function drawStepsArc(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var font = Graphics.getVectorFont({:face=>[fontFace], :size=>arcLabelFontSize});
        var arcLength = 60;
        var arcWidth = 10;
        var arcDataAngle = 256;
        var arcLabelAngle = 184;
        var arcLabel = WatchUi.loadResource(Rez.Strings.StepArcTitle);
        var ratio = arcLength*getStepsRatioThresholded();
        var justification = Graphics.TEXT_JUSTIFY_LEFT;
        var arcDataString = Math.round(getStepsRatioThresholded()*100).format("%.2i")+"%";

        // Set width of the arc line width
        dc.setPenWidth(arcWidth);
        // draw arc background color
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(width/2, height/2, height/2.35 - arcWidth / 2.35, Graphics.ARC_COUNTER_CLOCKWISE, 195, 255);
        // draw arc labels
        dc.setColor(uiPrimaryColor, Graphics.COLOR_TRANSPARENT);
        dc.drawRadialText(width/2, height/2, font, arcDataString, justification, arcDataAngle, (height/2.275) - (arcWidth/2.275), Graphics.ARC_CLOCKWISE);
        dc.drawRadialText(width/2, height/2, font, arcLabel, justification, arcLabelAngle, (height/2.275) - (arcWidth/2.275), Graphics.ARC_CLOCKWISE);
        // display the current percentage of body battery remaining
        if(getSteps() > 0 && getStepGoal() != null) {
            dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
            // don't let less than 1 otherwise drawing gets messed up
            if (ratio < 1) {
                ratio = 1;
            }
            dc.drawArc(width/2, height/2, height/2.35 - arcWidth / 2.35, Graphics.ARC_COUNTER_CLOCKWISE, 195, 195+ratio);
        }
    }

    // Draw the data arc - currently just displaying UTC
    // @param dc Device context
    private function drawDataArc(dc) {
        var width = dc.getWidth();
		var height = dc.getHeight();
        var font = Graphics.getVectorFont({:face=>[fontFace], :size=>dataFontSize});
        var arcWidth = 10;
        var arcDataAngle = 315;
        var justification = Graphics.TEXT_JUSTIFY_CENTER;
        var arcDataString;

        // Get UTC time
        var now = Time.now();
        var utcInfo = Gregorian.utcInfo(now, Time.FORMAT_SHORT);
        var utcTimeString = Lang.format("$1$:$2$", [utcInfo.hour, utcInfo.min.format("%02d")]);
        var localInfo = Gregorian.info(now, Time.FORMAT_SHORT);
        var localTimeString = Lang.format("$1$:$2$", [localInfo.hour, localInfo.min.format("%02d")]);
        if (displayUTC == 0) {
            arcDataString = utcTimeString+" UTC" +" / "+localTimeString;        
        } else {
            arcDataString = localTimeString;
        }

        // Draw Radial Time
        dc.setColor(uiPrimaryColor,Graphics.COLOR_TRANSPARENT);
        dc.drawRadialText(width/2, height/2, font, arcDataString, justification, arcDataAngle, (height/2.275) - (arcWidth/2.275), Graphics.ARC_CLOCKWISE);
    }

    // Draw an arc in the bottom right corner
    // @param dc Device context
    private function drawArc(dc) {
        var width= dc.getWidth();
        var height = dc.getHeight();
        var arcWidth = 15;
        dc.setPenWidth(arcWidth);
        dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(width/2, height/2, height/2.5 - arcWidth /2.5, Graphics.ARC_COUNTER_CLOCKWISE, width/2, height/2);
    }

    // Draw the current heart rate circle
    // @param dc Device context
    private function drawHeartRate(dc) {
        var font = Graphics.getVectorFont({:face=>[fontFace], :size=>circleFontSize});
        var dataString;
        var justification = Graphics.TEXT_JUSTIFY_CENTER;
        var xPos = (screen_width/2)-(screen_width/4)+screen_width*0.0288;

        // draw left circle
        dc.setPenWidth(3);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(xPos, screen_height/2, screen_width*0.1225);
        dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_DK_GRAY);
        dc.fillCircle(xPos, screen_height/2, screen_width*0.1201); 
        // draw heart
        dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(xPos, (screen_height/2)-(screen_height*0.0817), customIcons, "m", justification);
        
        // insert current HR data
        dc.setColor(uiTertiaryColor,Graphics.COLOR_TRANSPARENT);

        if (getHeartRateString() != "") {
            dataString = getHeartRateString();
        } else {
            dataString = "--";
        }
        dc.drawText((screen_width/2)-(screen_width/4)+screen_height*0.024, (screen_height/2)+screen_height*0.0072, font, dataString, justification);
    }

    // Draw the current "feels like" temperature circle in both C and F
    // @param dc Device context
    private function drawWeather(dc) {
        var font = Graphics.getVectorFont({:face=>[fontFace], :size=>circleFontSize});
        var currentConditions = Weather.getCurrentConditions();
        var feelsLikeTemp;
        var feelsLikeC;
        var feelsLikeF;
        var justification = Graphics.TEXT_JUSTIFY_CENTER;
        var centerX = screen_width/2;
        var xPos = (centerX)+(screen_width/4)-screen_width*0.0288;
        var yPosCondition = (screen_height/4)-screen_height*0.024;

        // draw right circle
        dc.setPenWidth(3);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(xPos, centerX, screen_width*0.1225);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_DK_GRAY);
        dc.fillCircle(xPos, centerX, screen_width*0.1201);

        // Check to see if weather exists otherwise display null temps
        if (currentConditions != null) {
            feelsLikeTemp = currentConditions.feelsLikeTemperature;
            feelsLikeC = feelsLikeTemp.format("%.2i")+"°C";
            feelsLikeF = (feelsLikeTemp*9/5+32).format("%.2i")+"°F";
            
            if (feelsLikeTemp > 25) {
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            } else if (feelsLikeTemp < 10) {
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            }
            // draw divider
            dc.setPenWidth(2);
            dc.drawLine(xPos-(screen_width*0.0576), (screen_height/2), xPos+(screen_width*0.0576),(screen_height/2));
        } else {
            feelsLikeC = "--°C";
            feelsLikeF = "--°F";
        }
        
        // insert the data
        dc.setColor(uiTertiaryColor,Graphics.COLOR_TRANSPARENT); 
        // font offset should take into account the font-height
        dc.drawText(xPos, (centerX)+(screen_height*0.012), font, feelsLikeC, justification);
        dc.drawText(xPos, (centerX)-(circleFontSize+(screen_height*0.0025)), font, feelsLikeF, justification);

        dc.setColor(uiPrimaryColor,Graphics.COLOR_TRANSPARENT);
        switch (currentConditions.condition) {
            case true:
                
            break;
            case 0:
                // clear
                dc.drawText(centerX, yPosCondition, weatherIcons, "y", justification);
            break;
            case 1:
                // partly cloudy
                dc.drawText(centerX, yPosCondition, weatherIcons, "x", justification);
            break;
            case 2:
                // mostly cloudy
                dc.drawText(centerX, yPosCondition, weatherIcons, "u", justification);
            break;
            case 3:
                // rain
                dc.drawText(centerX, yPosCondition, weatherIcons, "a", justification);
            break;
            case 4:
                // snow
                dc.drawText(centerX, yPosCondition, weatherIcons, "k", justification);
            break;
            case 5:
                // windy
                dc.drawText(centerX, yPosCondition, weatherIcons, "t", justification);
            break;
            case 6:
                // thunderstorms
                dc.drawText(centerX, yPosCondition, weatherIcons, "i", justification);
            break;
            case 7:
                // wintry mix
                dc.drawText(centerX, yPosCondition, weatherIcons, "j", justification);
            break;
            case 8:
                // fog
                dc.drawText(centerX, yPosCondition, weatherIcons, "E", justification);
            break;
            case 9:
                // hazy
                dc.drawText(centerX, yPosCondition, weatherIcons, "z", justification);
            break;
            case 10:
                // hail
                dc.drawText(centerX, yPosCondition, weatherIcons, "D", justification);
            break;
            case 11:
                // scattered showers
                dc.drawText(centerX, yPosCondition, weatherIcons, "d", justification);
            break;
            case 12:
                // scattered thunderstorms
                dc.drawText(centerX, yPosCondition, weatherIcons, "i", justification);
            break;
            case 13:
                // unknown precipitation
                dc.drawText(centerX, yPosCondition, weatherIcons, "h", justification);
            break;
            case 14:
                // light rain
                dc.drawText(centerX, yPosCondition, weatherIcons, "g", justification);
            break;
            case 15:
                // heavy rain
                dc.drawText(centerX, yPosCondition, weatherIcons, "a", justification);
            break;
            case 16:
                // light snow
                dc.drawText(centerX, yPosCondition, weatherIcons, "k", justification);
            break;
            case 17:
                // heavy snow
                dc.drawText(centerX, yPosCondition, weatherIcons, "l", justification);
            break;
            case 18:
                // light rain snow
                dc.drawText(centerX, yPosCondition, weatherIcons, "b", justification);
            break;
            case 19:
                // heavy rain snow
                dc.drawText(centerX, yPosCondition, weatherIcons, "b", justification);
            break;
            case 20:
                // cloudy
                dc.drawText(centerX, yPosCondition, weatherIcons, "u", justification);
            break;
            case 21:
                // rain snow
                dc.drawText(centerX, yPosCondition, weatherIcons, "b", justification);
            break;
            case 22:
                // partly clear
                dc.drawText(centerX, yPosCondition, weatherIcons, "x", justification);
            break;
            case 23:
                // mostly clear
                dc.drawText(centerX, yPosCondition, weatherIcons, "y", justification);
            break;
            case 24:
                // light showers
                dc.drawText(centerX, yPosCondition, weatherIcons, "d", justification);
            break;
            case 25:
                // showers
                dc.drawText(centerX, yPosCondition, weatherIcons, "d", justification);
            break;
            case 26:
                // heavy showers
                dc.drawText(centerX, yPosCondition, weatherIcons, "a", justification);
            break;
            case 27:
                // chance of showers
                dc.drawText(centerX, yPosCondition, weatherIcons, "h", justification);
            break;
            case 28:
                // chance of thunderstorms
                dc.drawText(centerX, yPosCondition, weatherIcons, "f", justification);
            break;
            case 29:
                // mist
                dc.drawText(centerX, yPosCondition, weatherIcons, "z", justification);
            break;
            case 30:
                // dust
                dc.drawText(centerX, yPosCondition, weatherIcons, "z", justification);
            break;
            case 31:
                // drizzle
                dc.drawText(centerX, yPosCondition, weatherIcons, "g", justification);
            break;
            case 32:
                // tornado
                dc.drawText(centerX, yPosCondition, weatherIcons, "r", justification);
            break;
            case 33:
                // smoke
                dc.drawText(centerX, yPosCondition, weatherIcons, "n", justification);
            break;
            case 34:
                // ice
                dc.drawText(centerX, yPosCondition, weatherIcons, "j", justification);
            break;
            case 35:
                // sand
                dc.drawText(centerX, yPosCondition, weatherIcons, "p", justification);
            break;
            case 36:
                // squall
                dc.drawText(centerX, yPosCondition, weatherIcons, "q", justification);
            break;
            case 37:
                // sandstorm
                dc.drawText(centerX, yPosCondition, weatherIcons, "p", justification);
            break;
            case 38:
                // volcanic ash
                dc.drawText(centerX, yPosCondition, weatherIcons, "m", justification);
            break;
            case 39:
                // haze
                dc.drawText(centerX, yPosCondition, weatherIcons, "z", justification);
            break;
            case 40:
                // fair
                dc.drawText(centerX, yPosCondition, weatherIcons, "y", justification);
            break;
            case 41:
                // hurricane
                dc.drawText(centerX, yPosCondition, weatherIcons, "q", justification);
            break;
            case 42:
                // tropical storm
                dc.drawText(centerX, yPosCondition, weatherIcons, "qc", justification);
            break;
            case 43:
                // chance of snow
                dc.drawText(centerX, yPosCondition, weatherIcons, "k", justification);
            break;
            case 44:
                // chance of rain snow
                dc.drawText(centerX, yPosCondition, weatherIcons, "b", justification);
            break;
            case 45:
                // cloudy chance of rain
                dc.drawText(centerX, yPosCondition, weatherIcons, "d", justification);
            break;
            case 46:
                // cloudy chance of snow
                dc.drawText(centerX, yPosCondition, weatherIcons, "k", justification);
            break;
            case 47:
                // cloudy chance of rain snow
                dc.drawText(centerX, yPosCondition, weatherIcons, "b", justification);
            break;
            case 48:
                // flurries
                dc.drawText(centerX, yPosCondition, weatherIcons, "jl", justification);
            break;
            case 49:
                // freezing rain
                dc.drawText(centerX, yPosCondition, weatherIcons, "ja", justification);
            break;
            case 50:
                // sleet
                dc.drawText(centerX, yPosCondition, weatherIcons, "e", justification);
            break;
            case 51:
                // ice snow
                dc.drawText(centerX, yPosCondition, weatherIcons, "jk", justification);
            break;
            case 52:
                // thin clouds
                dc.drawText(centerX, yPosCondition, weatherIcons, "x", justification);
            break;
            case 53:
                // unknown
                dc.drawText(centerX, yPosCondition, weatherIcons, "G", justification);
            break;
            default:

            break;
        } 
    }

    // Draw the current day of the week arc
    // @param dc Device context
    private function drawDayOfWeek(dc) {
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var todayM = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dayOfWeek = Lang.format("$1$", [today.day_of_week]);
        var dateString = Lang.format("$1$ $2$", [
                todayM.month,
                todayM.day,
            ]
        ).toUpper();
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var font = Graphics.getVectorFont({:face=>[fontFace], :size=>dayOfWeekFontSize});
        var justification = Graphics.TEXT_JUSTIFY_CENTER;
        var yPos = (screen_height)-(screen_height/3.5);
        var coords;
        var radius = centerY * 0.63;
        var radiusOffset = radius + screen_height*0.021634;
        var dotSize = screen_height*0.03605769;

        // draw centered circle
        dc.setPenWidth(3);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, yPos, screen_width*0.1225);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_DK_GRAY);
        dc.fillCircle(centerX, yPos, screen_width*0.1201);
        // draw calendar
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, yPos-screen_height*0.0889, customIcons, "W", justification);
        // Draw the date
        dc.setColor(uiTertiaryColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, yPos+screen_height*0.0048, font, dateString, justification);
        
        // Draw the days of the week       
        dc.setColor(uiPrimaryColor, Graphics.COLOR_TRANSPARENT);
        coords = getCoordinates(210,radius);
        dc.drawAngledText(centerX+coords[0],centerY+coords[1], font, WatchUi.loadResource(Rez.Strings.Sunday), justification, 60); 
        coords = getCoordinates(230,radius);
        dc.drawAngledText(centerX+coords[0],centerY+coords[1], font, WatchUi.loadResource(Rez.Strings.Monday), justification, 40);
        coords = getCoordinates(250,radius);
        dc.drawAngledText(centerX+coords[0],centerY+coords[1], font, WatchUi.loadResource(Rez.Strings.Tuesday), justification, 20);
        coords = getCoordinates(270,radius);
        dc.drawAngledText(centerX+coords[0],centerY+coords[1], font, WatchUi.loadResource(Rez.Strings.Wednesday), justification, 0);
        coords = getCoordinates(290,radius);
        dc.drawAngledText(centerX+coords[0],centerY+coords[1], font, WatchUi.loadResource(Rez.Strings.Thursday), justification, -20);
        coords = getCoordinates(310,radius);
        dc.drawAngledText(centerX+coords[0],centerY+coords[1], font, WatchUi.loadResource(Rez.Strings.Friday), justification, -40);
        coords = getCoordinates(330,radius);
        dc.drawAngledText(centerX+coords[0],centerY+coords[1], font, WatchUi.loadResource(Rez.Strings.Saturday), justification, -60);
        
        // Highlight the actual day
        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
        switch (dayOfWeek.toNumber()) { // 
            case true:
                
            break;
            case 1:
                coords = getCoordinates(210,radiusOffset);
                dc.fillCircle(centerX+coords[0],centerY+coords[1], dotSize);
                coords = getCoordinates(210,radius);
                dc.setColor(uiSecondaryColor, Graphics.COLOR_TRANSPARENT);
                dc.drawAngledText(centerX+coords[0],centerY+coords[1], font, WatchUi.loadResource(Rez.Strings.Sunday), justification, 60);
            break;
            case 2:
                coords = getCoordinates(230,radiusOffset);
                dc.fillCircle(centerX+coords[0],centerY+coords[1], dotSize);
                coords = getCoordinates(230,radius);
                dc.setColor(uiSecondaryColor, Graphics.COLOR_TRANSPARENT);
                dc.drawAngledText(centerX+coords[0],centerY+coords[1], font, WatchUi.loadResource(Rez.Strings.Monday), justification, 40);
            break;
            case 3:
                coords = getCoordinates(250,radiusOffset);
                dc.fillCircle(centerX+coords[0],centerY+coords[1], dotSize);
                coords = getCoordinates(250,radius);
                dc.setColor(uiSecondaryColor, Graphics.COLOR_TRANSPARENT);
                dc.drawAngledText(centerX+coords[0],centerY+coords[1], font, WatchUi.loadResource(Rez.Strings.Tuesday), justification, 20);
            break;
            case 4:
                coords = getCoordinates(270,radiusOffset);
                dc.fillCircle(centerX+coords[0],centerY+coords[1], dotSize);
                coords = getCoordinates(270,radius);
                dc.setColor(uiSecondaryColor, Graphics.COLOR_TRANSPARENT);
                dc.drawAngledText(centerX+coords[0],centerY+coords[1], font, WatchUi.loadResource(Rez.Strings.Wednesday), justification, 0);
            break;
            case 5:
                coords = getCoordinates(290,radiusOffset);
                dc.fillCircle(centerX+coords[0],centerY+coords[1], dotSize);
                coords = getCoordinates(290,radius);
                dc.setColor(uiSecondaryColor, Graphics.COLOR_TRANSPARENT);
                dc.drawAngledText(centerX+coords[0],centerY+coords[1], font, WatchUi.loadResource(Rez.Strings.Thursday), justification, -20);
            break;
            case 6:
                coords = getCoordinates(310,radiusOffset);
                dc.fillCircle(centerX+coords[0],centerY+coords[1], dotSize);
                coords = getCoordinates(310,radius);
                dc.setColor(uiSecondaryColor, Graphics.COLOR_TRANSPARENT);
                dc.drawAngledText(centerX+coords[0],centerY+coords[1], font, WatchUi.loadResource(Rez.Strings.Friday), justification, -40);
            break;
            case 7:
                coords = getCoordinates(330,radiusOffset);
                dc.fillCircle(centerX+coords[0],centerY+coords[1], dotSize);
                coords = getCoordinates(330,radius);
                dc.setColor(uiSecondaryColor, Graphics.COLOR_TRANSPARENT);
                dc.drawAngledText(centerX+coords[0],centerY+coords[1], font, WatchUi.loadResource(Rez.Strings.Saturday), justification, -60);
            break;
            default:
            // if all else fails
            break;
        }
    }

    // Draw a watch hand
	// @param dc Device Context to Draw
	// @param angle Angle of the watch hand
	// @param coords Polygon coordinates of the hand
	private function drawHand(dc, angle, coords) {
		var result = new [coords.size()];
        var centerX = screen_width / 2;
        var centerY = screen_height / 2;
        var cos = Math.cos(angle + Math.PI);
        var sin = Math.sin(angle + Math.PI);

        // Transform the coordinates
        for (var i = 0; i < coords.size(); i += 1) {
            var a = coords[i][0];
            var b = coords[i][1];

            var x = (a * cos) - (b * sin);
            var y = (a * sin) + (b * cos);
            //var x = (coords[i][0] * cos) - (coords[i][1] * sin);
            //var y = (coords[i][0] * sin) + (coords[i][1] * cos);
            result[i] = [centerX + x, centerY + y];
        }
        
        // Draw the polygon
        dc.fillPolygon(result);
        //dc.fillPolygon(result);
	}

    // Draw the hour hand
	// @param dc Device Context to Draw
	// @param angle Angle of the watch hand
	private function drawHourHand(dc, angle) {	
		// Define hand shape using coordinates
		var length = (screen_height/2)*.528; 
		var width = screen_height*0.0216;
		// Define shape of the hand
		var coords_outer;
        var coords_inner;
        // Outer pointer
		coords_outer = [[-width ,0],[width ,0],[width ,(length - 5)],[0,length],[-width ,(length-5)]];
		// Inner accent
		coords_inner = [[-(width - 2),55],[(width - 2),55],[(width - 2),(length - 11)],[-(width - 2),(length - 11)]];

		// Draw these with their color and orientation
        dc.setColor(uiPrimaryColor, 0x80);
		drawHand(dc, angle, coords_outer);
		dc.setColor(uiSecondaryColor, 0x80);
		drawHand(dc, angle, coords_inner);
	}

	// Draw the minute hand
	// @param dc Device Context to Draw
	// @param angle Angle of the watch hand
	private function drawMinuteHand(dc, angle) {
		// Define hand shape using coordinates
		var length = (screen_height/2)*0.889;
		var width = screen_height*0.0216;
		// Define shape of the hand
		// Outer pointer
		var coords_outer = [[-width ,0],[width ,0],[width ,(length - 5)],[0,length],[-width ,(length-5)]];
		// Inner accent
		var coords_inner = [[-(width - 2),55],[(width - 2),55],[(width - 2),(length - 11)],[-(width - 2),(length - 11)]];

		// Draw hands with their color and orientation
        dc.setColor(uiPrimaryColor, 0x80);
		drawHand(dc, angle, coords_outer);
		dc.setColor(uiSecondaryColor, 0x80);
		drawHand(dc, angle, coords_inner);
	}

    // Draw the second hand on the watch
	// @param dc Device Context to Draw
	// @param angle Angle of the watch hand
	private function drawSecondHand(dc, angle) {
		// Define hand shape using coordinates
		var length = screen_height - 10;
		var width = 1;
        var lengthTail = screen_height*0.08413;
        var widthTail = 5;
		// Define hand shape
		var coords = [[0,0],[width,0],[0,length],[-width,0]];
        var coordsTail = [[0,0],[0,0],[widthTail,-lengthTail],[-widthTail,-lengthTail]];
                
		// Draw the hand with it's appropriate color
		dc.setColor(accentColor, 0x80);
		drawHand(dc, angle, coords);
        drawHand(dc, angle, coordsTail);      
	}

    private function drawBluetooth(dc) {
		// only draw if device is connected
		dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
		if(System.getDeviceSettings().phoneConnected) {
			// Symbol parameters
			var symbolHeight = screen_height*0.03846;
            var centerX = (screen_width / 2);
			var centerY = screen_height - symbolHeight*2; 
			var xoffset = screen_width*0.012019;
			dc.setPenWidth(1.8);
			// Draw the symbol
			dc.drawLine(centerX, centerY - (symbolHeight/2),centerX,centerY+(symbolHeight/2));
			dc.drawLine(centerX, centerY - (symbolHeight/2),centerX+xoffset,centerY - (symbolHeight/4));
			dc.drawLine(centerX+xoffset,centerY - (symbolHeight/4),centerX-xoffset,centerY + (symbolHeight/4));
			dc.drawLine(centerX, centerY + (symbolHeight/2),centerX+xoffset,centerY + (symbolHeight/4));
			dc.drawLine(centerX+xoffset,centerY + (symbolHeight/4),centerX-xoffset,centerY - (symbolHeight/4));
		}
	}

    // Draw the hash mark symbols on the watch
    // @param dc Device context
    private function drawHashMarks(dc) { 	
        // Draw hashmarks differently depending on screen geometry
        if (System.SCREEN_SHAPE_ROUND == screenShape) {
            var sX, sY;
            var eX, eY;
            var outerRad = screen_width / 2;
            var innerRad = outerRad - 10;
            // Loop through each minute and draw tick marks
            for (var i = 0; i <= 59; i += 1) {
            	var angle = i * Math.PI / 30;
            	
            	// thicker lines at 5 min intervals
            	if ((i % 5) == 0) {
                    dc.setPenWidth(3);
                    dc.setColor(uiPrimaryColor, Graphics.COLOR_TRANSPARENT);
                }
                else {
                    dc.setPenWidth(1);
                    dc.setColor(uiHashColor, Graphics.COLOR_TRANSPARENT);            
                }
                // longer lines at intermediate 5 min marks
                if ((i % 5) == 0 && !((i % 15) == 0)) {               		
            		sY = (innerRad-10) * Math.sin(angle);
                	eY = outerRad * Math.sin(angle);
                	sX = (innerRad-10) * Math.cos(angle);
                	eX = outerRad * Math.cos(angle);
                }
                else {
                	sY = innerRad * Math.sin(angle);
                	eY = outerRad * Math.sin(angle);
                	sX = innerRad * Math.cos(angle);
                	eX = outerRad * Math.cos(angle);
            	}
                sX += outerRad; sY += outerRad;
                eX += outerRad; eY += outerRad;
                dc.drawLine(sX, sY, eX, eY);
            }
        } else {
            var coords = [0, screen_width / 4, (3 * screen_width) / 4, screen_width];
            for (var i = 0; i < coords.size(); i += 1) {
                var dx = ((screen_width / 2.0) - coords[i]) / (screen_height / 2.0);
                var upperX = coords[i] + (dx * 10);
                // Draw the upper hash marks
                dc.fillPolygon([[coords[i] - 1, 2], [upperX - 1, 12], [upperX + 1, 12], [coords[i] + 1, 2]]);
                // Draw the lower hash marks
                dc.fillPolygon([[coords[i] - 1, screen_height-2], [upperX - 1, screen_height - 12], [upperX + 1, screen_height - 12], [coords[i] + 1, screen_height - 2]]);
            }
        }
    }

    // Draw primary numbers and the hash mark symbols on the watch
    // @param dc Device context
    private function drawNumbersAndHashMarks(dc) {
       	dc.setColor(uiHashColor, Graphics.COLOR_TRANSPARENT);
    
        // Draw hashmarks differently depending on screen geometry
        if (System.SCREEN_SHAPE_ROUND == screenShape) {
            var sX, sY;
            var eX, eY;
            var outerRad = screen_width / 2;
            var innerRad = outerRad - 10;
            // Loop through each minute and draw tick marks
            for (var i = 0; i <= 59; i += 1) {
            	var angle = i * Math.PI / 30;
            	
                dc.setPenWidth(1);

                // lines at intermediate 5 min marks except for the main numbers
                if ((i == 0) || ((i % 5) == 0 && !((i % 15) == 0)) || (i == 30) || (i == 15) || (i == 45)) {               		
                    sX = 0;
                    sY = 0;
                    eX = 0;
                    eY = 0;
                }
                else {
                	sY = innerRad * Math.sin(angle);
                	eY = outerRad * Math.sin(angle);
                	sX = innerRad * Math.cos(angle);
                	eX = outerRad * Math.cos(angle);
            	}

                sX += outerRad; sY += outerRad;
                eX += outerRad; eY += outerRad;
                dc.drawLine(sX, sY, eX, eY);
            }

            var centerX = dc.getWidth() / 2;
            var centerY = dc.getHeight() / 2 - hourFontSize/2 + 2;
            var radius = dc.getHeight()/2 - hourFontSize/2.5;
            var font = Graphics.getVectorFont({:face=>[fontFace], :size=>hourFontSize});
            var justification = Graphics.TEXT_JUSTIFY_CENTER;
            dc.setColor(uiPrimaryColor, Graphics.COLOR_TRANSPARENT);

            for (var j = 1; j <= 12; j++) {
                var angle = 360 / 12 * j + -90;
                var radians = angle * Math.PI / 180;

                var x = centerX + radius * Math.cos(radians);
                var y = centerY + radius * Math.sin(radians);

                dc.drawText(x,y, font, j.toString(), justification);
            }

        } else {
            var coords = [0, screen_width / 4, (3 * screen_width) / 4, screen_width];
            for (var i = 0; i < coords.size(); i += 1) {
                var dx = ((screen_width / 2.0) - coords[i]) / (screen_height / 2.0);
                var upperX = coords[i] + (dx * 10);
                // Draw the upper hash marks
                dc.fillPolygon([[coords[i] - 1, 2], [upperX - 1, 12], [upperX + 1, 12], [coords[i] + 1, 2]]);
                // Draw the lower hash marks
                dc.fillPolygon([[coords[i] - 1, screen_height-2], [upperX - 1, screen_height - 12], [upperX + 1, screen_height - 12], [coords[i] + 1, screen_height - 2]]);
            }
        }
    }

    // Draw primary numbers on the watch
    // @param dc Device context
    private function drawNumbersOnlyMarks(dc) {
       	dc.setColor(uiPrimaryColor, Graphics.COLOR_TRANSPARENT);
    
        // Draw hashmarks differently depending on screen geometry
        if (System.SCREEN_SHAPE_ROUND == screenShape) {
            var centerX = dc.getWidth() / 2;
            var centerY = dc.getHeight() / 2 - hourFontSize/2 +2;
            var radius = dc.getHeight()/2 - hourFontSize/2.5;
            var font = Graphics.getVectorFont({:face=>[fontFace], :size=>hourFontSize});
            var justification = Graphics.TEXT_JUSTIFY_CENTER;

            for (var j = 1; j <= 12; j++) {
                var angle = 360 / 12 * j + -90;
                var radians = angle * Math.PI / 180;

                var x = centerX + radius * Math.cos(radians);
                var y = centerY + radius * Math.sin(radians);

                dc.drawText(x,y, font, j.toString(), justification);
            }

        }
    }

    private function getDate() as String {
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateString = Lang.format("$1$ $2$ $3$", [
                today.day_of_week,
                today.day,
                today.month,
            ]
        );
        return dateString;
    }

    private function getHeartRate() as Number  {
        var heartrateIterator = Toybox.ActivityMonitor.getHeartRateHistory(1, true);
        return heartrateIterator.next().heartRate;
    }

    private function getHeartRateString() as String  {
        return getHeartRate().format("%d");
    }

    private function getBodyBatteryIterator() {
        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory)) {
            return Toybox.SensorHistory.getBodyBatteryHistory({:period=>1, :order=> Toybox.SensorHistory.ORDER_NEWEST_FIRST});
        }
        return null;
    }

    private function getBodyBattery() as Lang.Number or Null {
        var bbIterator = getBodyBatteryIterator();
        var sample = bbIterator.next();

        while (sample != null) {
            if(sample.data != null) {
                return sample.data;
            }
            sample = bbIterator.next();
        }

        return null;
    }

    private function getBodyBatteryString() as String {
        var bodyBattery = getBodyBattery();

        if (bodyBattery == null) {
            return "-";
        }

        return bodyBattery.format("%d") + "%";
    }

    private function getSteps() as Lang.Number or Null {
        return Toybox.ActivityMonitor.getInfo().steps;
    }

    private function getStepsString() as String {
        var steps = getSteps();

        if(steps == null) {
            return "-";
        }

        return getSteps().format("%d");
    }

    private function getStepGoal() as Lang.Number or Null {
        return Toybox.ActivityMonitor.getInfo().stepGoal;
    }

    private function getStepsRatioThresholded() as Lang.Float or Null {
        var stepGoal = getStepGoal(); 
        var steps = getSteps();

        if(steps ==null || stepGoal == null) {
            return null;
        }

        if(steps > stepGoal) {
            steps = stepGoal;
        }

        return 1.0 * steps / stepGoal;
    }

    private function getBattery() as Float  {
    	return Toybox.System.getSystemStats().battery;		
    }

    private function getBatteryString() as String  {
        return getBattery().format("%d")+"%"; 
    }

    private function getCoordinates(angleInDegrees, radius) as Array {
        var angleInRadians = angleInDegrees * (Math.PI / 180);
        var x = radius * Math.cos(angleInRadians);
        var y = radius * Math.sin(angleInRadians);

        return [x,y];
    }

    private function drawReferenceLines(dc as Dc) as Void {
        var width= dc.getWidth();
        var height = dc.getHeight();

        dc.setPenWidth(1);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(0.2*width, 0.1*height, 0.6*width,  0.8*height );
        dc.drawRectangle(0.15*width, 0.15*height, 0.7*width,  0.7*height );
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(0.1*width, 0.2*height, 0.8*width,  0.6*height );
        dc.drawRectangle(0.05*width, 0.3*height, 0.9*width,  0.4*height );

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, 0.25*height, width,  1 );
        dc.fillRectangle(0, 0.5*height, width,  1 );
        dc.fillRectangle(0, 0.75*height, width,  1);
        dc.fillRectangle(0.25*width, 0 , 1, height );

        dc.fillRectangle(0.1*width, 0, 1,  height );
        dc.fillRectangle(0.9*width, 0, 1,  height );

        dc.fillRectangle(0.5*width, 0, 1,  height );
        dc.fillRectangle(0.75*width,0, 1,  height);

        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0.3333*width, 0 , 1, height );
        dc.fillRectangle(0.6666*width, 0 , 1, height );
    }
}

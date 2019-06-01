;;;; By BingLi224
;;;; 19:05 THA 14/08/2009
;;;
;;;; Draw Dictionary of Electric Symbols
;;;

( setq
	lstSymbols '(

		;;; ELECTRICAL
		( "ELECTRICAL" )
		( "Chandelier" "Chandelier" 0 0 1 )
		( "Chandelier.circle" "Chandelier" 0 0 2 )
		( "downlight" "Downlight" 0 0 1 )
		( "downlight.rect" "Downlight" 0 0 1 )
		( "downlight.small.sphere" "Downlight" 0 0 1 )
		( "HalogenLamp" "Halogen Lamp" 0 0 1 )
		( "HangingLamp" "Hanging Lamp" 0 0 2 )
		( "HangingLamp.rect" "Hanging Lamp" 0 0 1 )
		( "NightLamp" "Night Lamp" 0 0 1 )
		( "PhiliniaLamp" "Philinia Lamp" 0 0 1 )
		( "Philinia.small.sphere" "Philinia Light" 0 0 1 )
		( "PictureLamp" "Picture Lamp" 0 0 1 )
		( "Spotlight" "Spot Light" 0 0 1 )
		( "WallLamp" "Wall Lamp" 0 -150 2 )
		( "TubeLight" "Tube Light" 0 0 1 )
		( "Switch" "Switch" 0 0 1 )
		( "Dimmer" "Dimmer" 0 100 1 )
		( "DoorBell" "Door Bell" 0 100 1 )
		
		( "Receptacle" "Receptacle" 0 0 1 )
		
		( "AirCon" "Air Conditioner" 0 0 1 )
		( "Fan" "Fan" 0 0 2 )

		( "ControlBoard" "Control Board" 0 0 1 )
		( "MasterSwitch" "Master Switch" 0 100 1 )
		( "SwitchBoard" "Switch Board" 0 0 1 )
		( "MainSwitchBoard" "Main Switch Board" 0 0 1 )
		( "MDB" "M.D.B." 0 0 2 )
		;( "MainSwitch" "Main Switch" 0 0 )

		;( "LC" "L.C." 0 0 )
		;( "LCC" "L.C.C." 0 0 )

		;( "Ohm" "Ohm" 0 0 )

		;;; FIRE ALARM SYSTEM
		( "FIRE ALARM SYSTEM" )
		( "FireAlarm" "Fire Alarm Control Board" 0 0 1 )
		( "bell" "Fire Alarm Bell" 0 100 2 )
		( "manualswitch" "Manual Switch" 0 100 1 )
		( "Heat" "Heat" 0 0 1 )

		( "ExitLight" "Exit Light" 0 0 1 )

		( "EmergencyLight" "Emergency Light" 0 0 1 )
		( "EmergencyLight2" "Emergency Light" 0 0 1 )

		;;; TV & TELEPHONE
		( "TV & TELEPHONE" )
		( "tvoutlet" "T.V. Outlet" 0 0 1 )

		( "cctv" "C.C.T.V." -100 0 1 90 )

		( "Telephone" "Telephone Outlet" 0 -100 1 )

		( "TC" "T.C." 0 0 1 )
		
		;;; NETWORK
		( "NETWORK" )
		( "WirelessRouter" "Wireless Router" 0 100 1 )
		( "Modem" "Modem" 0 100 )
	)

	;;; base x-position
	offsetX 0

	;;; base y-position
	offsetY 0
)

( defun C:ds ( / currentSymbol basePoint x y defaultW defaultH rot )

	;;; get the top-left point to draw
	( setq	basePoint ( getpoint "\nSelect the top-left point of the list: " )
		x 0
		y 0
		offsetX ( car basePoint )
		offsetY ( cadr basePoint )
		scaleX	1
		scaleY	1
		defaultW 3000
		defaultH 300

		;;; save the current OSMode
		currOSMODE ( getvar "osmode" )
	)

	;;; turn off OSMode to draw at positions precisely
	( setvar "osmode" 0 )

	;;; draw the top horizontal border
	( command "line"
		( strcat ( rtos ( + offsetX x -400 ) ) "," ( rtos ( + offsetY y ) ) )
		( strcat "@" ( rtos defaultW ) ",0" )
	"" )

	;;; draw all symbols
	( foreach currentSymbol lstSymbols ( progn
		;;; get the height of current symbol
		( setq h ( * defaultH
			( if ( null ( setq h ( nth 4 currentSymbol ) ) )
				1
				( if ( numberp h )
					h
					( atoi h )
				)
			)
		) )

		( if ( null ( cdr currentSymbol ) )
			;;; draw symbol GROUP NAME
			( command "mtext"
				;;; 1st corner
				( strcat ( rtos ( + offsetX x ) ) "," ( rtos ( + offsetY y ) ) )
				
				"h" "120"	;;; height of font
				"s" "Electric"	;;; style
				"j" "ml"	;;; justify - middle left
				;;; opposite corner
				( strcat "@0,-" ( rtos h ) )
				( strcase ( car currentSymbol ) )	;;; text of group name
			"" ) ;;; command: draw mtext of symbol group name
		;;; else; draw SYMBOL
			( progn
				;;; draw the line between the symbol
				( command "line"
					( strcat
						( rtos ( + offsetX x 400 ) ) ","
						( rtos ( + offsetY y ) ) )
					( strcat "@0,-" ( rtos h ) )
				"" )
				
			  	;;; draw the symbol
				( command "insert"
					( car currentSymbol )
					;"b" ( strcat ( rtos ( car basePoint ) ) "," ( rtos ( cadr basePoint ) ) )
					( strcat
						( rtos ( + offsetX x ( caddr currentSymbol ) ) ) ","
						( rtos ( + offsetY y ( cadddr currentSymbol ) ( * -0.5 h ) ) ) )
					scaleX	;;; x-scale
					scaleY	;;; y-scale
					;;; rotation
					( if ( null ( setq rot ( nth 5 currentSymbol ) ) )
						"0"	;;; default rotation
						( if ( numberp rot )
							( rtos rot 2 4 ) ;;; convert from string into decimal
							rot
						)
					)
				) ;;; command: draw symbol

				;;; draw the info
				( command "mtext"
					;;; 1st corner
					( strcat ( rtos ( + offsetX x 600 ) ) "," ( rtos ( + offsetY y ) ) )
					
					"h" "120"	;;; height of font
					"s" "Electric"	;;; style
					"j" "ml"	;;; justify - middle left
					;;; opposite corner
					;( strcat ( rtos ( + offsetX x ( caddr currentSymbol ) 500 ) ) "," ( rtos ( + offsetY y ( cadddr currentSymbol ) ( * -1 h ) ) ) )
					( strcat "@0,-" ( rtos h ) )
					( strcase ( cadr currentSymbol ) )	;;; text
				"" ) ;;; command: draw mtext of symbol info
			)
		) ;;; if: draw group name OR symbol

		;;; move to the next line in the table
		( setq y ( - y h ) )

		;;; draw the HR between the symbols
		( command "line"
			( strcat ( rtos ( + -400 offsetX x ) ) "," ( rtos ( + offsetY y ) ) )
			( strcat "@" ( rtos defaultW ) ",0" )
		"" )
	) ) ;;; foreach: symbols

	;;; restore the OSMODE
	( setvar "osmode" currOSMODE )
) ;;; defun: draw list of symbols

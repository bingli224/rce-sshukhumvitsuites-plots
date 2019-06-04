
;;; By BingLi224
;;; 06:33 THA 30/07/2009
;;;
;;; MODIFIED:
;;; 04:29 THA 31/07/2009
;;; 12:18 THA 06/08/2009
;;; 17:20 THA 10/08/2009
;;; 16:55 THA 27/08/2009
;;; 16:20 THA 28/08/2009
;;; 05:53 THA 15/09/2009
;;;
;;; View, or plot specific category of plan:
;;; 	- architecture,
;;;	- electric:
;;; 		- lighting,
;;; 		- receptacle,
;;; 		- tel,
;;; 		- network,
;;; 		- TV,
;;; 		- CCTV,
;;; 		- fire alarm,
;;; 		- main wiring,
;;; 		- or air conditioner,
;;; in specific level (1 - 5).
;;; Create the electric plots of S.Sukhumvit Suites hotel
;;;
;;; 18:36 THA 09/12/2018
;;;
;;; Add Exit Map view mode
;;; 	- exit map:
;;; 		- room number (1-11)
;;;
;;; 13:10 THA 16/03/2019
;;;
;;; Change room numbers:
;;;	x08	-> x09
;;;	x09	-> x08
;;;	x10	-> x18
;;;	x11	-> x17
;;;
;;; 11:37 THA 01/06/2019
;;;
;;; Update ppx() to show the exit instructions instead of the frame
;;;
;;; 16:26 THA 04/06/2019
;;;
;;; Update pp() to show the exit position out of the rooms.


( setq	nLvlPrev	1
	bShowLayoutPrev	1
	strPlanCatPrev	"E"
	strPlanECatPrev	"G"
	mapPlanECatName	'(
		( "G"	"Lighting" )
		( "R"	"Receptacle" )
		( "T"	"Telephone" )
		( "E"	"Network" )
		( "V"	"TV" )
		( "C"	"CCTV" )
		( "F"	"FireAlarm" )
		( "W"	"MainWiring" )
		( "A"	"AirCon" )
		( "S"	"Symbols" )
	)
	mapPlan	'(
		( "A"	() )	;;; architecture
		( "E"	mapPlanECatName ) ;;; electrical
		( "X"	() )	;;; exit map
	)
)

;;; View the plan of specific category, and specific level.
( defun C:viewplan ( / ) ( C:_vp nil nil nil nil ) )
( defun C:vp ( / ) ( C:_vp nil nil nil nil ) )
( defun C:_vp ( nLvl bShowLayout strPlanCat strPlanCatSub / )

	;;; Request from user, and return, the specific level.
	( defun getlevel ( / nLvl )
		;;; ask for the level number
		( if ( or ( null nLvlPrev ) ( < nLvlPrev 1 ) ( > nLvlPrev 5 ) )
			( setq nLvl	( getint
				"\nSelect the level [1, 2, 3, 4, 5]: "
			) )
		;;; else: show the question with the previous level
			( setq nLvl	( getint
				( strcat "\nSelect the level [1, 2, 3, 4, 5] <" ( itoa nLvlPrev ) ">: " )
			) )
		)

		;;; return
		nLvl
	)
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	( if ( null nLvl )
		;;; ask for the level at the first time only
		( setq nLvl ( getlevel ) )

		;;; if the given level is number type,
		;;; convert to string to be printed later
		( if ( not ( numberp nLvl ) )
			( setq nLvl
				( atoi nLvl )
			)
		)
	)

	;;; assert: the given level number is 1 to 5 OR previous one
	( if ( or ( null nLvl ) ( < nLvl 1 ) ( > nLvl 5 ) )
		;;; if previous value is not available,
		( if ( or ( null nLvlPrev ) ( < nLvlPrev 1 ) ( > nLvlPrev 5 ) )
			;;; terminate app
			( progn
				( princ "\nRequires level 1 to 5.\n" )
				( exit )
			)
		;;; else: get the previous level number
			( setq nLvl nLvlPrev )
		)
	)

	;;; if no given level
	( if ( null nLvl )
		;;; abort everything else
		( exit )
	)

	( setq
		;;; store the current level number in integer
		nLvlPrev nLvl

	  	;;; set the nLvl variable in string
		nLvl ( itoa nLvl )
	) 

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;; hide all layers
	( command "_layer"
		"off"
		"*"
		"Y"	;;; ``ALL'' layers, to make sure to turn off IF some layer's even default
	"" )

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;;; if the given plan category exists, ..
	( if ( not ( null strPlanCat ) )
		( setq strPlanCat
			;;; if the given category is number, convert to string
			( if ( numberp strPlanCat )
				( itoa strPlanCat )
			;;; else, convert to uppercase
				( strcase strPlanCat )
			)
		)
	)

	;;; if the plan category to show is not specified yet,
	;;; ask now
	( while 
		;;; check whether the input is valid
		( if ( or ( null strPlanCat ) ( zerop ( strlen strPlanCat ) ) )
			T	;;; empty input, ask again

			;;; check whether the input is known
			( if ( assoc strPlanCat mapPlan )
				;;; break, and continue to progress
				nil
			;;; otherwise, unknown input
				( progn ( princ ( strcat "\nUnknown category: " strPlanCat ) ) T )
			)
		)

		;;; ask for the plan category to show
		( if ( or ( null strPlanCatPrev ) ( zerop ( strlen strPlanCatPrev ) ) )
			( setq strPlanCat ( strcase ( getstring
				"\nEnter the category [Architecture, Electrical, eXit map]: "
			) ) )
		;;; else: show the question with the previous category as default
			( progn
				( setq strPlanCat ( strcase ( getstring
					( strcat "\nEnter the category [Architecture, Electrical, eXit map] <" strPlanCatPrev ">: " )
				) ) )
				;;; if submit nothing, get the previous choice
				( if ( zerop ( strlen strPlanCat ) ) ( setq strPlanCat strPlanCatPrev ) )
			)
		)
	)

	;;; store the specific plan category
	( setq strPlanCatPrev strPlanCat )

	;;; set the visible layers in specific plan and specific level
	( cond
		;;; architecture plan to show
		( ( = strPlanCat "A" )
			;;; show the architectural entities in specific level
			( command "_layer" "on"
				( strcat
					"wall.*[[]*" nLvl "*[]],"
					"wall[[]*" nLvl "*[]],"
					"door[[]*" nLvl "*[]],"
					"elev*[[]*" nLvl "*[]],"
					"partition[[]*" nLvl "*[]],"
					"glass[[]*" nLvl "*[]],"
					"mirror[[]*" nLvl "*[]],"
					"column*[[]*" nLvl "*[]],"
					"window[[]*" nLvl "*[]],"
					"furn*[[]*" nLvl "*[]],"
					"hatch*[[]*" nLvl "*[]],"
					"info[[]*" nLvl "*[]],"
					"lights[[]*" nLvl "*[]],"
					"logo[[]*" nLvl "*[]],"
					"toilet*[[]*" nLvl "*[]],"
					"tree[[]*" nLvl "*[]],"
					"room.text[[]*" nLvl "*[]],"

					"pebbles[[]*" nLvl "*[]],"
					"gas*[[]*" nLvl "*[]],"

					;;; debugging layers
					"0[[]*" nLvl "*[]],"
					"0"
				) ""

				;;; set the current layer to ``0'' of this layer
				"_clayer" ( strcat "0[" nLvl "]" )
			)
		)
		
		;;; electric plan to show
		( ( = strPlanCat "E" ) ( progn

			;;; if the given plan sub-category exists, ..
			( if ( not ( null strPlanCatSub ) )
				( setq strPlanCatSub
					;;; if the given category is number, convert to string
					( if ( numberp strPlanCatSub )
						( itoa strPlanCatSub )
					;;; else, convert to uppercase
						( strcase strPlanCatSub )
					)
				)
			)

			;;; if the plan sub-category is not specified yet,
			;;; ask now
			( while ( progn
				;;; later, if the input is NOT valid,
				;;; ask user again

				( if ( null strPlanCatSub )
					;;; show the question
					( if ( or ( null strPlanECatPrev ) ( zerop ( strlen strPlanECatPrev ) ) )
						( setq strPlanCatSub	( strcase ( getstring
							"\nEnter the plan [liGhting, Receptacle, Tel, nEtwork, tV, Cctv, Fire alarm, main Wiring, Aircon]: "
						) ) )
					;;; else: show the question with the previous plan
						( progn
							( setq strPlanCatSub	( strcase ( getstring
								( strcat "\nEnter the plan [liGhting, Receptacle, Tel, nEtwork, tV, Cctv, Fire alarm, main Wiring, Aircon] <" strPlanECatPrev ">: " )
							) ) )
							( if ( or ( null strPlanCatSub ) ( zerop ( strlen strPlanCatSub ) ) )
								( setq strPlanCatSub strPlanECatPrev )
							)
						)
					)
				)

				;;; except for the list of symbols paper,
				;;; show the general structure for electrical plan
				( if ( not ( or ( = strPlanCatSub "SYMBOLS" ) ( = strPlanCatSub "S" ) ) )
					( command "_layer" "on"
						( strcat
							"wall.*[[]*" nLvl "*[]],"
							"wall[[]*" nLvl "*[]],"
							"door[[]*" nLvl "*[]],"
							"elev*[[]*" nLvl "*[]],"
							"partition[[]*" nLvl "*[]],"
							"glass[[]*" nLvl "*[]],"
							"mirror[[]*" nLvl "*[]],"
							"column*[[]*" nLvl "*[]],"
							"window[[]*" nLvl "*[]],"

							;;; debugging layers
							"0[[]*" nLvl "*[]],"
							"0"
						) ""

						;;; set the current layer to ``0'' of this layer
						"_clayer" ( strcat "0[" nLvl "]" )
					)
				)

				( cond
					( ( or ( = strPlanCatSub "LIGHTING" ) ( = strPlanCatSub "G" ) ) ( progn
				;;; Lighting
					( command	"_layer" "on"
							( strcat
								"*board[[]*" nLvl "*[]],"
								"*lamp[[]*" nLvl "*[]],"
								"*light[[]*" nLvl "*[]],"
								"doorbell*[[]*" nLvl "*[]],"
								"electline.lighting[[]*" nLvl "*[]],"
								"dimmer[[]*" nLvl "*[]],"
								"timerdelay[[]*" nLvl "*[]],"
								"chandelier[[]*" nLvl "*[]],"
								"lc*[[]*" nLvl "*[]],"
								"controlpump[[]*" nLvl "*[]],"
								"switch*[[]*" nLvl "*[]],"
								"masterswitch*[[]*" nLvl "*[]],"
								"nameplate[[]*" nLvl "*[]],"
								"mdb[[]*" nLvl "*[]],"
							)
					;;; all *switch* except than manual switch and emergency light
							"off"
							"manualswitch*,emergencylight*,"
							;"Y"	;;; to make sure to turn off IF some layer's even default
							"" )
					nil
				) ) ( ( or ( = strPlanCatSub "RECEPTACLE" ) ( = strPlanCatSub "R" ) )
				;;; Receptacle
					( command	"_layer" "on"
							( strcat
								"receptacle[[]*" nLvl "*[]],"
								"elect.text[[]*" nLvl "*[]],"
								"switchboard[[]*" nLvl "*[]],"
								"controlboard[[]*" nLvl "*[]],"
								"lc*[[]*" nLvl "*[]],"
								"fan[[]*" nLvl "*[]],"
								"electline.receptacle[[]*" nLvl "*[]],"
							) "" )
					nil
				) ( ( or ( = strPlanCatSub "TEL" ) ( = strPlanCatSub "T" ) )
				;;; Tel
					( command	"_layer" "on"
							( strcat
								"tc[[]*" nLvl "*[]],"
								"telephone[[]*" nLvl "*[]],"
								"electline.tel*[[]*" nLvl "*[]],"
							) "" )
					nil
				) ( ( or ( = strPlanCatSub "NETWORK" ) ( = strPlanCatSub "E" ) )
				;;; Network
					( command	"_layer" "on"
							( strcat
								"tc[[]*" nLvl "*[]],"
								"electline.network[[]*" nLvl "*[]],"
								"network[[]*" nLvl "*[]],"
							) "" )
					nil
				) ( ( or ( = strPlanCatSub "TV" ) ( = strPlanCatSub "V" ) )
				;;; TV
					( command	"_layer" "on"
							( strcat
								"tc[[]*" nLvl "*[]],"
								"tvoutlet[[]*" nLvl "*[]],"
								"electline.tv[[]*" nLvl "*[]],"
							) "" )
					nil
				) ( ( or ( = strPlanCatSub "CCTV" ) ( = strPlanCatSub "C" ) )
				;;; CCTV
					( command	"_layer" "on"
							( strcat
								"tc[[]*" nLvl "*[]],"
								"cctv[[]*" nLvl "*[]],"
								"electline.cctv[[]*" nLvl "*[]],"
							) "" )
					nil
				) ( ( or ( = strPlanCatSub "FIREALARM" ) ( = strPlanCatSub "F" ) )
				;;; Fire Alarm
					( command	"_layer" "on"
							( strcat
								"heat*[[]*" nLvl "*[]],"
								"electline.heat*[[]*" nLvl "*[]],"
								"electline.firealarm*[[]*" nLvl "*[]],"
								"fa[[]*" nLvl "*[]],"
								"ohm[[]*" nLvl "*[]],"
								"bell[[]*" nLvl "*[]],"
								"manualswitch*[[]*" nLvl "*[]],"
							) "" )
					nil
				) ( ( or ( = strPlanCatSub "AIRCON" ) ( = strPlanCatSub "A" ) )
				;;; AirCon
					( command	"_layer" "on"
							( strcat
								"aircon*[[]*" nLvl "*[]],"
								"electline.aircon*[[]*" nLvl "*[]],"
								"switchboard[[]*" nLvl "*[]],"
								"controlboard[[]*" nLvl "*[]],"
								"lc*[[]*" nLvl "*[]],"
							) "" )
					nil
				) ( ( or ( = strPlanCatSub "MAINWIRING" ) ( = strPlanCatSub "W" ) )
				;;; Main Wiring
					( command	"_layer" "on"
							( strcat
								"electline.mainwiring*[[]*" nLvl "*[]],"
								"receptacle.main*[[]*" nLvl "*[]],"
								"controlboard*[[]*" nLvl "*[]],"
								"*switchboard*[[]*" nLvl "*[]],"
								"lc*[[]*" nLvl "*[]],"
								"mdb[[]*" nLvl "*[]],"
								"emergencylight*[[]*" nLvl "*[]],"
								"electline.em*[[]*" nLvl "*[]],"
								"exitlight*[[]*" nLvl "*[]],"
						) "" )
					nil
				) ( ( or ( = strPlanCatSub "SYMBOLS" ) ( = strPlanCatSub "S" ) )
				;;; List of Symbols
					( command	"_layer" "on"
						( strcat
							"text.layout*,"
							"logo*,"
							"ElectSymbols,"
						)
						;;; except than the info of level
						"off" "info[[]*"
						"" )
					nil
				) ( T ( progn
				;;; Default: unknown input
					( princ ( strcat "Unknown plan: " strPlanCatSub ) )
					(setq strPlanCatSub nil )
					T
				) ) )
			) ) ;;; while: sub-category is unknown
		) )

		;;; exit map plan to show
		( ( = strPlanCat "X" ) ( progn

			;;; show the entities for exit map in specific level and room
			( command "_layer" "on"
				( strcat
					"wall.*[[]*" nLvl "*[]],"
					"wall[[]*" nLvl "*[]],"
					"door[[]*" nLvl "*[]],"
					"elev*[[]*" nLvl "*[]],"
					;"partition[[]*" nLvl "*[]],"
					"glass[[]*" nLvl "*[]],"
					"mirror[[]*" nLvl "*[]],"
					"column*[[]*" nLvl "*[]],"
					"window[[]*" nLvl "*[]],"
					;"furn*[[]*" nLvl "*[]],"
					;"hatch*[[]*" nLvl "*[]],"
					"info[[]*" nLvl "*[]],"
					;"lights[[]*" nLvl "*[]],"
					"logo[[]*" nLvl "*[]],"
					;"toilet*[[]*" nLvl "*[]],"
					;"tree[[]*" nLvl "*[]],"
					"room.text[[]*" nLvl "*[]],"

					;"pebbles[[]*" nLvl "*[]],"
					;"gas*[[]*" nLvl "*[]],"

					;;; debugging layers
					"0[[]*" nLvl "*[]],"
					"0"
				) ""

				;;; set the current layer to ``0'' of this layer
				"_clayer" ( strcat "0[" nLvl "]" )
			)

		 	;;; get the room number from param
			( setq nRoom strPlanCatSub )

			;;; get the room number, if not yet
			( if ( or ( null nRoom ) ( < nRoom 1 ) ( > nRoom 18 ) )
				( setq nRoom ( getint
					"\nSelect the room number [01-18]: "
				) )
			)

			;;; show the room exit map
			( if ( not ( or ( null nRoom ) ( < nRoom 1 ) ( > nRoom 18 ) ) )
				;;; show specific room
				( command "_layer" "on"
					( strcat
						"exit.room."
						;;; convert to string
						( if ( > 10 nRoom )
							( strcat "0" ( itoa nRoom ) )
							( itoa nRoom )
						)
						"[[]*" nLvl "*[]]"
					) ""
				)
			)
		) )
	)

	;;; store the specific plan sub category
	( setq strPlanECatPrev strPlanCatSub )

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;; if the decision to show the layer exists, ..
	( if ( not ( null bShowLayout ) )
		( setq bShowLayout
			;;; if the given category is number, convert to string
			( if ( numberp bShowLayout )
				( itoa bShowLayout )
			;;; else, convert to uppercase
				( strcase bShowLayout )
			)
		)
	)

	;;; ask for showing the layout
	( while ( progn
		( if ( null bShowLayout )
			;;; show the question
			( if ( null bShowLayoutPrev )
				( setq bShowLayout ( strcase ( getstring
					"\nShow the layout [Yes, No]: "
				) ) )
			;;; else: show the question with the previous setting as default
				( progn
					( setq bShowLayout ( strcase ( getstring
						( strcat
							"\nShow the layout [Yes, No] <"
							( if ( zerop bShowLayoutPrev ) "N" "Y" )
							">: "
						)
					) ) )
					;;; if submit nothing, get the previous setting
					( if ( zerop ( strlen bShowLayout ) ) ( setq bShowLayout ( if ( zerop bShowLayoutPrev ) "N" "Y" ) ) )
				)
			)
		)
		
		;;; check the input; should be either ``Y'' or ``N''
		( cond 
			( ( if ( numberp bShowLayout )
					( not ( zerop bShowLayout ) )
					( or ( = bShowLayout "Y" ) ( = bShowLayout "YES" ) ) ) ( progn
				;;; show the layout
				( command	"_layer" "on"
						( strcat
							"text.layout*,"
							"logo*,"
							"info[[]*" nLvl "*[]]"
						)
				"" )

				;;; remember the setting for the future
				( setq bShowLayoutPrev 1 )
				nil
			) ) ( ( if ( numberp bShowLayout )
					( zerop bShowLayout )
					( or ( = bShowLayout "N" ) ( = bShowLayout "NO" ) ) ) ( progn
				;;; remember the setting for the future
				( setq bShowLayoutPrev 0 )

				;;; show the exit room
				( if ( = strPlanCat "X" )
					( command	"_layer" "on"
							( strcat
								"Exit.MapInfo*,"
								"Exit.General,"
								"Exit.General[[]*" nLvl "*[]],"
								"Exit.MapInfo[[]*" nLvl "*[]]"
							)
					"" )
				)

				nil
			) ) ( T
				;;; unknown input, ask again
				(setq bShowLayout nil )
				T
			)
		) ;;; cond: the given decision to show the layout is valid
	) )

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	T
)

;;; Plot the current visible plan
( defun C:pp ( / ) ( C:plotplan ) )
( defun C:plotplan ( / )
	( command "plot"
		"Y"	;;; detailed plot config

		"" "DWG To PDF.pc3"	;;; model layer name
		;"" "Microsoft Print to PDF"	;;; model layer name

		"ISO A3 (420.00 x 297.00 MM)"
		;"ISO A1 (841.00 x 594.00 MM)"
		;"ISO A4 (297.00 x 210.00 MM)"

		"I"	;;; paper unit: inches
		"L"	;;; landscape
		"N"	;;; not upside down
		"D"	;;; Display	[Display/Extents/Limits/View/Window]
		"F"	;;; fit
		"C"	;;; Center	[Center/(x,y)]
		"Y"	;;; plot style	[Yes/No]
		;"."	;;; no plot style table name
		;"grayscale.ctb"	;;; grayscale style
		"acad.ctb"	;;; normal style
		"Y"	;;; plot with lineweights	[Yes/No]
		"a"	;;; shade plot setting AS DISPLAYED	[As displayed/lagecy Wireframe/legacy Hidden/Visual style/Rendere]
		;flname	;;; output filename
		;;; output filename
		( strcat
			;;; category
			( if ( null strPlanCatPrev )
				""
				( strcat strPlanCatPrev strCurrENum "." )
			)
			;;; sub category
			( if ( null strPlanECatPrev )
				""
				( if ( = strPlanCatPrev "E" )
					( strcat ( cadr ( assoc strPlanECatPrev mapPlanECatName ) ) "." )
					""
				)
			)
			;;; level
			( if ( null nLvlPrev )
				""
				( strcat "L"
					( if ( numberp nLvlPrev )
						( itoa nLvlPrev )
						nLvlPrev
				) )
			)
			( if ( and ( null strPlanCatPrev ) ( = strPlanCatPrev strPlanECatPrev nLvlPrev ) )
				;;; default unknown plan
				"Plot"
				""
			)
			".pdf"
		)
		"n"	;;; don't save the changes
		"Y"	;;; go on!
	)
	T
)

( setq strCurrENum "" )

;;; Plot all electrical plans into PDF files.
( defun C:ppa ( / intENum currOSMODE )
	;;; for first to last plan, view and plot
	( setq
		intENum	1
	)

	;;; temporarily turn off OSMode
	( setq currOSMODE ( getvar "osmode" ) )
	( setvar "osmode" 0 )

	;;; foreach plan, view and plot it
	( foreach currPlan mapPlanECatName
		( if ( /= ( car currPlan ) "S" ) ;;; ignore Symbol layout
			( foreach currLvl '( 1 2 3 4 5 )
				( C:_vp currLvl "Y" "E" ( car currPlan ) )
		
				;;; set the current for the title
				( command "clayer" "TEXT.layout" )

				( command
				;;; delete the last title if exists
				"erase" ( ssget "x" '(
					( 0 . "MTEXT" )
					( 1 . "{\\LELECTRICAL SYSTEM *" )
					( 8 . "TEXT.layout" )
					(10 -10182.0 149242.0 0.0)
				) ) ""
				
				;;; print the new title
				"mtext"
					;;; 1st corner
					"-10182,148642"

					;;; style
					"s"	"standard"
					;;; text height
					"h"	"600"
					;;; rotation
					"r"	"0"
					;;; justify: top-left
					"j"	"tl"
					;;; width
					;"w"	"20000"

					;;; opposite corner
					"@20000,600"

					;;; text content
					( strcat
						"{\\LELECTRICAL SYSTEM #E-"
						( setq strCurrENum ( strcat
							( if ( < intENum 10 ) "0" "" )
							( itoa intENum )
						) )
						"}"
					)

					""
				)

				;;; plot it now
				( C:pp )

				;;; next Elect Num
				( setq intENum ( 1+ intENum ) )
			)
		)
	)

	;;; clear the E# string for plotting
	( setq strCurrENum "" )

	;;; restore the OSMODE
	( setvar "osmode" currOSMODE )
)

;;; Plot all exit room plans into PDF files.
( defun C:ppx ( / intENum currOSMODE )
	;;; for first to last plan, view and plot
	( setq
		intENum	1
	)

	;;; temporarily turn off OSMode
	( setq currOSMODE ( getvar "osmode" ) )
	( setvar "osmode" 0 )

	;;; foreach plan, view and plot it
	( foreach currLvl '( 1 2 3 4 5 )
		( foreach currRoom '( 1 2 3 4 5 6 7 8 9 17 18 )
			( C:_vp currLvl "N" "X" currRoom )
	
			;;; set the current for the title
			( command "clayer" "TEXT.layout" )

			( command
			;;; delete the last title if exists
			"erase" ( ssget "x" '(
				( 0 . "MTEXT" )
				( 1 . "{\\LFIRE EXIT *" )
				( 8 . "TEXT.layout" )
				(10 -10182.0 149242.0 0.0)
			) ) ""
			
			;;; print the new title
			"mtext"
				;;; 1st corner
				"-10182,148642"

				;;; style
				"s"	"standard"
				;;; text height
				"h"	"600"
				;;; rotation
				"r"	"0"
				;;; justify: top-left
				"j"	"tl"
				;;; width
				;"w"	"20000"

				;;; opposite corner
				"@20000,600"

				;;; text content
				( strcat
					"{\\LFIRE EXIT #"
					( setq strCurrENum ( strcat
						( if ( < intENum 10 ) "0" "" )
						( itoa intENum )
					) )
					"}"
				)

				""
			)

			;;; plot it now
			( C:pp )

			;;; next Room Num
			( setq intENum ( 1+ intENum ) )
		)
	)

	;;; clear the E# string for plotting
	( setq strCurrENum "" )

	;;; restore the OSMODE
	( setvar "osmode" currOSMODE )
)


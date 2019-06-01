<<<<<<< HEAD
;;; By BingLi224
;;; 14:17 THA 27/08/2009
;;;
;;; Change the current layer by selecting existing object/entity.
;;;

( defun C:cla ( / entChosen )
	;;; select an entity to get the layer name
	( setq entChosen ( entsel "\nSelect object to be the current layer: " ) )

	;;; if the selection is done,
	;;; set the current layer to the selected entity's layer
	( if ( not ( null entChosen ) )
		;;; set the current layer
		( command "clayer"
			;;; get the layer name
			( cdr ( assoc 8
				;;; get all info of the selected entity
				( entget ( car entChosen ) ) ) )
		)
	)
)
=======
;;; By BingLi224
;;; 14:17 THA 27/08/2009
;;;
;;; Change the current layer by selecting existing object/entity.
;;;

( defun C:cla ( / entChosen )
	;;; select an entity to get the layer name
	( setq entChosen ( entsel "\nSelect object to be the current layer: " ) )

	;;; if the selection is done,
	;;; set the current layer to the selected entity's layer
	( if ( not ( null entChosen ) )
		;;; set the current layer
		( command "clayer"
			;;; get the layer name
			( cdr ( assoc 8
				;;; get all info of the selected entity
				( entget ( car entChosen ) ) ) )
		)
	)
)
>>>>>>> 175116fb6954b3040ebc9746e4ba6768c6e8d8ef

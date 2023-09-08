;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; El port esportiu de València :D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (domain puertobase)
	(:requirements :strips :equality :typing :fluents)
	(:types 
		location container stack rail arm - object
	)
	(:predicates
		(cinta ?r - rail ?x - location ?y - location)

        (stack_at ?s - stack ?l - location)
        (container_at ?c - container ?l - location)
        (arm_at ?a - arm ?l - location)

        (arm_free ?a - arm)
        (rail_free ?r - rail)

		(holding ?a - arm ?c - container)

        (top ?c - container ?s - stack)
        (empty ?s - stack)

		(in  ?c - container ?r - rail)
		(on_container ?c1 - container ?c2 - container)
        (on_stack ?c - container ?s - stack)
		(clear ?c - container)

		(is_target ?c - container)
		(is_regular ?c - container)

		(available ?t - container ?l - location)
	)

	;;;;;;;;;;;
	;;ACTIONS;;
	;;;;;;;;;;;

(:action stackOnEmpty
		:parameters (
			?t - container
			?a - arm 
			?s - stack
			?l - location
		)
		:precondition (and 
			;;location: everything in the same part of the port
			(arm_at ?a ?l)
			(stack_at ?s ?l)

			(holding ?a ?t)
            (empty ?s)

		)
		:effect (and 
			;;delete previous state
			(not (empty ?s))
			(not (holding ?a ?t))

			;;set new state
			(top ?t ?s)
			(on_stack ?t ?s)
			(clear ?t)
			(arm_free ?a)

			(available ?t ?l) ;;per consistencia

		)
	)	
	(:action stackOnContainer_regular
		:parameters (
			?t - container
			?c - container
			?a - arm 
			?s - stack
			?l - location
		)
		:precondition (and 
			;;location: everything in the same part of the port
			(arm_at ?a ?l)
			(stack_at ?s ?l)

			(holding ?a ?t)
			(top ?c ?s)

			(is_regular ?t)
		)
		:effect (and 
			;;delete previous state
			(not (top ?c ?s))
			(not (holding ?a ?t))
			(not (clear ?c))

			;;set new state
			(top ?t ?s)
			(on_container ?t ?c)
			(clear ?t)
			(arm_free ?a)

			(not(available ?c ?l))
			(available ?t ?l) ;;per consistencia

		)
	)
	(:action stackOnContainer_target
		:parameters (
			?t - container
			?c - container
			?a - arm 
			?s - stack
			?l - location
		)
		:precondition (and 
			;;location: everything in the same part of the port
			(arm_at ?a ?l)
			(stack_at ?s ?l)

			(holding ?a ?t)
			(top ?c ?s)

			(is_target ?t)
		)
		:effect (and 
			;;delete previous state
			(not (top ?c ?s))
			(not (holding ?a ?t))
			(not (clear ?c))

			;;set new state
			(top ?t ?s)
			(on_container ?t ?c)
			(clear ?t)
			(arm_free ?a)

			(available ?t ?l) ;;action

		)
	)
	;;unstack
    (:action unstackToEmpty
		:parameters (
			?t - container
			?a - arm 
			?s - stack
			?l - location
		)
		:precondition (and
			;;location: everything in the same part of the port
			(arm_at ?a ?l)
			(stack_at ?s ?l)

			;;scenario: remove container from top of the other
			(top ?t ?s)
			(on_stack ?t ?s)
			(arm_free ?a)
		)
		:effect (and 
			;;delete previous state
			(not (top ?t ?s))
			(not (on_stack ?t ?s))
			(not (clear ?t))
			(not (arm_free ?a))
			(not (available ?t ?l))

			;;set new state
			(holding ?a ?t)
            (empty ?s)
		)
	)
	(:action unstack
		:parameters (
			?t - container
			?c - container
			?a - arm 
			?s - stack
			?l - location
		)
		:precondition (and
			;;location: everything in the same part of the port
			(arm_at ?a ?l)
			(stack_at ?s ?l)

			;;scenario: remove container from top of the other
			(top ?t ?s)
			(on_container ?t ?c)
			(arm_free ?a)
		)
		:effect (and 
			;;delete previous state
			(not (top ?t ?s))
			(not (on_container ?t ?c))
			(not (clear ?t))
			(not (arm_free ?a))
			(not (available ?t ?l))

			;;set new state
			(top ?c ?s)
			(clear ?c)
			(available ?c ?l)
			(holding ?a ?t)		
		)
	)

	;;placeInRail
	(:action placeInRail
		:parameters (
			?l - location
            ?dest - location
			?a - arm
			?c - container
			?r - rail
		)
		:precondition (and
			;;location: everything in the same part of the port
			(arm_at ?a ?l)

			;;scenario
			(holding ?a ?c)
			(rail_free ?r)
			(cinta ?r ?l ?dest)
		)
		:effect (and
			;;delete previous state
			(not (holding ?a ?c))
			(not (rail_free ?r))
			;;set new state
			(in ?c ?r)
			(arm_free ?a)
		)
	)

	;;pickFromRail
	(:action pickFromRail
		:parameters (
			?r - rail
			?l - location
            ?ori - location
			?c - container
			?a - arm
		)
		:precondition (and
			;;(transported ?c ?l)
			(container_at ?c ?l)
			(arm_at ?a ?l)
			;;(cinta ?r ?ori ?l)
			(in ?c ?r)
			(arm_free ?a)
		)
		:effect (and
			;;delete previous state
			(not (in ?c ?r))
			(not (arm_free ?a))
			
			;;set new state
			(holding ?a ?c)
			(rail_free ?r)
		)
	)

	;;transport
	(:action transport ;;polivalent xd
		:parameters (
			?r - rail
			?c - container
			?ori - location
            ?dest - location
		)

		:precondition (and 
			(in ?c ?r)
			(cinta ?r ?ori ?dest)
			(container_at ?c ?ori)
		)
		:effect (and
			(not (container_at ?c ?ori))
			(container_at ?c ?dest)
		)

	)
	
)
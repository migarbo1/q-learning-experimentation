;; one target container in 2. must be moved to 1
(define (problem puertobase)
    (:domain puertobase)
    (:objects
		;;loc 1
		l1 - location
		a1 - arm
		r1 - rail

		s11 - stack
		t3 - container
		c1 - container
		
		s12 - stack

		;;loc 2
		l2 - location
		a2 - arm
		r2 - rail

		s21 - stack
        t2 - container
		
		s22 - stack
	)
	(:init

		;;stacks at location
		(stack_at s11 l1)
		(stack_at s12 l1)

		;;arm at location
		(arm_at a1 l1)
		(cinta r1 l1 l2)

		;;free rail1
		(rail_free r1)

		;;free arm1
		(arm_free a1)

		(available c1 l1)
		(clear c1)
		(top c1 s11)
		(on_container c1 t3)
		(on_stack t3 s11)
		(container_at c1 l1)
		(container_at t3 l1)

		(is_regular c1)
		(is_target t3)

		(empty s12)

        ;;Location 2

		;;stacks at location
		(stack_at s21 l2)
		(stack_at s22 l2)

		;;arm at location
		(arm_at a2 l2)
		(cinta r2 l2 l1)

		;;free rail1
		(rail_free r2)

		;;free arm1
		(arm_free a2)

		;;container states location 2
		(available t2 l2)
		(clear t2)
		(top t2 s21)
		(on_stack t2 s21)
		(container_at t2 l2)

		(empty s22)

		;;containers identity
		(is_target t2)

	)
	(:goal (and
		(available t2 l1)
		(available t3 l1)
	))
)
;; one target container in 2. must be moved to 1
(define (problem puertobase)
    (:domain puertobase)
    (:objects
		;;loc 1
		l1 - location
		a1 - arm
		r1 - rail

		s11 - stack
		c4 - container
		c5 - container
		
		s12 - stack

		;;loc 2
		l2 - location
		a2 - arm
		r2 - rail

		s21 - stack
		c2 - container
		t1 - container
		t3 - container
		
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

		(available c4 l1)
		(clear c4)
		(top c4 s11)
		(on_stack c4 s11)
		(container_at c4 l1)

		(available c5 l1)
		(clear c5)
		(top c5 s12)
		(on_stack c5 s12)
		(container_at c5 l1)

		(is_regular c4)
		(is_regular c5)


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
		(available t1 l2)
		(clear t1)
		(top t1 s21)
		(on_stack t1 s21)
		(container_at t1 l2)

		(available c2 l2)
		(clear c2)
		(top c2 s22)
		(on_container c2 t3)
		(on_stack t3 s22)
		(container_at c2 l2)
		(container_at t3 l2)

		(empty s22)

		;;containers identity
		(is_target t3)
		(is_target t1)
		(is_regular c2)

	)
	(:goal (and
		(available t1 l1)
		(available t3 l1)
	))
)
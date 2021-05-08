/datum/targetable/vampire/grave_grasp
	name = "Grave grasp"
	desc = "Grabs the target and infects them with a deadly, non-contagious disease."
	icon_state = "badtouch" //brought to you by the bloodhound gang
	targeted = 1
	target_nodamage_check = 1
	max_range = 1
	cooldown = 750
	pointCost = 50
	when_stunned = 0
	not_when_handcuffed = 1
	unlock_message = "You have gained grave grasp, when used on someone you will aggressively grab them and inflict them with a deadly non-contagious disease"

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampire/H = holder

		if (!M || !target || !ismob(target))
			return 1

		if (M == target)
			boutput(M, __red("Why would you want to infect yourself?"))
			return 1

		if (get_dist(M, target) > src.max_range)
			boutput(M, __red("[target] is too far away."))
			return 1

		if (isdead(target))
			boutput(M, __red("It would be a waste of time to infect the dead."))
			return 1

		if (!iscarbon(target))
			boutput(M, __red("[target] is immune to the disease."))
			return 1

		var/mob/living/L = target

		//playsound(M.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
		//M.visible_message("<span class='notice'>[M] shakes [L], trying to wake them up!</span>")
		M.shake_awake(target)
		L.add_fingerprint(M) // Why not leave some forensic evidence?
		if (!(L.bioHolder && L.traitHolder.hasTrait("training_chaplain")))
			L.contract_disease(/datum/ailment/disease/vamplague, null, null, 1) // path, name, strain, bypass resist
			M.visible_message("<span class='alert'><B>[M] aggressively grabs [L]!</B></span>")
			var/obj/item/grab/G = new /obj/item/grab(M, M, L)
			M.put_in_hand(G, M.hand)
			G.state = 3
			L.loc = M.loc
			G.update_icon()
			M.set_dir(get_dir(M, L))
			playsound(M.loc, "sound/impact_sounds/Generic_Shove_1.ogg", 65, 1)

		if (istype(H)) H.blood_tracking_output(src.pointCost)
		logTheThing("combat", M, L, "uses grave grasp on [constructTarget(L,"combat")] at [log_loc(M)].")
		return 0

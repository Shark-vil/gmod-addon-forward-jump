local CurTime = CurTime
local LerpVector = LerpVector
local slib_magnitude = slib.magnitude
--
local sound_effects = {
	Sound('sharkvil/forward_jump_animation/somersault_01.wav'),
	Sound('sharkvil/forward_jump_animation/somersault_02.wav'),
}

hook.Add('Slib_PlayAnimation', 'ForwardJumpAnimationTeleport', function(anim_info)
	if anim_info.name ~= 'forward_jump_anim' then return end

	local ForwardJump = anim_info.data.ForwardJump
	local target = anim_info.entity
	local animator = anim_info.animator
	local target_position = ForwardJump.targetPosition
	local animator_final_jumppos =  animator:GetPos()
	local animator_jumppos = animator:GetPos() + Vector(0, 0, 20)
	local is_ground_detected = false

	local phys = animator:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	do
		local tr = ForwardJump:TraceGroundCollision()
		if tr.Hit then
			animator_final_jumppos.z = tr.HitPos.z
			target_position.z = animator_final_jumppos.z
			is_ground_detected = true
		end
	end

	local start_jump_delay = .8
	if anim_info.sequence == 'root_fast' then
		start_jump_delay = .5
	end

	timer.Simple(start_jump_delay, function()
		target:EmitSound(table.RandomBySeq(sound_effects), 75, 100, 1, CHAN_AUTO)

		if GetConVar('sv_forward_jump_breakglass'):GetBool() then
			local tr = ForwardJump:TraceGlassEntity()
			if tr then
				local x = 1
				local y = 1

				for i = 0, 20 do
					target:FireBullets({
						Src = target:EyePos(),
						Dir = tr.Normal,
						Num = 1,
						Distance = tr.StartPos:Distance(tr.HitPos) + 10,
						Spread = Vector(x, y),
						IgnoreEntity = target,
					})

					x = x - .1
					y = x - .1
				end
			end
		end

		local stagetwo
		local addspeed = 10

		if anim_info.sequence == 'root_fast' then
			stagetwo = CurTime() + .4
		else
			stagetwo = CurTime() + .5
		end

		animator:slibCreateTimer('lerp', 0, 0, function()
			local speed = slib.fixedDeltaTime * addspeed
			if stagetwo > CurTime() then
				animator:SetPos(LerpVector(speed, animator:GetPos(), animator_jumppos))
			else
				if not is_ground_detected then
					speed = slib.fixedDeltaTime * (slib_magnitude(target:GetVelocity()) / 20)
					animator_final_jumppos.z = target:GetPos().z
					target_position.z = animator_final_jumppos.z
				end
				animator:SetPos(LerpVector(speed, animator:GetPos(), animator_final_jumppos))
			end
		end)
	end)

	target:slibCreateTimer('forward_jump_anim_end', anim_info.time / 2.5, 1, function()
		if not IsValid(animator) then return end
		target:SetPos(target_position)
	end)
end)
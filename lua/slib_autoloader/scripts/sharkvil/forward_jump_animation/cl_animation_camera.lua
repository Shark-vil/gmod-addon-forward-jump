local LerpVector = LerpVector
local LerpAngle = LerpAngle
local CurTime = CurTime
--
CreateClientConVar('cl_forward_jump_anim_firstperson', '0', true, false)

hook.Add('Slib_PlayAnimation', 'CalcViewAnimationForwardJumpTP', function(anim_info)
	if anim_info.name ~= 'forward_jump_anim' then return end
	if anim_info.entity ~=  LocalPlayer() then return end
	if GetConVar('cl_forward_jump_anim_firstperson'):GetBool() then return end

	local cam_pos
	local cam_angle
	local hook_name = slib.UUID()
	local animator = anim_info.animator
	local stoptime = CurTime() + anim_info.time
	local stagetwo = CurTime() + anim_info.time - .3
	local stagethree = CurTime() + anim_info.time - .15
	local forward = animator:GetForward()

	hook.Add('CalcView', hook_name, function(ply, position, angles, fov)
		local current_time = CurTime()

		if not IsValid(animator) or stoptime < current_time then
			hook.Remove('CalcView', hook_name)
			return
		end

		if not cam_pos then cam_pos = position end
		if not cam_angle then cam_angle = angles end

		local speed = slib.deltaTime * 4
		local center, _ = animator:GetBonePosition(animator:LookupBone('Circle001'))

		if current_time < stagetwo then
			local next_cam_angle = forward:Angle() - Angle(-10, 0, 0)
			cam_angle = LerpAngle(speed, cam_angle, next_cam_angle)

			local next_cam_pos = center - forward * 50 + ply:GetRight() * 10 + ply:GetUp() * 60
			cam_pos = LerpVector(speed, cam_pos, next_cam_pos)
		else
			position.x = center.x
			position.y = center.y

			cam_pos = LerpVector(speed, cam_pos, position)
			cam_angle = LerpAngle(speed, cam_angle, angles)

			if current_time >= stagethree then anim_info.nodraw = true end
		end

		local view = {
			origin = cam_pos,
			angles = cam_angle,
			fov = fov,
			drawviewer = true
		}

		return view
	end)
end)

hook.Add('Slib_PlayAnimation', 'CalcViewAnimationForwardJumpFP', function(anim_info)
	if anim_info.name ~= 'forward_jump_anim' then return end
	if anim_info.entity ~=  LocalPlayer() then return end
	if not GetConVar('cl_forward_jump_anim_firstperson'):GetBool() then return end

	local cam_pos
	local cam_angle
	local headindex
	local hook_name = slib.UUID()
	local animator = anim_info.animator
	local stoptime = CurTime() + anim_info.time
	local stagethree = CurTime() + anim_info.time - .7
	local stagetwo_p1
	local stagetwo_p2
	local stagetwo

	if anim_info.sequence == 'root_fast' then
		stagetwo = CurTime() + .4
		stagetwo_p1 = Lerp(.3, stagetwo, stagethree)
		stagetwo_p2 = Lerp(.5, stagetwo, stagethree)
	else
		stagetwo = CurTime() + .8
		stagetwo_p1 = Lerp(.2, stagetwo, stagethree)
		stagetwo_p2 = Lerp(.4, stagetwo, stagethree)
	end

	hook.Add('CalcView', hook_name, function(ply, position, angles, fov)
		local current_time = CurTime()

		if not headindex and IsValid(animator) then
			headindex = animator:LookupBone('ValveBiped.Bip01_Head1')
		end

		if not headindex or not IsValid(animator) or stoptime < current_time then
			hook.Remove('CalcView', hook_name)
			return
		end

		if not anim_info.settings.no_draw then anim_info.settings.no_draw = true end
		if not cam_pos then cam_pos = position end
		if not cam_angle then cam_angle = angles end

		local speed
		local _, headang = animator:GetBonePosition(headindex)
		local center, _ = animator:GetBonePosition(animator:LookupBone('Circle001'))

		position.x = center.x
		position.y = center.y

		if current_time >= stagethree then
			speed = slib.deltaTime * 4
		else
			speed = slib.deltaTime * 2
		end

		if stagetwo < current_time and stagethree > current_time then
			if stagetwo_p1 < current_time and stagetwo_p2 > current_time then
				cam_pos = LerpVector(speed, cam_pos, position + Vector(0, 0, 10))
			else
				position = position + animator:GetForward() * 10
				cam_pos = LerpVector(speed, cam_pos, position - Vector(0, 0, 30))
			end
		else
			cam_pos = LerpVector(speed, cam_pos, position)
		end

		if stagethree < current_time then
			cam_angle = LerpAngle(speed, cam_angle, angles)
		else
			cam_angle = LerpAngle(speed * 2, cam_angle, headang - Angle(-50, 0, 90))
		end

		local view = {
			origin = cam_pos,
			angles = cam_angle,
			fov = fov,
			drawviewer = true
		}

		return view
	end)
end)
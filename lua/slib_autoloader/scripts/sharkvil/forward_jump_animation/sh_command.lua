local math_abs = math.abs
--
local movetype_blacklist = {
	MOVETYPE_FLY,
	MOVETYPE_FLYGRAVITY,
	MOVETYPE_NOCLIP,
	MOVETYPE_LADDER,
	MOVETYPE_OBSERVER,
}

scommand.Create('act_forward_jump').OnServer(function(ply)
	if not IsValid(ply) or slib.Animator.IsPlay('forward_jump_anim', ply) then return end
	if table.HasValueBySeq(movetype_blacklist, ply:GetMoveType()) then return end
	if not ply:OnGround() then return end

	local ForwardJump = slib.Instance('ForwardJumpComponent', ply)

	local tr = ForwardJump:TraceTotalJumpDistance()
	if tr.Hit then return end

	tr = ForwardJump:TraceGroundCollision()
	if GetConVar('sv_forward_jump_ground_detected'):GetBool() and not tr.Hit then return end
	if tr.Hit and math_abs(ForwardJump.startPosition.z - tr.HitPos.z) >= 20 then return end

	tr = ForwardJump:TraceAbsenceObstacles()
	if not tr.Hit or tr.Entity ~= ply then return end

	if ForwardJump:IsStuckPrediction() then return end

	local animation_type = 'root'
	if GetConVar('sv_forward_jump_fastmode'):GetBool() then
		animation_type = 'root_fast'
	end

	slib.Animator.Play('forward_jump_anim', animation_type, ply,
		{ not_parent = true }, { ForwardJump = ForwardJump }
	)
end).Register()
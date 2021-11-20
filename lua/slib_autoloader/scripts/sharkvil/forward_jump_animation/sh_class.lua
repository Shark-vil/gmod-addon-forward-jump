local util_TraceLine = util.TraceLine
local util_TraceHull = util.TraceHull
local Vector = Vector
local Angle = Angle
local LocalToWorld = LocalToWorld
--
local ForwardJumpComponent = {}
local Vector_0_0_10 = Vector(0, 0, 20)
local Vector_0_0_15 = Vector(0, 0, 20)
local Vector_0_0_5 = Vector(0, 0, 5)
local Color_0_26_255 = Color(0, 26, 255)
local Color_0_162_255 = Color(0, 162, 255)
local Color_255_0_0 = Color(255, 0, 0)
local Color_9_255_0 = Color(9, 255, 0)
local Color_255_239_13 = Color(255, 239, 13)
local EmptyAngle = Angle()

local function is_breakable_surf(ent)
	if ent:GetClass() ~= 'func_breakable_surf' then return false end
	return GetConVar('sv_forward_jump_breakglass'):GetBool()
end

function ForwardJumpComponent:Instance(ply)
	local function _filter_no_player(ent)
		if ent ~= ply then return true end
	end

	local function _filter_no_player_and_func_breakable_surf(ent)
		if ent ~= ply and not is_breakable_surf(ent) then
			return true
		end
	end

	local function _filter_simple(ent)
		if not is_breakable_surf(ent) then
			return true
		end
	end

	local public = {}
	public.player = ply
	public.jumpDistance = 130
	public.groundCheckDistance = 120
	public.obbCenter = ply:OBBCenter()
	public.obbMaxs = ply:OBBMaxs()
	public.obbMins = ply:OBBMins()
	public.startAngles = ply:GetAngles()
	public.startPosition = ply:GetPos()
	public.startCenter = ply:LocalToWorld(public.obbCenter) + Vector_0_0_10
	public.forwardDirection = ply:GetForward()
	public.upDirection = ply:GetUp()
	do
		local tr = util_TraceLine({
			start = public.startCenter,
			endpos = public.startCenter + public.forwardDirection * public.jumpDistance,
			filter = _filter_no_player_and_func_breakable_surf
		})
		public.targetPosition = tr.HitPos
	end

	function public:GetUpperCenter()
		local vec, ang = self:GetCenter()
		return vec + Vector_0_0_10, ang
	end

	function public:GetCenter()
		return LocalToWorld(self.obbCenter, EmptyAngle, ply:GetPos(), self.startAngles)
	end

	function public:GetGroundCheckerStartPosition()
		return self:GetUpperCenter() + self.forwardDirection * self.groundCheckDistance
	end

	function public:TraceGlassEntity()
		local center = self:GetUpperCenter()
		local tr = util_TraceLine({
			start = center,
			endpos = center + self.forwardDirection * self.jumpDistance,
			filter = _filter_no_player
		})

		debugoverlay.Line(center, tr.HitPos, 3, Color_0_162_255)
		debugoverlay.Sphere(tr.HitPos, 10, 3, Color_0_162_255)

		if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == 'func_breakable_surf' then
			return tr
		end

		return nil
	end

	function public:TraceTotalJumpDistance()
		local center = self:GetUpperCenter()
		local tr = util_TraceLine({
			start = center,
			endpos = center + self.forwardDirection * self.jumpDistance,
			filter = _filter_no_player_and_func_breakable_surf
		})

		-- local box_center = tr.HitPos
		-- box_center.z = box_center.z - (self.obbMaxs.z / 2)
		-- local max_vector = self.obbMaxs - Vector(0, 0, 10)
		-- local min_vector = self.obbMins

		-- debugoverlay.Box(box_center, min_vector, max_vector, 5, Color_255_239_13)

		-- local tr_box = util_TraceHull({
		-- 	start = box_center,
		-- 	endpos = box_center,
		-- 	maxs = max_vector,
		-- 	mins = min_vector,
		-- 	filter = _filter_no_player_and_func_breakable_surf
		-- })

		-- if tr_box.Hit then
		-- 	tr.Hit = true
		-- 	return tr
		-- end

		debugoverlay.Line(center, tr.HitPos, 3, Color_0_26_255)
		debugoverlay.Sphere(tr.HitPos, 10, 3, Color_0_26_255)

		return tr
	end

	function public:TraceGroundCollision()
		local center = self:GetGroundCheckerStartPosition()
		local tr = util_TraceLine({
			start = center,
			endpos = center - self.upDirection * (self.obbCenter.z + 40),
			filter = _filter_simple
		})

		debugoverlay.Line(center, tr.HitPos, 3, Color_255_0_0)
		debugoverlay.Sphere(tr.HitPos, 10, 3, Color_255_0_0)

		return tr
	end

	function public:TraceAbsenceObstacles()
		local ground_position = self:TraceGroundCollision().HitPos
		local offset_distance = self.jumpDistance - self.groundCheckDistance
		local center = ground_position + self.forwardDirection * offset_distance + Vector_0_0_15
		local tr = util_TraceLine({
			start = center,
			endpos = ply:EyePos() - Vector_0_0_5,
			filter = _filter_simple
		})

		debugoverlay.Line(center, tr.HitPos, 3, Color_9_255_0)
		debugoverlay.Sphere(tr.HitPos, 10, 3, Color_9_255_0)

		return tr
	end

	function public:IsStuckPrediction()
		local tr = util_TraceLine({
			start = self.targetPosition,
			endpos = self.targetPosition - self.upDirection * 1000,
			filter = _filter_simple
		})

		local center = tr.HitPos
		local max_vector = self.obbMaxs
		local min_vector = self.obbMins
		max_vector.z = max_vector.z - 20
		min_vector.z = min_vector.z + 20

		debugoverlay.Box(center, min_vector, max_vector, 3, Color_255_239_13)

		tr = util_TraceHull({
			start = center,
			endpos = center,
			maxs = max_vector,
			mins = min_vector,
		})

		return tr.Hit
	end

	return public
end

slib.SetComponent('ForwardJumpComponent', ForwardJumpComponent)

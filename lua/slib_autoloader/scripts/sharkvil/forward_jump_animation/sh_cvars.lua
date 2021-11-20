local DefaultAccess = { isAdmin = true }

scvar.Register('sv_forward_jump_breakglass', 1, FCVAR_ARCHIVE,
	'1 - the ability to break glass, 0 - disable.', 0, 1)
	.Access(DefaultAccess)

scvar.Register('sv_forward_jump_fastmode', 1, FCVAR_ARCHIVE,
	'1 - accelerated animation will be used, 0 - default.', 0, 1)
	.Access(DefaultAccess)

scvar.Register('sv_forward_jump_ground_detected', 1, FCVAR_ARCHIVE,
	'1 - turn on the ground detector to prevent jumping into the void, 0 - disable.', 0, 1)
	.Access(DefaultAccess)
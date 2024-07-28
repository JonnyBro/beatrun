local OldAnims = CreateClientConVar("Beatrun_OldAnims", "0", true, false, "")

local animtable = {
	lockang = false,
	allowmove = true,
	followplayer = true,
	ignorez = false,
	BodyAnimSpeed = 1,
	deleteonend = false,
	BodyLimitX = 90,
	AnimString = "jumpslow",
	CamIgnoreAng = true,
	animmodelstring = "new_climbanim",
	BodyLimitY = 180,
	usefullbody = 2
}

fbanims = {
	ladderexittoplefthand = true,
	runfwdstart = true,
	walktostandleft = true,
	wallrunverticalstart = true,
	meleeair = true,
	fallinguncontrolled = true,
	stand = true,
	meslideend = true,
	walkbalancefwd = true,
	meleewrleft = true,
	runfwd = true,
	jumpzipline = true,
	springboardleftleg = true,
	jumpcoilend = true,
	hangstraferight = true,
	hangfoldedstart = true,
	jumpslow = true,
	hangheaveup = true,
	jumpwrright = true,
	meleeairhit = true,
	jumpstill = true,
	dodgejumpright = true,
	jumpturnflyidle = true,
	ladderclimbdownfast = true,
	ladderclimbuprighthand = true,
	wallrunverticalturn = true,
	jumpturnlandidle = true,
	hanghardstart = true,
	hangstrafeleft = true,
	walkfwd = true,
	jumpfast = true,
	meslidestart45 = true,
	hangfoldedendhang = true,
	wallrunleft = true,
	zipline = true,
	wallrunleftstart = true,
	sprintfwd = true,
	walkbalancelosebalanceright = true,
	jumpwrleft = true,
	grapplecenter = true,
	swingstraight = true,
	jumpcoil = true,
	hang = true,
	runland = true,
	crouchfwd = true,
	crouchbwd = true,
	meslideloop = true,
	crouchstill = true,
	snatchsniper = true,
	meslidestart = true,
	ladderclimbuplefthandstill = true,
	bargein = true,
	meslideendprone = true,
	diveidle = true,
	diveslidestart = true,
	diveslideidle = true,
	wallrunright = true,
	diveslideend = true,
	divestart = true,
	hangfoldedheaveup = true,
	ziplinestart = true,
	dodgejumpleft = true,
	evaderoll = true,
	hanghardstart2 = true,
	diestand = true,
	jumpturnlandstand = true,
	runbwd = true,
	hanghardstartvertical = true,
	walkbalancestill = true,
	ladderenterbottom = true,
	wallrunrightstart = true,
	walkbalancefalloffleft = true,
	wallrunvertical = true,
	ladderclimbhangstart = true,
	jumpturnland = true,
	jumpturnlandstandgun = true,
	meleewrright = true,
	diestandlong = true,
	ladderclimbuplefthand = true,
	walkbalancelosebalanceleft = true,
	jumpturnfly = true,
	meslideloop45 = true,
	meleeslide = true,
	stepuprightleg = true,
	ladderexittoprighthand = true,
	ladderclimbuprighthandstill = true,
	jumpidle = true,
	jumpair = true,
	vaultkong = true,
	vaultonto = true,
	vaultover = true,
	vaultontohigh = true,
	vaultoverhigh = true,
	walkbalancefalloffright = true,
	meleeairstill = true,
	swingjumpoff = true,
	snatchscar = true,
	water_swimfwd = true,
	water_swimright = true,
	water_swimleft = true,
	water_swimback = true,
	water_float = true
}

local jumpanims = {
	jumpwrleft = true,
	jumpfast = true,
	jumpslow = true,
	jumpwrright = true,
	jumpstill = true,
	jumpidle = true,
	jumpair = true,
	jumpcoil = true,
	jumpzipline = true
}

local jumpanims2 = {
	jumpfast = true,
	jumpslow = true,
	jumpstill = true
}

local runanims = {
	crouchfwd = true,
	crouchbwd = true,
	walktostandleft = true,
	stand = true,
	runfwd = true,
	walkfwd = true,
	crouchstill = true,
	sprintfwd = true,
	runbwd = true
}

local events = {
	ladderenter = true,
	divestart = true,
	fall = true,
	ladderclimbleft = true,
	jumpwallrun = true,
	ziplinestart = true,
	hangstrafeleft = true,
	hangstraferight = true,
	climbhard = true,
	walkbalancefwd = true,
	hangfoldedheaveup = true,
	jumpturnlandstand = true,
	swingjump = true,
	sidestepleft = true,
	swingpiperight = true,
	jumpfar = true,
	hangfoldedstart = true,
	jumpslide = true,
	swingpipeleft = true,
	ladderenterhang = true,
	disarmsniper = true,
	jumpstill = true,
	climb = true,
	stepup = true,
	ladderclimbdownfast = true,
	sidestepright = true,
	jumpwallrunleft = true,
	meleeslide = true,
	meleeair = true,
	disarmscar = true,
	falluncontrolled = true,
	meleewrright = true,
	meleewrleft = true,
	meleeairhit = true,
	climbhard2 = true,
	walkbalancestill = true,
	hangfoldedendhang = true,
	walkbalancefalloffleft = true,
	walkbalancefalloffright = true,
	swingbar = true,
	jump = true,
	jumpwallrunright = true,
	coil = true,
	ladderexittoplefthand = true,
	climbheave = true,
	diveslidestart = true,
	bargedoor = true,
	hangjump = true,
	diveslideend = true,
	landcoil = true,
	ladderexittoprighthand = true,
	hangend = true,
	springboard = true,
	vault = true,
	vaultkong = true,
	vaultonto = true,
	vaultover = true,
	vaultontohigh = true,
	ladderclimbright = true,
	meleeairstill = true
}

local eventslut = {
	ladderenter = "ladderenterbottom",
	divestart = "divestart",
	jumpwallrunright = "jumpwrleft",
	hangfoldedheaveup = "hangfoldedheaveup",
	jumpwallrun = "jumpfast",
	hangstrafeleft = "hangstrafeleft",
	ziplinestart = "ziplinestart",
	climbhard2 = "hanghardstart2",
	vaultonto = "vaultonto",
	climbhard = "hanghardstart",
	walkbalancefwd = "walkbalancefwd",
	jumpwallrunleft = "jumpwrright",
	jumpturnlandstand = "jumpturnlandstand",
	swingjump = "swingjumpoff",
	sidestepleft = "dodgejumpleft",
	vaulthigh = "vaultoverhigh",
	hangstraferight = "hangstraferight",
	hangfoldedstart = "hangfoldedstart",
	ladderexittoprighthand = "ladderexittoprighthand",
	swingpipeleft = "stand",
	ladderenterhang = "ladderclimbhangstart",
	vault = "vaultover",
	disarmsniper = "snatchsniper",
	jumpstill = "jumpstill",
	climb = "hanghardstartvertical",
	stepup = "stepuprightleg",
	springboard = "springboardleftleg",
	ladderexittoplefthand = "ladderexittoplefthand",
	slide45 = "meslidestart45",
	sidestepright = "dodgejumpright",
	meleeslide = "meleeslide",
	disarmscar = "snatchscar",
	falluncontrolled = "fallinguncontrolled",
	meleewrright = "meleewrright",
	meleeairhit = "meleeairhit",
	meleewrleft = "meleewrleft",
	meleeair = "meleeair",
	jumpslide = "jumpfast",
	hangfoldedendhang = "hangfoldedendhang",
	walkbalancestill = "walkbalancestill",
	walkbalancefalloffleft = "walkbalancefalloffleft",
	walkbalancefalloffright = "walkbalancefalloffright",
	swingbar = "swingstraight",
	ladderclimbleft = "ladderclimbuplefthand",
	coil = "jumpcoil",
	fall = "jumpair",
	climbheave = "hangheaveup",
	slide = "meslidestart",
	bargedoor = "bargein",
	hangjump = "jumpfast",
	diveslidestart = "diveslidestart",
	landcoil = "jumpcoilend",
	diveslideend = "diveslideend",
	hangend = "jumpair",
	ladderclimbdownfast = "ladderclimbdownfast",
	swingpiperight = "stand",
	vaultkong = "vaultkong",
	ladderclimbright = "ladderclimbuprighthand",
	meleeairstill = "meleeairstill",
	vaultontohigh = "vaultontohigh"
}

local armfollowanims = {
	stand = true,
	diveslideidle = true,
	walktostandleft = true,
	diestandlong = true,
	diveslidestart = true,
	vaultoverhigh = true,
	walkfwd = true,
	crouchstill = true,
	crouchfwd = true,
	crouchbwd = true
}

local armlock = {
	meleeairhit = true,
	bargein = true,
	wallrunverticalstart = true,
	ladderexittoprighthand = true,
	meleeair = true,
	ladderclimbuplefthand = true,
	ladderexittoplefthand = true,
	ladderenterbottom = true,
	snatchsniper = true,
	ladderclimbuplefthandstill = true,
	ladderclimbuprighthandstill = true,
	wallrunvertical = true,
	ladderclimbdownfast = true,
	ladderclimbuprighthand = true,
	ladderclimbhangstart = true,
	vaultontohigh = true,
	snatchscar = true,
	wallrunright = true,
	wallrunleft = true,
	wallrunrightstart = true,
	wallrunleftstart = true
}

local stillanims = {
	jumpturnlandstandgun = true,
	meslideloop = true,
	jumpturnlandidle = true,
	snatchsniper = true,
	meslidestart = true,
	meslideloop45 = true,
	meslidestart45 = true,
	bargein = true,
	jumpturnflyidle = true,
	jumpturnfly = true,
	jumpturnlandstand = true,
	jumpturnland = true,
	meleeslide = true,
	snatchscar = true
}

local arminterrupts = {
	punchright = true,
	punchleft = true,
	punchmid = true,
	doorbash = true,
	jumpturnflypiecesign = true,
	standhandwallright = true,
	standhandwallleft = true,
	standhandwallboth = true
}

local transitionanims = {
	hanghardstart = "hang",
	divestart = "diveidle",
	ladderexittoplefthand = "runfwd",
	walktostandleft = "stand",
	fallinguncontrolled = "runfwd",
	hangstrafeleft = "hang",
	ladderclimbhangstart = "ladderclimbuprighthandstill",
	hanghardstart2 = "hang",
	meslideend = "runfwd",
	hangfoldedheaveup = "runfwd",
	jumpturnlandstand = "stand",
	ziplinestart = "zipline",
	springboardleftleg = "runfwd",
	hanghardstartvertical = "hang",
	hangstraferight = "hang",
	zipline = "jumpzipline",
	ladderenterbottom = "ladderclimbuplefthandstill",
	hangheaveup = "runfwd",
	dodgejumpleft = "stand",
	walkbalancefalloffleft = "jumpair",
	meleeairhit = "jumpair",
	dodgejumpright = "stand",
	meleeair = "jumpair",
	walkbalancefalloffright = "jumpair",
	swingjumpoff = "jumpslow",
	wallrunverticalstart = "wallrunvertical",
	jumpturnland = "jumpturnlandidle",
	jumpcoilend = "runfwd",
	bargeout = "runfwd",
	jumpturnlandstandgun = "stand",
	meleewrright = "jumpair",
	diveslidestart = "diveslideidle",
	diveslideend = "runfwd",
	hangfoldedendhang = "hang",
	ladderclimbuplefthand = "ladderclimbuplefthandstill",
	jumpturnfly = "jumpturnflyidle",
	meleewrleft = "jumpair",
	meleeslide = "meslideloop",
	stepuprightleg = "runfwd",
	snatchsniper = "stand",
	ladderexittoprighthand = "runfwd",
	meslideendprone = "jumpturnlandidle",
	wallrunverticalturn = "jumpslow",
	ladderclimbuprighthand = "ladderclimbuprighthandstill",
	meleeairstill = "jumpair",
	vaultoverhigh = "runfwd",
	vaultonto = "runfwd",
	vaultover = "jumpair",
	vaultkong = "runfwd",
	vaultontohigh = "runfwd",
	snatchscar = "stand",
	water_swimfwd = "runfwd",
	water_swimright = "runfwd",
	water_swimleft = "runfwd",
	water_swimback = "runfwd",
	water_float = "runfwd"
}

local nospinebend = {
	ladderclimbuplefthand = true,
	divestart = true,
	hang = true,
	hangfoldedheaveup = true,
	ladderexittoprighthand = true,
	ziplinestart = true,
	hangfoldedendhang = true,
	hangstrafeleft = true,
	zipline = true,
	hanghardstart2 = true,
	snatchsniper = true,
	grapplecenter = true,
	hanghardstart = true,
	ladderexittoplefthand = true,
	diveidle = true,
	hanghardstartvertical = true,
	hangstraferight = true,
	hangfoldedstart = true,
	ladderenterbottom = true,
	hangheaveup = true,
	diveslidestart = true,
	ladderclimbuplefthandstill = true,
	ladderclimbuprighthandstill = true,
	diveslideidle = true,
	diveslideend = true,
	wallrunvertical = true,
	ladderclimbdownfast = true,
	ladderclimbuprighthand = true,
	ladderclimbhangstart = true,
	vaultontohigh = true,
	snatchscar = true,
	crouchstill = true,
	crouchfwd = true,
	crouchbwd = true
}

local worldarm = {
	ladderclimbuplefthand = true,
	ladderclimbuplefthandstill = true,
	hanghardstart = true,
	hangfoldedheaveup = true,
	hang = true,
	snatchsniper = true,
	hangfoldedendhang = true,
	hangstrafeleft = true,
	bargein = true,
	hanghardstart2 = true,
	grapplecenter = true,
	diveslidestart = true,
	diveslideidle = true,
	ladderexittoplefthand = true,
	diveslideend = true,
	hanghardstartvertical = true,
	hangstraferight = true,
	hangfoldedstart = true,
	ladderenterbottom = true,
	hangheaveup = true,
	ladderexittoprighthand = true,
	ladderclimbuprighthandstill = true,
	ladderclimbdownfast = true,
	ladderclimbuprighthand = true,
	ladderclimbhangstart = true,
	snatchscar = true,
	jumpturnlandidle = true,
	standhandwallright = true,
	standhandwallleft = true,
	standhandwallboth = true,
	swing = true,
	swingstraight = true
}

local ignorezarm = {
	wallrunvertical = true,
	hangfoldedstart = true,
	hangfoldedendhang = true,
	hangfoldedheaveup = true,
	wallrunverticalstart = true,
	diestandlong = true,
	vaultontohigh = true
}

local nocyclereset = {
	jumpwrright = true,
	jumpwrleft = true,
	meslidestart = true
}

local ignorebac = {
	evaderoll = true,
	meroll = true,
	merollgun = true
}

local customspeed = {
	vaultonto = 1.15,
	vaultontohigh = 1
}

local vaultoverhighcam1 = Vector(0, 0, -7.5)
local vaultoverhighcam2 = Vector(0, 0, 0)
local vaultoverhigharm1 = Vector(4, -4, 13.5)
local vaultoverhigharm2 = Vector(4, 0, -2.5)
local ladderexitarm1 = Vector(-2.5, 0, 0)
local ladderexitarm2 = Vector(-10, 0, 0)
local vaultontohigharm1 = Vector(5, -10, 3.5)
local vaultontohigharm2 = Vector(10, 0, 0)
local snatchscarcam1 = Vector(0, 0, 0)
local snatchscarcam2 = Vector(10, 0, 5)

local customarmoffset = {
	meslidestart = Vector(2, 5, 9.5),
	meslideloop = Vector(2, 5, 9.5),
	meslidestart45 = Vector(2, 5, 5),
	meslideloop45 = Vector(2, 5, 5),
	meslideend = Vector(2, 5, 9.5),
	meslideendprone = Vector(0, 0, 3),
	meleeslide = Vector(2, 5, 9.5),
	jumpturnfly = Vector(0, 2.5, 7.5),
	jumpturnflyidle = Vector(0, 2.5, 7.5),
	jumpturnland = Vector(0, 2.5, 7.5),
	jumpturnlandidle = Vector(0, 2.5, 7.5),
	jumpturnlandstand = Vector(0, 2.5, 7.5),
	jumpturnlandstandgun = Vector(0, 2.5, 7.5),
	wallrunvertical = Vector(0, 0, 5),
	wallrunverticalstart = Vector(0, 0, 5),
	wallrunverticalturn = Vector(0, 0, 5),
	vaultover = Vector(0, 4, -2.5),
	vaultoverhigh = Vector(0, 0, 9.5),
	vaultontohigh = Vector(5, -10, 2.5),
	fallinguncontrolled = Vector(5, 0, 6),
	ladderexittoplefthand = Vector(5, 0, 0),
	ladderexittoprighthand = Vector(5, 0, 0),
	ladderclimbhangstart = Vector(-5, 0, 0),
	ladderenterbottom = Vector(-7.5, 0, 0),
	crouchstill = Vector(-4, 0, -2),
	crouchfwd = Vector(-4, 0, -2),
	crouchbwd = Vector(-4, 0, -2),
	walkfwd = Vector(10, 0, -10),
	runbwd = Vector(0, 0, 3),
	stand = Vector(10, 0, -10),
	walktostandleft = Vector(10, 0, -10)
}

local customcamoffset = {
	jumpturnfly = Vector(0, 0, 7.5),
	jumpturnflyidle = Vector(0, 0, 7.5),
	jumpturnland = Vector(0, 0, 7.5),
	jumpturnlandidle = Vector(0, 0, 7.5),
	jumpturnlandstand = Vector(0, 0, 7.5),
	jumpturnlandstandgun = Vector(0, 0, 7.5),
	meslideendprone = Vector(0, 0, 7.5),
	vaultover = Vector(0, 0, -2.5),
	vaultoverhigh = Vector(0, 0, -7.5),
	ladderexittoplefthand = Vector(-5, 0, 0),
	ladderexittoprighthand = Vector(-5, 0, 0),
	ladderenterbottom = Vector(-5, 0, 0),
	hangstrafeleft = Vector(-2.5, 0, 0),
	hangstraferight = Vector(-2.5, 0, 0),
	snatchscar = snatchscarcam1,
	crouchstill = Vector(2, 0, 2.5),
	crouchfwd = Vector(2, 0, 2.5),
	crouchbwd = Vector(2, 0, 2.5)
}

local transitionchecks = {
	meleeairstill = function(ply)
		if BodyAnimCycle >= 1 or ply:OnGround() then return true end
	end,
	swingjumpoff = function(ply)
		if BodyAnimCycle >= 0.15 or ply:OnGround() then
			BodyAnimCycle = 0

			return true
		end
	end,
	jumpcoilend = function(ply)
		if ply:GetVelocity():Length() < 10 and BodyAnimCycle > 0.5 or BodyAnimCycle > 0.9 then return true end
	end,
	vaultover = function(ply)
		if BodyAnimCycle >= 1 or ply:OnGround() and ply:GetMantle() == 0 then
			BodyLimitX = 90
			BodyLimitY = 180

			return true
		end
	end,
	vaultkong = function(ply)
		if BodyAnimCycle >= 1 or ply:OnGround() and ply:GetMantle() == 0 then
			BodyLimitX = 90
			BodyLimitY = 180

			return true
		end
	end,
	vaultoverhigh = function(ply)
		if BodyAnimCycle < 0.45 then
			customarmoffset.vaultoverhigh = vaultoverhigharm1
			customcamoffset.vaultoverhigh = vaultoverhighcam1
		else
			customarmoffset.vaultoverhigh = vaultoverhigharm2
			customcamoffset.vaultoverhigh = vaultoverhighcam2
		end

		if BodyAnimCycle >= 1 or BodyAnimCycle > 0.75 and ply:OnGround() and ply:GetMantle() == 0 then
			BodyLimitX = 90
			BodyLimitY = 180

			return true
		else
			BodyLimitX = 25
			BodyLimitY = 40
		end
	end,
	vaultontohigh = function(ply)
		if BodyAnimCycle < 0.45 then
			customarmoffset.vaultontohigh = vaultontohigharm1
		else
			customarmoffset.vaultontohigh = vaultontohigharm2
		end

		local ang = ply.OrigEyeAng

		BodyAnim:SetAngles(ang)

		if BodyAnimCycle >= 1 then
			BodyLimitX = 90
			BodyLimitY = 180

			return true
		elseif BodyAnimCycle >= 0.15 then
			BodyLimitX = 10
			BodyLimitY = 45
		else
			BodyLimitX = 10
			BodyLimitY = 0
		end

		if BodyAnimCycle >= 0.45 then
			local eyeang = ply:EyeAngles()
			eyeang.x = 0
			eyeang.z = 0
			ply.OrigEyeAng = eyeang

			BodyAnim:SetAngles(eyeang)
		end
	end,
	zipline = function(ply)
		if not IsValid(ply:GetZipline()) then
			BodyAnimCycle = 0

			return true
		end
	end,
	jumpzipline = function(ply)
		lockang = false
		BodyLimitX = 90
		BodyLimitY = 180
	end,
	stepuprightleg = function(ply)
		if BodyAnimCycle >= 1 then return true end
	end,
	springboardleftleg = function(ply)
		if BodyAnimCycle >= 0.75 or ply:OnGround() then return true end
	end,
	jumpturnlandstand = function(ply)
		if BodyAnimCycle >= 0.85 then
			BodyLimitX = 90
			BodyLimitY = 180

			return true
		end
	end,
	jumpturnlandstandgun = function(ply)
		if BodyAnimCycle >= 0.85 then
			BodyLimitX = 90
			BodyLimitY = 180

			return true
		end
	end,
	fallinguncontrolled = function(ply)
		if not ply.FallStatic then return true end
	end,
	ladderclimbuplefthand = function(ply)
		if BodyAnimCycle >= 0.75 then return true end
	end,
	ladderclimbuprighthand = function(ply)
		if BodyAnimCycle >= 0.75 then return true end
	end,
	ladderenterbottom = function(ply)
		if BodyAnimCycle >= 0.35 then return true end
	end,
	ladderexittoplefthand = function(ply)
		if BodyAnimCycle < 0.25 then
			customarmoffset.ladderexittoplefthand = ladderexitarm1
		else
			customarmoffset.ladderexittoplefthand = ladderexitarm2
		end

		if BodyAnimCycle >= 1 or ply:OnGround() then return true end
	end,
	ladderexittoprighthand = function(ply)
		if BodyAnimCycle < 0.25 then
			customarmoffset.ladderexittoprighthand = ladderexitarm1
		else
			customarmoffset.ladderexittoprighthand = ladderexitarm2
		end

		if BodyAnimCycle >= 1 or ply:OnGround() then return true end
	end,
	wallrunverticalturn = function(ply)
		if ply:GetWallrun() ~= 4 then return true end
	end,
	hangfoldedheaveup = function(ply)
		if BodyAnimCycle >= 0.65 then return true end
	end,
	hanghardstart = function(ply)
		if BodyAnimCycle >= 1 then
			ply.hangyaw = 0

			return true
		end
	end,
	hanghardstart2 = function(ply)
		if BodyAnimCycle >= 0.75 then
			ply.hangyaw = 0

			return true
		end
	end,
	snatchscar = function(ply)
		lockang = true

		if BodyAnimCycle < 0.35 or BodyAnimCycle > 0.8 then
			customcamoffset.snatchscar = snatchscarcam1
		else
			customcamoffset.snatchscar = snatchscarcam2
		end

		if BodyAnimCycle >= 1 then
			lockang = false

			return true
		end
	end,
	snatchsniper = function(ply)
		lockang = true

		if BodyAnimCycle >= 1 then
			lockang = false

			return true
		end
	end,
	ziplinestart = function(ply)
		if BodyAnimCycle >= 0.75 then return true end
	end,
	walkbalancefalloffleft = function(ply)
		lockang = true

		if BodyAnimCycle >= 1 then
			lockang = false

			return true
		end
	end,
	walkbalancefalloffright = function(ply)
		lockang = true

		if BodyAnimCycle >= 1 then
			lockang = false

			return true
		end
	end
}

fbfunctions = {
	vaultontohigh = function(ply) return true end,
	swing = function(ply)
		CamIgnoreAng = false
		BodyLimitY = 45
	end,
	swingstraight = function(ply)
		CamIgnoreAng = false
		BodyLimitY = 45

		BodyAnim:SetPoseParameter("swing", (ply:GetSBOffset() / 45 - 1) * 100)
	end,
	ziplinestart = function(ply)
		if IsValid(ply:GetZipline()) then
			lockang = true
			CamIgnoreAng = false
			BodyLimitX = 30
			BodyLimitY = 90
			local ang = ply.OrigEyeAng

			BodyAnim:SetAngles(ang)
		end

		return true
	end,
	zipline = function(ply)
		lockang = true
		CamIgnoreAng = false
		BodyLimitX = 30
		BodyLimitY = 90
		local ang = ply.OrigEyeAng

		BodyAnim:SetAngles(ang)

		return true
	end,
	hang = function(ply)
		CamIgnoreAng = false
		local ang = ply.OrigEyeAng
		local eyeang = ply:EyeAngles()
		local eyeangx = eyeang.x
		eyeang.x = 0

		BodyAnim:SetAngles(ang)

		local mul = ang:Forward():Dot(eyeang:Forward()) + 1.1
		mul = math.Clamp(mul, 0.4, 1)
		BodyLimitX = 80 * mul
		BodyLimitY = 175

		local a = math.Clamp(math.AngleDifference(ang.y, eyeang.y), -179, 179)

		if not ply.hangyaw then
			ply.hangyaw = 0
		end

		if math.abs(a) < 42 then
			a = 0
		end

		ply.hangyaw = Lerp(FrameTime() * 15, ply.hangyaw, a)
		a = ply.hangyaw

		if IsValid(BodyAnimArmCopy) and IsValid(BodyAnim) then
			BodyAnim:SetPoseParameter("hang_yaw", a)
			BodyAnimArmCopy:SetPoseParameter("hang_yaw", a)

			a = LocalPlayer():EyeAngles().x

			BodyAnim:SetPoseParameter("hang_pitch", a)
			BodyAnimArmCopy:SetPoseParameter("hang_pitch", a)
		end

		if BodyLimitX <= eyeangx then
			eyeang.x = BodyLimitX - 0.1
			ply:SetEyeAngles(eyeang)
		end

		return true
	end,
	hangstrafeleft = function(ply)
		BodyLimitY = 40

		return true
	end,
	hangstraferight = function(ply)
		BodyLimitY = 40

		return true
	end,
	hanghardstartvertical = function(ply)
		BodyLimitX = 30
		BodyLimitY = 120
		local ang = ply.OrigEyeAng

		BodyAnim:SetAngles(ang)

		return true
	end,
	hanghardstart = function(ply)
		BodyLimitX = 30
		BodyLimitY = 120
		local ang = ply.OrigEyeAng

		BodyAnim:SetAngles(ang)

		return true
	end,
	hanghardstart2 = function(ply)
		BodyLimitX = 30
		BodyLimitY = 120
		local ang = ply.OrigEyeAng

		BodyAnim:SetAngles(ang)

		return true
	end,
	hangheaveup = function(ply)
		BodyLimitX = 30
		BodyLimitY = 90
		local ang = ply.OrigEyeAng

		BodyAnim:SetAngles(ang)

		return true
	end,
	hangfoldedstart = function(ply)
		BodyLimitX = 30
		BodyLimitY = 90
		local ang = ply.OrigEyeAng

		BodyAnim:SetAngles(ang)

		return true
	end,
	hangfoldedendhang = function(ply)
		BodyLimitX = 30
		BodyLimitY = 90
		local ang = ply.OrigEyeAng

		BodyAnim:SetAngles(ang)
		ply.hangyaw = 0

		return true
	end,
	hangfoldedheaveup = function(ply)
		BodyLimitX = 30
		BodyLimitY = 90
		local ang = ply.OrigEyeAng

		BodyAnim:SetAngles(ang)

		return true
	end,
	dodgejumpleft = function(ply)
		BodyLimitX = 30
		BodyLimitY = 180
	end,
	dodgejumpright = function(ply)
		BodyLimitX = 30
		BodyLimitY = 180
	end,
	ladderclimbdownfast = function(ply)
		lockang = true
	end
}

local defaultcamoffset = Vector()

local playermodelbones = {"ValveBiped.Bip01_L_UpperArm", "ValveBiped.Bip01_R_UpperArm"}
local fingers = {"ValveBiped.Bip01_L_Finger4", "ValveBiped.Bip01_L_Finger41", "ValveBiped.Bip01_L_Finger3", "ValveBiped.Bip01_L_Finger31", "ValveBiped.Bip01_L_Finger2", "ValveBiped.Bip01_L_Finger21", "ValveBiped.Bip01_L_Finger1", "ValveBiped.Bip01_L_Finger11", "ValveBiped.Bip01_R_Finger4", "ValveBiped.Bip01_R_Finger41", "ValveBiped.Bip01_R_Finger3", "ValveBiped.Bip01_R_Finger31", "ValveBiped.Bip01_R_Finger2", "ValveBiped.Bip01_R_Finger21", "ValveBiped.Bip01_R_Finger1", "ValveBiped.Bip01_R_Finger11"}

local fingerscustom = {
	["ValveBiped.Bip01_L_Finger4"] = Angle(-10, 10, 0),
	["ValveBiped.Bip01_L_Finger3"] = Angle(-10, 20, 0),
	["ValveBiped.Bip01_L_Finger2"] = Angle(0, 20, 0),
	["ValveBiped.Bip01_L_Finger1"] = Angle(10, 20, 0),
	["ValveBiped.Bip01_R_Finger4"] = Angle(30, 10, 0),
	["ValveBiped.Bip01_R_Finger3"] = Angle(20, 20, 0),
	["ValveBiped.Bip01_R_Finger2"] = Angle(10, 20, 0)
}

eventsounds = {
	hangfoldedendhang = {
		[0.42] = "Handsteps.ConcreteHard",
		[0.05] = "Handsteps.ConcreteSoft",
		[0.25] = "Handsteps.ConcreteRelease",
		[0.15] = "Handsteps.ConcreteRelease",
		[0.5] = "Faith.StrainHard"
	},
	hangfoldedheaveup = {
		[0.1] = "Faith.StrainHard"
	},
	hangfoldedstart = {
		[0.1] = "Faith.Impact"
	},
	hangheaveup = {
		[0] = "Faith.StrainMedium"
	},
	vaultontohigh = {
		[0.2] = "Vault",
		[0.05] = "Handsteps.ConcreteHard",
		[0.25] = "Faith.StrainSoft",
		[0.45] = "Footsteps.Concrete",
		[0.5] = "Cloth.MovementRun",
		[0.3] = "Cloth.VaultSwish"
	},
	vaultonto = {
		[0.1] = "Footsteps.Concrete",
		[0.01] = "Handsteps.ConcreteHard",
		[0.025] = "Cloth.MovementRun"
	},
	vaultkong = {
		[0.025] = "Vault"
	},
	snatchscar = {
		[0.35] = "Melee.Foot",
		[0.05] = "Melee.ArmSwoosh",
		[0.1] = "Melee.LegSwoosh",
		[0.15] = "Faith.StrainMedium"
	},
	meleeslide = {
		[0.025] = "Melee.LegSwoosh"
	},
	meleewrleft = {
		[0.035] = "Melee.LegSwoosh",
		[0.075] = "Faith.StrainHard"
	},
	meleewrright = {
		[0.035] = "Melee.LegSwoosh",
		[0.075] = "Faith.StrainHard"
	},
	ladderclimbhangstart = {
		[0] = "Footsteps.LadderHeavy",
		[0.1] = "Land.Ladder"
	},
	ladderclimbuplefthand = {
		[0] = "Release.Ladder",
		[0.15] = "Footsteps.LadderMedium",
		[0.2] = "Handsteps.Ladder"
	},
	ladderclimbuprighthand = {
		[0] = "Release.Ladder",
		[0.15] = "Footsteps.LadderMedium",
		[0.2] = "Handsteps.Ladder"
	},
	ladderexittoplefthand = {
		[0.45] = "Release.Ladder",
		[0.1] = "Handsteps.Ladder",
		[0.5] = "Release.Ladder",
		[0.15] = "Handsteps.Ladder"
	},
	ladderexittoprighthand = {
		[0.45] = "Release.Ladder",
		[0.1] = "Handsteps.Ladder",
		[0.5] = "Release.Ladder",
		[0.15] = "Handsteps.Ladder"
	},
	jumpturnlandstand = {
		[0.025] = "me_faith_cloth_roll_cloth.wav",
		[0.25] = "Faith.StrainSoft",
		[0.3] = "me_body_roll.wav"
	}
}

local CharaName = "Faith"

local function BodyEventSounds(anim)
	local tbl = eventsounds[anim]

	if tbl then
		local ply = LocalPlayer()

		for k, v in pairs(tbl) do
			local func = nil

			if v:Left(#CharaName) == CharaName then
				func = ply.FaithVO
			else
				func = ply.EmitSound
			end

			timer.Simple(k, function()
				func(ply, v)
			end)
		end
	end
end

camint = 1
campos = Vector()
camang = Angle()
-- local customoffset = Vector()
-- local movedback = false
local customoffsetlerp = Vector()

local function JumpCalcView(view)
	if not fbanims[BodyAnimString] then
		hook.Remove("BodyAnimCalcView", "JumpCalcView")
		hook.Remove("BodyAnimDrawArm", "JumpArmThink")
		hook.Remove("PostDrawOpaqueRenderables", "JumpArmDraw")

		if IsValid(BodyAnimArmCopy) then
			BodyAnimArmCopy:Remove()
		end
	end

	-- local eyepos = LocalPlayer():EyePos()
	-- local vieworigin = view.origin

	BodyAnim:SetupBones()

	local m = BodyAnim:GetBoneMatrix(68)
	local ang = nil -- local pos, ang = nil

	if m then
		ang = m:GetAngles()
		pos = m:GetTranslation()
	end

	if IsValid(ang) then
		ang:Sub(view.angles)
		ang:Mul(camint)
		view.angles:Add(ang)
	end

	customoffsetlerp = LerpVector(math.min(10 * FrameTime(), 1), customoffsetlerp, customcamoffset[BodyAnimString] or defaultcamoffset)
	campos = view.origin
	camang = view.angles

	campos:Add(LocalToWorld(customoffsetlerp, angle_zero, vector_origin, BodyAnim:GetAngles()))

	if IsValid(BodyAnim) and jumpanims[BodyAnimString] and BodyAnimCycle >= 1 then
		BodyAnim:SetSequence(BodyAnim:LookupSequence("jumpidle"))
	end
end

local function CreateBodyAnimArmCopy()
	if not IsValid(BodyAnimArmCopy) and IsValid(BodyAnim) and not ignorebac[BodyAnimString] then
		local ply = LocalPlayer()
		BodyAnimArmCopy = ClientsideModel("models/" .. BodyAnimMDLString .. ".mdl", RENDERGROUP_BOTH)
		local seq = BodyAnim:GetSequence()

		if seq then
			BodyAnimArmCopy:SetSequence(seq)
		end

		for num, _ in pairs(BodyAnim:GetBodyGroups()) do
			BodyAnimArmCopy:SetBodygroup(num - 1, BodyAnim:GetBodygroup(num - 1))
			BodyAnimArmCopy:SetSkin(BodyAnim:GetSkin())
		end

		for k, v in ipairs(fingers) do
			local b = BodyAnimArmCopy:LookupBone(v)

			if b then
				BodyAnimArmCopy:ManipulateBoneAngles(b, Angle(0, 30, 0))
			end
		end

		for k, v in pairs(fingerscustom) do
			local b = BodyAnimArmCopy:LookupBone(k)

			if b then
				BodyAnimArmCopy:ManipulateBoneAngles(b, v)
			end
		end

		ply.BAC = BodyAnimArmCopy
	end

	return BodyAnimArmCopy
end

hook.Add("BodyAnimRemove", "BodyAnimArmRemove", function()
	if IsValid(BodyAnimArmCopy) then
		BodyAnimArmCopy:Remove()
	end
end)

local function JumpArmThink()
	local bac = CreateBodyAnimArmCopy()

	if IsValid(bac) then return true end
end

function ArmInterrupting(bac)
	return IsValid(bac) and arminterrupts[bac:GetSequenceName(bac:GetSequence())]
end

local defaultarmoffset = Vector()
local armoffset = Vector()
local armoffsetlerp = Vector()
-- local drawnorigin = false
local drawnskytime = 0

local function JumpArmDraw(a, b, c)
	local bac = CreateBodyAnimArmCopy()

	if IsValid(bac) and not LocalPlayer():ShouldDrawLocalPlayer() and IsValid(BodyAnim) and not c then
		local ply = LocalPlayer()
		local ang = ply:EyeAngles()
		ang.z = 0

		if not nospinebend[BodyAnimString] then
			BodyAnim:ManipulateBoneAngles(1, Angle(0, math.max(ang.x * 0.5, 0), 0))
		else
			BodyAnim:ManipulateBoneAngles(1, angle_zero)
		end

		cam.IgnoreZ(true)

		-- local camposoff = campos - ply:EyePos()
		local attachId = bac:LookupAttachment("eyes")
		local offset = bac:GetAttachment(attachId)

		if not offset then return end

		local arminterrupting = ArmInterrupting(bac)
		local arminterruptboost = arminterrupting and 4 or 1

		armoffsetlerp = LerpVector(math.min(10 * FrameTime() * arminterruptboost, 1), armoffsetlerp, not arminterrupting and customarmoffset[BodyAnimString] or defaultarmoffset)
		armoffset:Set(armoffsetlerp)

		local pos = offset.Pos
		local ang = offset.Ang

		if not IsValid(BodyAnimMDLarm) then return end

		BodyAnimMDLarm:SetNoDraw(true)
		bac:SetParent(nil)
		bac:SetAngles(angle_zero)
		bac:SetPos(Vector(0, 0, -64))

		if not worldarm[BodyAnimString] then
			bac:SetRenderOrigin(bac:GetPos())
		end

		BodyAnimMDLarm:SetParent(bac)

		if not ply.armfollowlerp then
			ply.armfollowlerp = 0
		end

		if armfollowanims[BodyAnimString] and not ArmInterrupting(bac) then
			ang.x = ply.armfollowlerp < 1 and Lerp(ply.armfollowlerp, 0, ply:EyeAngles().x) or ply:EyeAngles().x
			ply.armfollowlerp = math.Approach(ply.armfollowlerp, 1, FrameTime() * 1.5)
		elseif armlock[BodyAnimString] then
			ang.x = ply:EyeAngles().x
			ang.y = ply:EyeAngles().y - ply.OrigEyeAng.y
		else
			ang.x = ply.armfollowlerp > 0 and Lerp(ply.armfollowlerp, 0, ply:EyeAngles().x) or 0
			ang.y = 0
			ply.armfollowlerp = math.Approach(ply.armfollowlerp, 0, FrameTime() * 2.5 * arminterruptboost)
		end

		pos:Add(armoffset)
		pos:Add(customoffsetlerp)
		ang:Add(ViewTiltAngle)

		if CamShake then
			ang:Add(CamShakeAng)
		end

		local activewep = ply:GetActiveWeapon()

		if ply:UsingRH() then
			if not worldarm[BodyAnimString] then
				cam.Start3D(pos, ang)
					cam.IgnoreZ(ignorezarm[BodyAnimString] or false)

					BodyAnimMDLarm:SetPos(pos)
					bac:SetupBones()
					BodyAnimMDLarm:DrawModel()
				cam.End3D()
			else
				local armoff = LocalToWorld(armoffset, angle_zero, vector_origin, BodyAnim:GetAngles())

				cam.IgnoreZ(ignorezarm[BodyAnimString] or false)
				bac:SetAngles(BodyAnim:GetAngles())
				bac:SetPos(BodyAnim:GetPos() + armoff)
				bac:SetRenderOrigin(nil)

				BodyAnimMDLarm:SetPos(BodyAnim:GetPos() + armoff)
				bac:SetupBones()
				BodyAnimMDLarm:DrawModel()
			end
		elseif IsValid(activewep) then
			ply:DrawViewModel(true)
			ply:GetViewModel():SetNoDraw(false)
		end

		cam.IgnoreZ(false)

		local seq = BodyAnim:GetSequence()

		if seq and (not arminterrupts[bac:GetSequenceName(bac:GetSequence())] or bac:GetCycle() >= 1) then
			if bac:GetSequence() ~= seq then
				for k, v in ipairs(fingers) do
					local b = bac:LookupBone(v)

					if b then
						bac:ManipulateBoneAngles(b, Angle(0, 30, 0))
					end
				end

				for k, v in pairs(fingerscustom) do
					local b = bac:LookupBone(k)

					if b then
						bac:ManipulateBoneAngles(b, v)
					end
				end
			end

			bac:SetSequence(seq)
			bac:SetCycle(BodyAnim:GetCycle() or 1)
		elseif seq and drawnskytime < CurTime() then
			bac:SetCycle(bac:GetCycle() + FrameTime() / bac:SequenceDuration())
		end

		if (not b or not skybox3d) and not worldarm[BodyAnimString] then
			bac:SetRenderOrigin(campos)

			drawnorigin = true
		end

		drawnskytime = CurTime()
	end
end

hook.Add("PreRender", "JumpArmOriginVar", function()
	drawnorigin = false
end)

hook.Add("PostDrawSkyBox", "JumpArm3DSky", function()
	skybox3d = true

	hook.Remove("PostDrawSkyBox", "JumpArm3DSky")
end)

hook.Add("CalcViewModelView", "lol", function(wep, vm, oldpos, oldang, pos, ang)
	if has_tool_equipped then return end

	pos:Sub(oldpos)
	pos:Add(campos)
	ang:Sub(oldang)
	ang:Add(camang)

	if wep.m_ViewModel then
		local vmoffsets = wep.ViewModelVars
		local lerpaimpos = vmoffsets.LerpAimPos
		lerpaimpos.y = 0
		local cpos, cang = LocalToWorld(vector_origin, angle_zero, lerpaimpos, vmoffsets.LerpAimAngles)

		pos:Add(cpos)
		ang:Add(cang)

		wep.m_ViewModel:SetRenderOrigin(pos)
		wep.m_ViewModel:SetAngles(ang)
	end
end)

local function JumpAnim(event, ply)
	if events[event] then
		local wasjumpanim = fbanims[BodyAnimString] and IsValid(BodyAnim)

		if not wasjumpanim then
			RemoveBodyAnim()
		end

		if event == "jump" or event == "jumpfar" or event:Left(11) == "jumpwallrun" and ply:GetWallrunDir():Dot(ply:EyeAngles():Forward()) < 0.75 then
			if event == "jumpfar" then
				animtable.AnimString = "jumpfast"
			else
				animtable.AnimString = "jumpslow"
			end

			lockang = false
			CamIgnoreAng = true
			BodyLimitX = 90
			BodyLimitY = 180
		else
			BodyAnimCycle = 0
			animtable.AnimString = eventslut[event]
		end

		BodyAnimString = animtable.AnimString

		BodyEventSounds(BodyAnimString)

		if not nocyclereset[BodyAnimString] then
			BodyAnimCycle = 0
		end

		if not wasjumpanim then
			CheckAnims()

			StartBodyAnim(animtable)

			if not IsValid(BodyAnim) then return end

			CreateBodyAnimArmCopy()

			if not ply:ShouldDrawLocalPlayer() or CurTime() < 10 then
				for k, v in ipairs(playermodelbones) do
					local b = BodyAnim:LookupBone(v)

					if b then
						BodyAnim:ManipulateBonePosition(b, Vector(0, 0, 100 * (k == 1 and -1 or 1)))
					end
				end
			end

			hook.Add("BodyAnimCalcView", "JumpCalcView", JumpCalcView)
			hook.Add("BodyAnimDrawArm", "JumpArmThink", JumpArmThink)
			hook.Add("PostDrawOpaqueRenderables", "JumpArmDraw", JumpArmDraw)
		else
			BodyAnim:ResetSequence(BodyAnim:LookupSequence(BodyAnimString))
		end
	end
end

function CheckAnims()
	RemoveBodyAnim()

	if OldAnims:GetBool() then
		animtable.animmodelstring = "old_climbanim"
	else
		animtable.animmodelstring = "new_climbanim"
	end

	StartBodyAnim(animtable)

	if not IsValid(BodyAnim) then return end

	CreateBodyAnimArmCopy()

	if not LocalPlayer():ShouldDrawLocalPlayer() or CurTime() < 10 then
		for k, v in ipairs(playermodelbones) do
			local b = BodyAnim:LookupBone(v)

			if b then
				BodyAnim:ManipulateBonePosition(b, Vector(0, 0, 100 * (k == 1 and -1 or 1)))
			end
		end
	end
end

cvars.AddChangeCallback("Beatrun_OldAnims", function(cvar, vOld, vNew)
	CheckAnims()
end)

hook.Add("PlayerInitialSpawn", "CheckAnims", CheckAnims)
hook.Add("OnParkour", "JumpAnim", JumpAnim)

function ArmInterrupt(anim)
	if arminterrupts[anim] then
		local arm = CreateBodyAnimArmCopy()

		if IsValid(arm) then
			for _, v in ipairs(fingers) do
				local b = BodyAnimArmCopy:LookupBone(v)

				if b then
					arm:ManipulateBoneAngles(b, angle_zero)
				end
			end

			for k, _ in pairs(fingerscustom) do
				local b = BodyAnimArmCopy:LookupBone(k)

				if b then
					arm:ManipulateBoneAngles(b, angle_zero)
				end
			end

			--[[ TODO: make work good
			if string.match(anim, "standhandwall") then
				local ply = LocalPlayer()
				local trace = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 30, ply)
				local x = trace.Normal.x < 0.6 and trace.Normal.x or trace.Normal.y
				local y = trace.Normal.y > -0.8 and trace.Normal.y or -trace.Normal.x

				local newAng = Angle(x * (5 * trace.Fraction * x), 0, x * (10 * trace.Fraction * y))

				ply:ChatPrint("Fraction: " .. tostring(trace.Fraction))
				ply:ChatPrint("Normal: " .. tostring(trace.Normal))

				arm:SetAngles(newAng)
			end
			--]]

			arm:SetSequence(anim)
			arm:SetCycle(0)
		end
	end
end

local lastwr = 0

hook.Add("Think", "FBAnimHandler", function()
	local ply = LocalPlayer()

	if not IsValid(BodyAnim) and ply:Alive() then
		JumpAnim("fall", ply)

		camjoint = "eyes"
		BodyAnimSpeed = 1
		BodyLimitX = 90
		BodyLimitY = 180
	end

	if ply:GetWallrun() >= 2 then
		BodyLimitY = 95
	end

	if ply:GetWallrun() == 0 and lastwr > 0 then
		BodyLimitY = 180
	end

	lastwr = ply:GetWallrun()
end)

local animtr, animtr_result = nil, nil
local oldnewang = Angle()

local function JumpThink()
	if IsValid(BodyAnim) then
		if not animtr then
			animtr = {}
			animtr_result = {}
			animtr.filter = ply
			animtr.output = animtr_result
		end

		local lastBAString = BodyAnimString
		BodyAnimString = BodyAnim:GetSequenceName(BodyAnim:GetSequence())

		if fbanims[BodyAnimString] then
			local ply = LocalPlayer()

			if jumpanims[BodyAnimString] and (ply:OnGround() or ply:GetWallrun() ~= 0 or ply:GetMantle() ~= 0) then
				BodyAnim:SetSequence(BodyAnim:LookupSequence("runfwd"))
				BodyAnimCycle = 0
			end

			local ang = ply:EyeAngles()
			ang[1] = 0

			animtr.start = ply:GetPos()

			local angold = ang
			local lerpspeed = 10
			local vel = LocalPlayer():GetVelocity()
			local vel_l = vel:Length()
			local moving = ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT)
			local back = ply:KeyDown(IN_BACK)

			if runanims[BodyAnimString] then
				if lastBAString == "stand" and vel_l > 0 then
					BodyAnimCycle = ply:GetStepRight() and 0.5 or 0
				end

				lockang = false
				CamIgnoreAng = true
				BodyLimitX = 90
				BodyLimitY = 180
				vel.z = 0

				if back and vel_l > 10 then
					ang = vel:Angle()

					if ang:Forward():Dot(angold:Forward()) < 0 then
						ang:RotateAroundAxis(Vector(0, 0, 1), 180)
					end

					BodyAnimSpeed = math.Clamp(vel_l / 150, 0.1, 0.8)
					lerpspeed = 300
					moveback = true

					if not ply:Crouching() then
						BodyAnim:SetSequence(BodyAnim:LookupSequence("runbwd"))
					else
						BodyAnim:SetSequence(BodyAnim:LookupSequence("crouchbwd"))
					end
				elseif vel_l > 0 and moving then
					ang = vel:Angle()

					if moveback then
						ang:RotateAroundAxis(Vector(0, 0, 1), -180)

						if ply:KeyDown(IN_FORWARD) then
							moveback = false
						elseif ply:Crouching() and moveback then
							BodyAnim:SetSequence(BodyAnim:LookupSequence("crouchbwd"))
						else
							BodyAnim:SetSequence(BodyAnim:LookupSequence("runbwd"))
						end
					end

					if ply:InOverdrive() then
						BodyAnimSpeed = math.Clamp(vel_l / 320, 0.85, 1.5)
					else
						local dot = ang:Forward():Dot(angold:Forward())

						if dot < 0 then
							ang:RotateAroundAxis(Vector(0, 0, 1), 180 * math.abs(dot))
						end

						if vel_l > 295 then
							BodyAnimSpeed = math.Clamp(vel_l / 300, 0.85, 1)
						elseif moveback then
							BodyAnimSpeed = math.Clamp(vel_l / 150, 0.1, 0.8)
						else
							BodyAnimSpeed = math.Clamp(vel_l / 255, 0.85, 1.15)
						end
					end

					lerpspeed = 30

					if vel:Length() > 300 and ply:OnGround() then
						-- if ply:InOverdrive() and BodyAnimString ~= "sprintfwd" and vel:Length() < 300 then
						-- 	ply:EmitSound("CyborgRun")
						-- end

						BodyAnim:SetSequence(BodyAnim:LookupSequence("sprintfwd"))
					elseif ply:OnGround() and not moveback then
						if not ply:Crouching() then
							if ply:KeyDown(IN_WALK) or vel:Length() < 150 then
								BodyAnim:SetSequence(BodyAnim:LookupSequence("walkfwd"))
							else
								BodyAnim:SetSequence(BodyAnim:LookupSequence("runfwd"))
							end
						else
							BodyAnim:SetSequence(BodyAnim:LookupSequence("crouchfwd"))
						end
					end
				else
					if not ply:Crouching() and BodyAnimString:Left(6) == "crouch" or BodyAnimString == "walkfwd" or BodyAnimString == "runfwd" or BodyAnimString == "sprintfwd" or BodyAnimString == "runbwd" then
						BodyAnimCycle = 0

						BodyAnim:SetSequence(BodyAnim:LookupSequence("walktostandleft"))
					end

					if (BodyAnimString == "stand" or BodyAnimString == "walktostandleft" or BodyAnimString == "jumpcoilend") and ply:Crouching() or BodyAnimString == "crouchfwd" or BodyAnimString == "crouchbwd" then
						BodyAnimCycle = 0

						BodyAnim:SetSequence(BodyAnim:LookupSequence("crouchstill"))
					end
				end

				if vel_l < 64 then
					ang = angold
				end
			else
				lerpspeed = 10
				BodyAnimSpeed = customspeed[BodyAnimString] or animtable.BodyAnimSpeed
			end

			if jumpanims2[BodyAnimString] and vel.z < -5 then
				local pos = ply:GetPos()
				local groundcheck = Vector(0, 0, -35)

				groundcheck:Add(pos)

				animtr.start = pos
				animtr.endpos = groundcheck
				animtr.filter = ply

				util.TraceLine(animtr)

				if animtr_result.Hit then
					BodyAnim:SetSequence("jumpidle")
				end
			end

			if ply:GetWallrun() >= 2 and ply:GetWallrun() < 4 and ply:GetMelee() == 0 then
				vel.z = 0
				ang = vel:Angle()
				CamIgnoreAng = false
				local bs = ply:GetWallrun() == 2 and "wallrunrightstart" or "wallrunleftstart"
				local bl = ply:GetWallrun() == 2 and "wallrunright" or "wallrunleft"

				if BodyAnimString == bs and BodyAnimCycle >= 1 then
					BodyAnim:SetSequence(BodyAnim:LookupSequence(bl))

					BodyAnimSpeed = 1.5
				elseif BodyAnimString ~= bl then
					BodyAnim:SetSequence(BodyAnim:LookupSequence(bs))
				end
			elseif BodyAnimString == "wallrunright" or BodyAnimString == "wallrunleft" or BodyAnimString == "wallrunrightstart" or BodyAnimString == "wallrunleftstart" then
				BodyAnimCycle = 0

				BodyAnim:SetSequence(BodyAnim:LookupSequence("jumpair"))
			end

			if BodyAnimString == "jumpturnfly" or BodyAnimString == "jumpturnflyidle" then
				if ply:GetQuickturn() then
					BodyAnim:SetAngles(ang + Angle(0, 6.5, 0))

					ply.OrigEyeAng = ang
				end

				if ply:OnGround() then
					BodyAnimCycle = 0

					BodyAnim:SetSequence("jumpturnland")
					ply:EmitSound("Cloth.FallShortHard")
					ply:FaithVO("Faith.Impact")
					DoImpactBlur(6)
				end
			elseif (BodyAnimString == "jumpturnland" or BodyAnimString == "jumpturnlandidle" or BodyAnimString == "jumpturnlandstand" or BodyAnimString == "jumpturnlandstandgun") and not ply:OnGround() and ply:GetMoveType() ~= MOVETYPE_NOCLIP and ply:WaterLevel() < 3 then
				BodyAnimCycle = 0

				BodyAnim:SetSequence("jumpturnflyidle")
			end

			if ply:GetSliding() then
				ang = vel:Angle()
			end

			local check = transitionchecks[BodyAnimString]

			if check and check(ply) or not check and BodyAnimCycle >= 0.9 and transitionanims[BodyAnimString] then
				BodyAnim:SetSequence(transitionanims[BodyAnimString])
			end

			if ply:WaterLevel() >= 2 and not ply:Crouching() and not ply:OnGround() and ply:GetMoveType() ~= MOVETYPE_NOCLIP then
				BodyAnim:SetSequence(BodyAnim:LookupSequence("water_float"))

				if ply:KeyDown(IN_MOVELEFT) and vel_l > 5 then
					BodyAnim:SetSequence(BodyAnim:LookupSequence("water_swimleft"))
				elseif ply:KeyDown(IN_MOVERIGHT) and vel_l > 5 then
					BodyAnim:SetSequence(BodyAnim:LookupSequence("water_swimright"))
				elseif ply:KeyDown(IN_FORWARD) and vel_l > 5 then
					BodyAnim:SetSequence(BodyAnim:LookupSequence("water_swimfwd"))
				elseif ply:KeyDown(IN_BACK) and vel_l > 5 then
					BodyAnim:SetSequence(BodyAnim:LookupSequence("water_swimback"))
				end
			end

			if BodyAnimString == "wallrunverticalstart" or BodyAnimString == "wallrunvertical" then
				ang = ply.WallrunOrigAng or ang
				BodyAnimSpeed = 1.2 * math.Clamp((LocalPlayer():GetWallrunTime() - CurTime()) / 1.2, 0.5, 1)
			end

			if BodyAnimString == "vaultover" or BodyAnimString == "vaultkong" or BodyAnimString == "stepuprightleg" or BodyAnimString == "vaultonto" then
				if BodyAnimCycle < 0.65 then
					local target = ply:GetMantleEndPos() - ply:GetMantleStartPos()
					target.z = 0
					target = target:Angle()
					ang = target or ang

					if BodyAnimString == "vaultover" or BodyAnimString == "vaultkong" or BodyAnimString == "vaultonto" then
						BodyLimitX = 15
						BodyLimitY = 70

						if BodyAnimString == "vaultkong" then
							BodyLimitX = 25
						end
					end
				else
					BodyLimitX = 90
					BodyLimitY = 180
				end
			end

			if BodyAnimString == "wallrunverticalturn" then
				BodyAnimSpeed = 1.5
				ang = ply:EyeAngles()
				ang.x = 0
				ang.z = 0

				BodyAnim:SetAngles(ang)

				ply.OrigEyeAng = ang

				return
			end

			if BodyAnimString:Left(6) == "ladder" and BodyAnimString ~= "ladderclimbdownfast" then
				BodyLimitX = 25
				BodyLimitY = 90
				ang = ply.OrigEyeAng

				BodyAnim:SetAngles(ang)

				CamIgnoreAng = false
				lockang = false

				return
			end

			local func = fbfunctions[BodyAnimString]
			func = func and func(ply)

			if func == true then return end

			if ply:GetMantle() == 4 then
				BodyAnim:SetSequence("vaultoverhigh")

				return
			end

			if ply:GetMantle() == 5 then
				BodyAnim:SetSequence("vaultontohigh")

				return
			end

			if not stillanims[BodyAnimString] then
				local speed = vel_l > 5 and math.min(vel_l / 200, 1) or 1
				local newang = LerpAngle(math.min(lerpspeed * FrameTime() * speed, 1), BodyAnim:GetAngles(), ang)
				local ang = ply:EyeAngles()
				ang[1] = 0
				ang[3] = 0

				if vel_l > 0 or BodyAnimString == "walktostandleft" or ply:Crouching() or IsValid(ply:GetBalanceEntity()) then
					if newang:Forward():Dot(ang:Forward()) > -0.25 then
						ply.OrigEyeAng = newang

						BodyAnim:SetAngles(newang)
						oldnewang:Set(BodyAnim:GetAngles())
					else
						oldnewang:Set(LerpAngle(FrameTime() * 8, oldnewang, ang))

						ply.OrigEyeAng = Angle(oldnewang)

						BodyAnim:SetAngles(oldnewang)
					end
				elseif newang:Forward():Dot(ang:Forward()) < 0.25 then
					local stepmat = ply.LastStepMat or game.SinglePlayer() and ply:GetNW2String("LastStepMat", "Concrete") or "Concrete"
					BodyAnimCycle = 0

					BodyAnim:SetSequence(BodyAnim:LookupSequence("walktostandleft"))
					ply:EmitSound("Release." .. stepmat)

					timer.Simple(0.15, function()
						ply:EmitSound("Footsteps." .. stepmat)
					end)
				end
			end
		end
	end
end

hook.Add("Think", "JumpThink", JumpThink)

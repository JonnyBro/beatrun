local coursepanel = {
	w = 900,
	h = 650
}

coursepanel.x = 950 - coursepanel.w * 0.5
coursepanel.y = 550 - coursepanel.h * 0.5
coursepanel.bgcolor = Color(32, 32, 32)
coursepanel.outlinecolor = Color(54, 55, 56)
coursepanel.alpha = 0.9
coursepanel.elements = {}

local function sacheck()
	return not LocalPlayer():IsSuperAdmin()
end

local function stopbutton()
	net.Start("Course_Stop")
	net.SendToServer()
end

local function buildmodebutton()
	AEUI:Clear()

	LocalPlayer():ConCommand("buildmode")
end

AEUI:Text(coursepanel, language.GetPhrase("beatrun.coursemenu.trials"):format(string.Replace(game.GetMap(), " ", "-")), "AEUIVeryLarge", 20, 30)

local buildmodebutton = AEUI:AddButton(coursepanel, "#beatrun.coursemenu.buildmode", buildmodebutton, "AEUILarge", coursepanel.w - 400, coursepanel.h - 50)
buildmodebutton.greyed = sacheck

local stopbutton = AEUI:AddButton(coursepanel, "#beatrun.coursemenu.freeplay", stopbutton, "AEUILarge", coursepanel.w - 750, coursepanel.h - 50)
stopbutton.greyed = sacheck

local courselist = {
	w = 800,
	h = 450,
	x = 1000 - coursepanel.w * 0.5,
	y = 648 - coursepanel.h * 0.5,
	bgcolor = Color(32, 32, 32),
	outlinecolor = Color(54, 55, 56),
	alpha = 0.9,
	elements = {}
}

local function closebutton()
	AEUI:RemovePanel(courselist)
	AEUI:RemovePanel(coursepanel)
end

AEUI:AddButton(coursepanel, "  X  ", closebutton, "AEUILarge", coursepanel.w - 47, 0)

function OpenCourseMenu()
	AEUI:AddPanel(coursepanel)
	AEUI:AddPanel(courselist)

	local dir = "beatrun/courses/" .. string.Replace(game.GetMap(), " ", "-") .. "/"
	local dirsearch = dir .. "*.txt"
	local files = file.Find(dirsearch, "DATA", "datedesc")

	if BEATRUN_DEBUG then PrintTable(files) end

	table.Empty(courselist.elements)

	for _, v in pairs(files) do
		local data = file.Read(dir .. v, "DATA")
		local course = util.Decompress(data) or data

		if course then
			local coursetable = util.JSONToTable(course)
			local filename = v:Split(".txt")[1]
			local courseid = util.CRC(course)
			local courseentry = AEUI:Text(courselist, coursetable[5] and coursetable[5] .. " (" .. courseid .. ")" or "ERROR", "AEUILarge", 10, 40 * #courselist.elements)

			function courseentry:onclick()
				LocalPlayer():EmitSound("buttonclick.wav")
				LoadCourse(filename)

				AEUI:RemovePanel(courselist)
				AEUI:RemovePanel(coursepanel)
			end

			courseentry.greyed = sacheck
		end
	end
end

hook.Add("InitPostEntity", "CourseMenuCommand", function()
	concommand.Add("Beatrun_CourseMenu", OpenCourseMenu)
	hook.Remove("InitPostEntity", "CourseMenuCommand")
end)

concommand.Add("Beatrun_CourseMenu", OpenCourseMenu)
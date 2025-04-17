net.Receive("DeathStopSound", function()
	if not blinded then
		RunConsoleCommand("stopsound")

		if LocalPlayer():GetPos().z < -2200 then
			timer.Simple(0.011, function()
				RunConsoleCommand("stopsound")
			end)

			timer.Simple(0.02, function()
				LocalPlayer():EmitSound("enterwater_highvelocity_0" .. math.random(1, 2) .. ".wav")
			end)

			timer.Simple(0.02, function()
				local rag = LocalPlayer():GetRagdollEntity()

				if IsValid(rag) then
					for i = 0, rag:GetPhysicsObjectCount() - 1 do
						local phys = rag:GetPhysicsObjectNum(i)

						phys:EnableMotion(false)
					end
				end
			end)
		end
	end
end)
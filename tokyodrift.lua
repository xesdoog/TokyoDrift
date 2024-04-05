---@diagnostic disable: undefined-global, lowercase-global

tokyodrift = gui.get_tab("GUI_TAB_VEHICLE"):add_tab("Tokyo Drift")
script.register_looped("vars", function(vars)
    if NETWORK.NETWORK_IS_SESSION_ACTIVE() then
        is_online = true
    else
        is_online = false
    end
    if PED.IS_PED_IN_ANY_VEHICLE(self.get_ped()) then
        current_vehicle = PED.GET_VEHICLE_PED_IS_USING(self.get_ped())
        is_car = VEHICLE.IS_THIS_MODEL_A_CAR(ENTITY.GET_ENTITY_MODEL(current_vehicle))
    end
    vars:yield()
end)
local ShiftDrift = false
local DriftIntensity = 0
local DriftTires = false
local function resettokyodrift()
    DriftTires = false
    ShiftDrift = false
    DriftIntensity = 0
    shiftDriftToggled = false
end
tokyodrift:add_imgui(function()
manufacturer = VEHICLE.GET_MAKE_NAME_FROM_VEHICLE_MODEL(ENTITY.GET_ENTITY_MODEL(current_vehicle))
mfr_name = (manufacturer:lower():gsub("^%l", string.upper))
vehicle_name = vehicles.get_vehicle_display_name(ENTITY.GET_ENTITY_MODEL(current_vehicle))
    if PED.IS_PED_IN_ANY_VEHICLE(self.get_ped(), true) and is_car then
        ImGui.Text("Vehicle: "..mfr_name.." "..vehicle_name)
        ImGui.Spacing()
        ShiftDrift, shiftDriftToggled = ImGui.Checkbox("Activate Tokyo Drift", ShiftDrift, true)
        ImGui.SameLine()
        ImGui.TextDisabled("(?)")
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Hold [Left Shift] to drift")
            ImGui.EndTooltip()
        end
        if shiftDriftToggled then
            if not ShiftDrift then
                DriftTires = false
            end
        end
        DriftTires, driftTyresToggled = ImGui.Checkbox("Use Low Grip Tires", DriftTires, true)
        ImGui.SameLine()
        ImGui.TextDisabled("(?)")
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("This will use GTA 5's low grip tires instead.")
            ImGui.EndTooltip()
        end
        if not DriftTires then
            ImGui.Spacing()
            ImGui.Text("Intensity:")
            ImGui.PushItemWidth(250)
            DriftIntensity, DriftIntensityUsed = ImGui.SliderInt("##Intensity", DriftIntensity, 0, 3)
            if ImGui.IsItemHovered() then
                ImGui.BeginTooltip()
                ImGui.Text("0: No Grip (very stiff).\n1: Balanced (Recommended).\n2: Weak Drift.\n3: Weakest Drift.")
                ImGui.EndTooltip()
            end
            ImGui.PopItemWidth()
        end
    elseif PED.IS_PED_IN_ANY_VEHICLE(self.get_ped(), true) and not is_car then
        ImGui.Text("Tokyo Drift only works on cars and trucks.")
    else
        ImGui.Text("Get in a vehicle before using the script!")
    end
    ImGui.Spacing() ImGui.Spacing() ImGui.Spacing() ImGui.Spacing() ImGui.Spacing() ImGui.Spacing()
    ImGui.Separator()
    if ImGui.Button("-- Credits --") then
        ImGui.OpenPopup("Credits")
    end
    ImGui.SetNextWindowPos(600, 400, ImGuiCond.Appearing)
    ImGui.SetNextWindowBgAlpha(0.6)
    if ImGui.BeginPopupModal("Credits", true, ImGuiWindowFlags.AlwaysAutoResize | ImGuiWindowFlags.NoMove) then
        ImGui.Text("Original script [Shift-Drift], made by Harmless05\nand tweaked by SAMURAI (xesdoog).")
        ImGui.Text("Visit Harmless's profile on Github:")
        ImGui.Indent()
        ImGui.TextColored(0.25, 0.65, 0.96, 0.8, "https://github.com/Harmless05")
        ImGui.Unindent()
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Click to copy link")
            ImGui.EndTooltip()
        end
        if ImGui.IsItemHovered() and ImGui.IsItemClicked(0) then
            ImGui.SetClipboardText("https://github.com/Harmless05")
            gui.show_message("Tokyo Drift", "Copied \"https://github.com/Harmless05\" to clipboard!")
            log.info("Copied \"https://github.com/Harmless05\" to clipboard!")
        end
        -- ImGui.Text("Checkout Harmless-Scripts:")
        -- ImGui.BulletText("https://github.com/YimMenu-Lua/Harmless-Scripts")
        -- if ImGui.IsItemHovered() then
        --     ImGui.BeginTooltip()
        --     ImGui.Text("Click to copy link")
        --     ImGui.EndTooltip()
        -- end
        -- if ImGui.IsItemHovered() and ImGui.IsItemClicked(0) then
        --     ImGui.SetClipboardText("https://github.com/YimMenu-Lua/Harmless-Scripts")    <-- Crashes my game for some reason! The profile link is fine but clicking the YimMenu-Lua repo link crashes my game???🤨
        --     gui.show_message("TokyoDrift Credits", "Copied \"https://github.com/YimMenu-Lua/Harmless-Scripts\" to clipboard!")
        -- end
        ImGui.EndPopup()
    end
end)
event.register_handler(menu_event.MenuUnloaded, function()
    resettokyodrift()
end)
event.register_handler(menu_event.ScriptsReloaded, function()
    resettokyodrift()
end)
script.register_looped("Drift Loop", function(script)
    script:yield()
    if PED.IS_PED_IN_ANY_VEHICLE(self.get_ped(), true) then
        if is_car and DriftTires and PAD.IS_CONTROL_PRESSED(0, 21) then
            VEHICLE.SET_DRIFT_TYRES(current_vehicle, true)
        else
            VEHICLE.SET_DRIFT_TYRES(current_vehicle, false)
        end
        script:yield()
        if is_car and ShiftDrift and PAD.IS_CONTROL_PRESSED(0, 21) and not DriftTires then
            VEHICLE.SET_VEHICLE_REDUCE_GRIP(current_vehicle, true)
            VEHICLE.SET_VEHICLE_REDUCE_GRIP_LEVEL(current_vehicle, DriftIntensity)
        else
            VEHICLE.SET_VEHICLE_REDUCE_GRIP(current_vehicle, false)
        end
    end
end)

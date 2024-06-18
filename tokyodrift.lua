---@diagnostic disable: undefined-global, lowercase-global

tokyodrift = gui.get_tab("GUI_TAB_VEHICLE"):add_tab("Tokyo Drift")
local ShiftDrift     = false
local DriftTires     = false
local is_car         = false
local is_quad        = false
local validModel     = false
local speedBoost     = false
local sfx            = false
local ptfx           = false
local hornLight      = false
local nosPurge       = false
local rgbLights      = false
local has_xenon      = false
local defaultXenon   = 0
local DriftIntensity = 0
local lightSpeed     = 1
local tdBtn          = 21
local function resettokyodrift()
    DriftTires        = false
    ShiftDrift        = false
    shiftDriftToggled = false
    speedBoost        = false
    sfx               = false
    ptfx              = false
    hornLight         = false
    nosPurge          = false
    rgbLights         = false
    DriftIntensity    = 0
    lightSpeed        = 1
    if nosptfx ~= nil then
        script.run_in_fiber(function()
            GRAPHICS.STOP_PARTICLE_FX_LOOPED(nosptfx)
        end)
    end
end
tokyodrift:add_imgui(function()
manufacturer = VEHICLE.GET_MAKE_NAME_FROM_VEHICLE_MODEL(ENTITY.GET_ENTITY_MODEL(current_vehicle))
mfr_name = (manufacturer:lower():gsub("^%l", string.upper))
vehicle_name = vehicles.get_vehicle_display_name(ENTITY.GET_ENTITY_MODEL(current_vehicle))
    if PED.IS_PED_IN_ANY_VEHICLE(self.get_ped(), true) then
        if validModel then
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
        else
            ImGui.Text("You can only drift cars, trucks\nand quad bikes.")
        end
        ImGui.Spacing();ImGui.Separator();ImGui.Text("--------------------- Fun Stuff ---------------------");ImGui.Spacing()
        speedBoost, _ = ImGui.Checkbox("Speed Boost", speedBoost, true)
        if sfx and not speedBoost then
            sfx = false
        end
        if ptfx and not speedBoost then
            ptfx = false
        end
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Simulates NOS.\nGives you more power and increases\nyour top speed when pressing [Left Shift].")
            ImGui.EndTooltip()
        end
        ImGui.SameLine(); sfx, sfxPressed = ImGui.Checkbox("SFX", sfx, true)
        if sfxPressed and not speedBoost then
            gui.show_error("TokyoDrift", "This option is unavailable without 'Speed Boost'.")
            sfx = false
        end
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Plays a sound effect when using 'Speed Boost'.")
            ImGui.EndTooltip()
        end
        ImGui.SameLine(); ptfx, ptfxPressed = ImGui.Checkbox("PTFX", ptfx, true)
        if ptfxPressed and not speedBoost then
            gui.show_error("TokyoDrift", "This option is unavailable without 'Speed Boost'.")
            ptfx = false
        end
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Enables exhaust fire when using 'Speed Boost'.\n\nNOTE: This feature doesn't work on some aftermaket\nexhausts. If you can't see fire coming out of yours,\ngo to LSC and equip a different one.")
            ImGui.EndTooltip()
        end
        ImGui.Spacing();hornLight, _ = ImGui.Checkbox("High Beams on Horn", hornLight, true)
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Flash high beams when honking.")
            ImGui.EndTooltip()
        end
        ImGui.SameLine();ImGui.Dummy(5, 1);ImGui.SameLine();nosPurge, _ = ImGui.Checkbox("NOS Purge", nosPurge, true)
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Press [X] on keyboard or [A] on controller\nto purge your NOS Fast & Furious style.")
            ImGui.EndTooltip()
        end
        ImGui.Spacing();rgbLights, rgbToggled = ImGui.Checkbox("RGB Headlights", rgbLights, true)
        if rgbToggled then
            script.run_in_fiber(function()
                if not VEHICLE.IS_TOGGLE_MOD_ON(current_vehicle, 22) then
                    has_xenon = false
                else
                    has_xenon    = true
                    defaultXenon = VEHICLE.GET_VEHICLE_XENON_LIGHT_COLOR_INDEX(current_vehicle)
                end
            end)
        end
        ImGui.SameLine()
        ImGui.PushItemWidth(100)
        lightSpeed, used = ImGui.SliderInt("RGB Speed", lightSpeed, 1, 3)
        ImGui.PopItemWidth()
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
        ImGui.Text("Original script [Shift-Drift], made by Harmless05\nand improved by SAMURAI (xesdoog).")
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
-- script.register_looped("control scheme", function()
--     if PAD.IS_USING_KEYBOARD_AND_MOUSE() then
--         tdBtn = 21
--     else
--         tdBtn = 73
--     end
-- end)
script.register_looped("Drift Loop", function(script)
    script:yield()
    if PED.IS_PED_IN_ANY_VEHICLE(self.get_ped(), true) then
        local effect = 0
        current_vehicle = PED.GET_VEHICLE_PED_IS_USING(self.get_ped())
        is_car  = VEHICLE.IS_THIS_MODEL_A_CAR(ENTITY.GET_ENTITY_MODEL(current_vehicle))
        is_quad = VEHICLE.IS_THIS_MODEL_A_QUADBIKE(ENTITY.GET_ENTITY_MODEL(current_vehicle))
        if is_car or is_quad then
            validModel = true
        else
            validModel = false
        end
        if validModel and DriftTires and PAD.IS_CONTROL_PRESSED(0, tdBtn) then
            VEHICLE.SET_DRIFT_TYRES(current_vehicle, true)
            VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(current_vehicle, 5.0)
        else
            VEHICLE.SET_DRIFT_TYRES(current_vehicle, false)
            VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(current_vehicle, 1.0)
        end
        script:yield()
        if validModel and ShiftDrift and PAD.IS_CONTROL_PRESSED(0, tdBtn) and not DriftTires then
            VEHICLE.SET_VEHICLE_REDUCE_GRIP(current_vehicle, true)
            VEHICLE.SET_VEHICLE_REDUCE_GRIP_LEVEL(current_vehicle, DriftIntensity)
            VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(current_vehicle, 5.0)
        else
            VEHICLE.SET_VEHICLE_REDUCE_GRIP(current_vehicle, false)
            VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(current_vehicle, 1.0)
        end
        if speedBoost and PAD.IS_CONTROL_PRESSED(0, tdBtn) and PAD.IS_CONTROL_PRESSED(0, 71) then
            VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(current_vehicle, 5.0)
            VEHICLE.MODIFY_VEHICLE_TOP_SPEED(current_vehicle, 100.0)
            if sfx then
                AUDIO.SET_VEHICLE_BOOST_ACTIVE(current_vehicle, true)
            else
                AUDIO.SET_VEHICLE_BOOST_ACTIVE(current_vehicle, false)
            end
        else
            VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(current_vehicle, 1.0)
            VEHICLE.MODIFY_VEHICLE_TOP_SPEED(current_vehicle, -1)
            AUDIO.SET_VEHICLE_BOOST_ACTIVE(current_vehicle, false)
            GRAPHICS.STOP_PARTICLE_FX_LOOPED(effect)
        end
        if hornLight then
            if PAD.IS_CONTROL_PRESSED(0, 86) then
                VEHICLE.SET_VEHICLE_LIGHTS(current_vehicle, 2)
                VEHICLE.SET_VEHICLE_FULLBEAM(current_vehicle, true)
                repeat
                    script:sleep(50)
                until
                    PAD.IS_CONTROL_PRESSED(0, 86) == false
                VEHICLE.SET_VEHICLE_FULLBEAM(current_vehicle, false)
                VEHICLE.SET_VEHICLE_LIGHTS(current_vehicle, 0)
            end
        end
    end
end)
script.register_looped("Speed Boost ptfx", function(spbptfx)
    if speedBoost and ptfx then
        if PAD.IS_CONTROL_PRESSED(0, tdBtn) and PAD.IS_CONTROL_PRESSED(0, 71) then
            local effect  = "veh_xs_vehicle_mods"
            local exhaust = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(current_vehicle, "exhaust")
            while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(effect) do
                STREAMING.REQUEST_NAMED_PTFX_ASSET(effect)
                coroutine.yield()
            end
            GRAPHICS.USE_PARTICLE_FX_ASSET(effect)
            ptfxEffect = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("veh_nitrous", current_vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, exhaust, 1.0, false, false, false, 0, 0, 0)
            repeat
                spbptfx:sleep(50)
            until
                PAD.IS_CONTROL_PRESSED(0, tdBtn) == false or PAD.IS_CONTROL_PRESSED(0, 71) == false
            GRAPHICS.STOP_PARTICLE_FX_LOOPED(ptfxEffect)
        end
    end
end)
script.register_looped("Purge", function(nosprg)
    if nosPurge then
        if PAD.IS_CONTROL_PRESSED(0, 73) then
            local dict  = "core"
            local hood = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(current_vehicle, "bonnet")
            while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(dict) do
                STREAMING.REQUEST_NAMED_PTFX_ASSET(dict)
                coroutine.yield()
            end
            GRAPHICS.USE_PARTICLE_FX_ASSET(dict)
            nosptfx = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("weap_extinguisher", current_vehicle, 0.0, 0.7, 0.0, 0.0, 0.0, 0.0, hood, 0.3, false, false, false, 0, 0, 0)
            repeat
                nosprg:sleep(50)
            until
                PAD.IS_CONTROL_PRESSED(0, 73) == false
            GRAPHICS.STOP_PARTICLE_FX_LOOPED(nosptfx)
        end
    end
end)
script.register_looped("rgbheadlights", function(rgb)
    if rgbLights then
        for i = 0, 14 do
            if rgbLights then
                if not has_xenon then
                    VEHICLE.TOGGLE_VEHICLE_MOD(current_vehicle, 22, true)
                end
                VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.9)
                rgb:sleep(100 / lightSpeed)
                VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.8)
                rgb:sleep(100 / lightSpeed)
                VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.7)
                rgb:sleep(100 / lightSpeed)
                VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.6)
                rgb:sleep(100 / lightSpeed)
                VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.5)
                rgb:sleep(100 / lightSpeed)
                VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(current_vehicle, i)
                VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.4)
                rgb:sleep(100 / lightSpeed)
                VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.3)
                rgb:sleep(100 / lightSpeed)
                VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.2)
                rgb:sleep(100 / lightSpeed)
                VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.1)
                rgb:sleep(100 / lightSpeed)
                VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(current_vehicle, i)
                VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.2)
                rgb:sleep(100 / lightSpeed)
                VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.3)
                rgb:sleep(100 / lightSpeed)
                VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.4)
                rgb:sleep(100 / lightSpeed)
                VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.5)
                rgb:sleep(100 / lightSpeed)
                VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(current_vehicle, i)
                VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.6)
                rgb:sleep(100 / lightSpeed)
                VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.7)
                rgb:sleep(100 / lightSpeed)
                VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.8)
                rgb:sleep(100 / lightSpeed)
                VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 0.9)
                rgb:sleep(100 / lightSpeed)
                VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(current_vehicle, 1.0)
                VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(current_vehicle, i)
                rgb:sleep(100 / lightSpeed)
            else
                if has_xenon then
                    VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(current_vehicle, defaultXenon)
                    break
                else
                    VEHICLE.TOGGLE_VEHICLE_MOD(current_vehicle, 22, false)
                    break
                end
            end
        end
    end
  end)
event.register_handler(menu_event.MenuUnloaded, function()
    resettokyodrift()
end)
event.register_handler(menu_event.ScriptsReloaded, function()
    resettokyodrift()
end)
local BmFont = require('/lib/bmfont')  
local FONT_TT_MASTERS = BmFont.load_fnt('bmfont-tt-masters')  
  
local colors = require('notification-colors')  
  

gGlobalSyncTable.notificationText = gGlobalSyncTable.notificationText or ""  
gGlobalSyncTable.notificationActive = gGlobalSyncTable.notificationActive or false  
gGlobalSyncTable.notificationTimer = gGlobalSyncTable.notificationTimer or 0  
gGlobalSyncTable.notificationDuration = gGlobalSyncTable.notificationDuration or 0  
gGlobalSyncTable.animationEnabled = gGlobalSyncTable.animationEnabled or true  
gGlobalSyncTable.brightnessEnabled = gGlobalSyncTable.brightnessEnabled or true  
gGlobalSyncTable.currentColor = gGlobalSyncTable.currentColor or "red"  
gGlobalSyncTable.isRainbow = gGlobalSyncTable.isRainbow or false  
  
local function anim_leaping(index, length, output)  
    local t = index + get_global_timer() * 0.3  
    local sinv = math.sin(t)  
    local cosv = math.cos(t)  
       
    if gGlobalSyncTable.brightnessEnabled then  
        local brightness = (math.sin(t * 2) * 0.2 + 0.8)
        output.color.r = output.color.r * brightness  
        output.color.g = output.color.g * brightness  
        output.color.b = output.color.b * brightness  
    end  
      
    output.offset.x = cosv * 2  
    output.offset.y = sinv * 6  
    output.rotation.pivot_x = 0.5  
    output.rotation.pivot_y = 0.5  
    output.rotation.rotation = sinv * 2000  
end  
  
 
local function wrap_text(text, max_width)  
    local words = {}  
    for word in text:gmatch("%S+") do  
        table.insert(words, word)  
    end  
  
    local lines = {}  
    local current_line = ""  
  
    for i, word in ipairs(words) do  
        local test_line = current_line == "" and word or current_line .. " " .. word  
        local test_width = djui_hud_measure_text(test_line) * 1.2  
  
        if test_width <= max_width then  
            current_line = test_line  
        else  
            if current_line ~= "" then  
                table.insert(lines, current_line)  
                current_line = word  
            else  
                table.insert(lines, word)  
            end  
        end  
    end  
  
    if current_line ~= "" then  
        table.insert(lines, current_line)  
    end  
  
    return lines  
end  
  
  
local function process_rdt_command(command, msg)  
    if not network_is_server() then  
        play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)  
        djui_chat_message_create("Error: Only the host can use this command")  
        return false  
    end  
  
    if msg and msg:len() > 0 then  
        gGlobalSyncTable.notificationText = msg  
        gGlobalSyncTable.notificationActive = true  
          

        local seconds = tonumber(string.match(command, "rdt(%d+)"))  
        if seconds then  
            gGlobalSyncTable.notificationDuration = seconds * 60 
            gGlobalSyncTable.notificationTimer = gGlobalSyncTable.notificationDuration  
            play_sound(SOUND_MENU_STAR_SOUND, gGlobalSoundSource)  
            djui_chat_message_create("Temporary notification (" .. seconds .. "s): " .. msg)  
        else  
 
            gGlobalSyncTable.notificationTimer = 0  
            play_sound(SOUND_MENU_STAR_SOUND, gGlobalSoundSource)  
            djui_chat_message_create("Notification: " .. msg)  
        end  
    else  
        gGlobalSyncTable.notificationActive = false  
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)  
        djui_chat_message_create("Notification hidden")  
    end  
    return true  
end  
  
 
local function get_available_colors()  
    local colorList = {}  
    for colorName, _ in pairs(colors) do  
        table.insert(colorList, colorName)  
    end  
    return table.concat(colorList, ", ")  
end  
  
 
hook_chat_command("rdt", "[text] - Shows notification (empty to hide)", function(msg)  
    return process_rdt_command("rdt", msg)  
end)  
  
hook_chat_command("rdt5", "[text] - Shows notification for 5 seconds", function(msg)  
    return process_rdt_command("rdt5", msg)  
end)  
  
hook_chat_command("rdt10", "[text] - Shows notification for 10 seconds", function(msg)  
    return process_rdt_command("rdt10", msg)  
end)  
  
hook_chat_command("rdt15", "[text] - Shows notification for 15 seconds", function(msg)  
    return process_rdt_command("rdt15", msg)  
end)  
  
hook_chat_command("rdt20", "[text] - Shows notification for 20 seconds", function(msg)  
    return process_rdt_command("rdt20", msg)  
end)  
  
hook_chat_command("rdt30", "[text] - Shows notification for 30 seconds", function(msg)  
    return process_rdt_command("rdt30", msg)  
end)  
  
hook_chat_command("rdc", "[color] - Change color", function(msg)  
    if not network_is_server() then  
        play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)  
        djui_chat_message_create("Error: Only the host can use this command")  
        return false  
    end  
  
    msg = string.lower(msg or "")  
  
    if colors[msg] then  
        gGlobalSyncTable.currentColor = msg  
        gGlobalSyncTable.isRainbow = false  
        play_sound(SOUND_MENU_STAR_SOUND, gGlobalSoundSource)  
        djui_chat_message_create("Color changed to: " .. colors[msg].name)  
    elseif msg == "rainbow" then  
        gGlobalSyncTable.isRainbow = true  
        play_sound(SOUND_MENU_STAR_SOUND, gGlobalSoundSource)  
        djui_chat_message_create("Color changed to: Rainbow")  
    else  
        play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)  
        djui_chat_message_create("Available colors: " .. get_available_colors() .. ", rainbow")  
    end  
    return true  
end)  
  
hook_chat_command("rdn", "Enable/deactivate animation", function(msg)  
    if not network_is_server() then  
        play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)  
        djui_chat_message_create("Error: Only the host can use this command")  
        return false  
    end  
  
    gGlobalSyncTable.animationEnabled = not gGlobalSyncTable.animationEnabled   
    if gGlobalSyncTable.animationEnabled then  
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)  
        djui_chat_message_create("Animation activated")  
    else  
        play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)  
        djui_chat_message_create("Animation deactivated")  
    end  
    return true  
end)  
  
hook_chat_command("rdb", "Enable/deactivate brightness effect", function(msg)  
    if not network_is_server() then  
        play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)  
        djui_chat_message_create("Error: Only the host can use this command")  
        return false  
    end  
  
    gGlobalSyncTable.brightnessEnabled = not gGlobalSyncTable.brightnessEnabled  
    if gGlobalSyncTable.brightnessEnabled then  
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)  
        djui_chat_message_create("Brightness effect activated")  
    else  
        play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)  
        djui_chat_message_create("Brightness effect deactivated")  
    end  
    return true  
end)  
  
local function on_hud_render()  
    djui_hud_set_resolution(RESOLUTION_DJUI)  
    djui_hud_set_font(FONT_TT_MASTERS)  
  
    local screen_width = djui_hud_get_screen_width()  
  
 
    if gGlobalSyncTable.notificationActive then  
  
        if gGlobalSyncTable.notificationTimer > 0 then  
            if network_is_server() then  
                gGlobalSyncTable.notificationTimer = gGlobalSyncTable.notificationTimer - 1  
                if gGlobalSyncTable.notificationTimer <= 0 then  
                    gGlobalSyncTable.notificationActive = false  
                end  
            end  
        end  
  
 
        local alpha = 255  
        if gGlobalSyncTable.notificationTimer > 0 and gGlobalSyncTable.notificationTimer < 60 then  
            alpha = math.max(0, gGlobalSyncTable.notificationTimer * 4)  
        end  
  
        local scale = 1.0  
        local max_width = screen_width * 0.8  
          
  
        if djui_hud_measure_text(gGlobalSyncTable.notificationText) * scale > max_width then  
            scale = 0.8  
            local lines = wrap_text(gGlobalSyncTable.notificationText, max_width)  
            local line_height = 60 
            local total_height = #lines * line_height  
            local start_y = 100 - total_height * 0.5  
  
            for i, line in ipairs(lines) do  
                local y = start_y + (i - 1) * line_height  
  
                if gGlobalSyncTable.isRainbow then  
                    local rainbowColors = {  
                        { r = 255, g = 0, b = 0 },  
                        { r = 255, g = 127, b = 0 },  
                        { r = 255, g = 255, b = 0 },  
                        { r = 0, g = 255, b = 0 },  
                        { r = 0, g = 0, b = 255 },  
                        { r = 75, g = 0, b = 130 },  
                        { r = 148, g = 0, b = 211 }  
                    }  
                    local colorIndex = math.floor((get_global_timer() * 0.1) % #rainbowColors) + 1  
                    local color = rainbowColors[colorIndex]  
                    djui_hud_set_color(color.r, color.g, color.b, alpha)  
                else  
                    local color = colors[gGlobalSyncTable.currentColor]  
                    djui_hud_set_color(color.r, color.g, color.b, alpha)  
                end  
  
                if gGlobalSyncTable.animationEnabled then  
                    BmFont.print_center_aligned(FONT_TT_MASTERS, line, screen_width * 0.5, y, scale, anim_leaping)  
                else  
                    local measure = djui_hud_measure_text(line) * scale * 0.5  
                    djui_hud_print_text(line, screen_width * 0.5 - measure, y, scale)  
                end  
            end  
        else  
 
            if gGlobalSyncTable.isRainbow then  
                local rainbowColors = {  
                    { r = 255, g = 0, b = 0 },  
                    { r = 255, g = 127, b = 0 },  
                    { r = 255, g = 255, b = 0 },  
                    { r = 0, g = 255, b = 0 },  
                    { r = 0, g = 0, b = 255 },  
                    { r = 75, g = 0, b = 130 },  
                    { r = 148, g = 0, b = 211 }  
                }  
                local colorIndex = math.floor((get_global_timer() * 0.1) % #rainbowColors) + 1  
                local color = rainbowColors[colorIndex]  
                djui_hud_set_color(color.r, color.g, color.b, alpha)  
            else  
                local color = colors[gGlobalSyncTable.currentColor]  
                djui_hud_set_color(color.r, color.g, color.b, alpha)  
            end  
  
            if gGlobalSyncTable.animationEnabled then  
                BmFont.print_center_aligned(FONT_TT_MASTERS, gGlobalSyncTable.notificationText, screen_width * 0.5, 100, scale, anim_leaping)  
            else  
                local measure = djui_hud_measure_text(gGlobalSyncTable.notificationText) * scale * 0.5  
                djui_hud_print_text(gGlobalSyncTable.notificationText, screen_width * 0.5 - measure, 100, scale)  
            end  
        end  
    end  
end  
  
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
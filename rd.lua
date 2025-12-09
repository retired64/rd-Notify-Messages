-- rd.lua
local BmFont = require('/lib/bmfont')
local FONT_TT_MASTERS = BmFont.load_fnt('bmfont-tt-masters')
local colors = require('notification-colors')

local djui_hud_set_resolution = djui_hud_set_resolution
local djui_hud_set_font = djui_hud_set_font
local djui_hud_get_screen_width = djui_hud_get_screen_width
local djui_hud_measure_text = djui_hud_measure_text
local djui_hud_set_color = djui_hud_set_color
local djui_hud_print_text = djui_hud_print_text
local djui_hud_print_text_interpolated = djui_hud_print_text_interpolated -- Añadido
local hud_is_hidden = hud_is_hidden -- Añadido
local get_global_timer = get_global_timer
local network_is_server = network_is_server
local play_sound = play_sound
local djui_chat_message_create = djui_chat_message_create
local math_sin = math.sin
local math_cos = math.cos
local math_floor = math.floor
local math_max = math.max
local string_match = string.match
local string_lower = string.lower
local table_insert = table.insert
local table_concat = table.concat

local FADE_TIME = 60
local MAX_WIDTH_RATIO = 0.8
local DEFAULT_SCALE = 1.0
local WRAPPED_SCALE = 0.7
local LINE_HEIGHT = 30
local DEFAULT_Y = 50
local ANIMATION_SPEED = 0.3
local BRIGHTNESS_SPEED = 2.0

-- Variables Globales de Sincronización
gGlobalSyncTable.rd_text = gGlobalSyncTable.rd_text or ""
gGlobalSyncTable.rd_active = gGlobalSyncTable.rd_active or false
gGlobalSyncTable.rd_timer = gGlobalSyncTable.rd_timer or 0
gGlobalSyncTable.rd_duration = gGlobalSyncTable.rd_duration or 0
gGlobalSyncTable.rd_anim = gGlobalSyncTable.rd_anim or true
gGlobalSyncTable.rd_bright = gGlobalSyncTable.rd_bright or false
gGlobalSyncTable.rd_color = gGlobalSyncTable.rd_color or "red"
gGlobalSyncTable.rd_rainbow = gGlobalSyncTable.rd_rainbow or false

local RAINBOW_COLORS = {
    { r = 255, g = 0, b = 0 },
    { r = 255, g = 127, b = 0 },
    { r = 255, g = 255, b = 0 },
    { r = 0, g = 255, b = 0 },
    { r = 0, g = 0, b = 255 },
    { r = 75, g = 0, b = 130 },
    { r = 148, g = 0, b = 211 }
}


local function anim_leaping(index, length, output)
    local t = index + get_global_timer() * ANIMATION_SPEED
    local sinv = math_sin(t)
    local cosv = math_cos(t)
       
    if gGlobalSyncTable.rd_bright then
        local brightness = (math_sin(t * BRIGHTNESS_SPEED) * 0.2 + 0.8)
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
        table_insert(words, word)
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
                table_insert(lines, current_line)
                current_line = word
            else
                table_insert(lines, word)
            end
        end
    end
  
    if current_line ~= "" then
        table_insert(lines, current_line)
    end
  
    return lines
end

local function process_rdt_command(command, msg)

    if msg and msg:len() > 0 then
        gGlobalSyncTable.rd_text = msg
        gGlobalSyncTable.rd_active = true
          
        local seconds = tonumber(string_match(command, "rdt(%d+)"))
        if seconds then
            gGlobalSyncTable.rd_duration = seconds * 60
            gGlobalSyncTable.rd_timer = gGlobalSyncTable.rd_duration
            play_sound(SOUND_MENU_STAR_SOUND, gGlobalSoundSource)
            djui_chat_message_create("Temporary notification (" .. seconds .. "s): " .. msg)
        else
            gGlobalSyncTable.rd_timer = 0
            play_sound(SOUND_MENU_STAR_SOUND, gGlobalSoundSource)
            djui_chat_message_create("Notification: " .. msg)
        end
    else
        gGlobalSyncTable.rd_active = false
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
        djui_chat_message_create("Notification hidden")
    end
    return true
end

local function get_available_colors()
    local colorList = {}
    for colorName, _ in pairs(colors) do
        table_insert(colorList, colorName)
    end
    return table_concat(colorList, ", ")
end

hook_chat_command("rdt", "[text] - Shows notification (empty to hide)", function(msg)
    if not network_is_server() then
        play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
        djui_chat_message_create("Error: Only the host can use this command")
        return false
    end
    return process_rdt_command("rdt", msg)
end)

local timed_commands = {"rdt5", "rdt10", "rdt15", "rdt20", "rdt30"}
for _, cmd in ipairs(timed_commands) do
    hook_chat_command(cmd, "[text] - Shows notification", function(msg)
        if not network_is_server() then
            play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
            djui_chat_message_create("Error: Only the host can use this command")
            return false
        end
        return process_rdt_command(cmd, msg)
    end)
end

hook_chat_command("rdc", "[color] - Change color", function(msg)
    if not network_is_server() then
        play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
        djui_chat_message_create("Error: Only the host can use this command")
        return false
    end
  
    msg = string_lower(msg or "")
  
    if colors[msg] then
        gGlobalSyncTable.rd_color = msg
        gGlobalSyncTable.rd_rainbow = false
        play_sound(SOUND_MENU_STAR_SOUND, gGlobalSoundSource)
        djui_chat_message_create("Color changed to: " .. colors[msg].name)
    elseif msg == "rainbow" then
        gGlobalSyncTable.rd_rainbow = true
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
  
    gGlobalSyncTable.rd_anim = not gGlobalSyncTable.rd_anim
    if gGlobalSyncTable.rd_anim then
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
  
    gGlobalSyncTable.rd_bright = not gGlobalSyncTable.rd_bright
    if gGlobalSyncTable.rd_bright then
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
        djui_chat_message_create("Brightness effect activated")
    else
        play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
        djui_chat_message_create("Brightness effect deactivated")
    end
    return true
end)

local function on_hud_render()

    if hud_is_hidden() then return end
    if not gGlobalSyncTable.rd_active then return end


    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_TT_MASTERS)

    local screen_width = djui_hud_get_screen_width()


    if gGlobalSyncTable.rd_timer > 0 then
        if network_is_server() then
            gGlobalSyncTable.rd_timer = gGlobalSyncTable.rd_timer - 1
            if gGlobalSyncTable.rd_timer <= 0 then
                gGlobalSyncTable.rd_active = false
            end
        end
    end

    -- Cálculo de alpha
    local alpha = 255
    if gGlobalSyncTable.rd_timer > 0 and gGlobalSyncTable.rd_timer < FADE_TIME then
        alpha = math_max(0, gGlobalSyncTable.rd_timer * 4)
    end

    local scale = DEFAULT_SCALE
    local max_width = screen_width * MAX_WIDTH_RATIO

    -- Determinar Color (Simplificado)
    local currentColorObj
    if gGlobalSyncTable.rd_rainbow then
        local colorIndex = math_floor((get_global_timer() * 0.1) % #RAINBOW_COLORS) + 1
        currentColorObj = RAINBOW_COLORS[colorIndex]
    else
        currentColorObj = colors[gGlobalSyncTable.rd_color] or colors.red
    end

    -- Renderizado
    if djui_hud_measure_text(gGlobalSyncTable.rd_text) * scale > max_width then
        scale = WRAPPED_SCALE
        local lines = wrap_text(gGlobalSyncTable.rd_text, max_width)
        local total_height = #lines * LINE_HEIGHT
        local start_y = DEFAULT_Y - total_height * 0.5

        for i, line in ipairs(lines) do
            local y = start_y + (i - 1) * LINE_HEIGHT
            
            djui_hud_set_color(currentColorObj.r, currentColorObj.g, currentColorObj.b, alpha)

            if gGlobalSyncTable.rd_anim then
                BmFont.print_center_aligned(FONT_TT_MASTERS, line, screen_width * 0.5, y, scale, anim_leaping)
            else
                local measure = djui_hud_measure_text(line) * scale * 0.5
                djui_hud_print_text(line, screen_width * 0.5 - measure, y, scale)
            end
        end
    else
        djui_hud_set_color(currentColorObj.r, currentColorObj.g, currentColorObj.b, alpha)

        if gGlobalSyncTable.rd_anim then
            BmFont.print_center_aligned(FONT_TT_MASTERS, gGlobalSyncTable.rd_text, screen_width * 0.5, DEFAULT_Y, scale, anim_leaping)
        else
            local measure = djui_hud_measure_text(gGlobalSyncTable.rd_text) * scale * 0.5
            djui_hud_print_text(gGlobalSyncTable.rd_text, screen_width * 0.5 - measure, DEFAULT_Y, scale)
        end
    end
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, on_hud_render)

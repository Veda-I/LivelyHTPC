local prevFocusIndex = 0
local moving = false
local meterIcons = {}

-- Log Meter
function LogMeter(meter)
	if debug == 1 and not moving then
		local msg = string.format("Icon%d [F=%s|%s|X:%d|A:%d]",meter.id,tostring(meter.focused),meter.name,meter.x,meter.a)
		SKIN:Bang('!Log', msg)
	end	
end

-- Log
function Log(msg)
	if debug == 1 and not moving then
		SKIN:Bang('!Log', msg)
	end	
end

-- Animations utilities --

-- EaseOutExpo (standard)
local function EaseOutExpo_t(t)
    if t >= 1 then return 1 end
    return 1 - math.pow(2, -10 * t)
end

-- EaseOutExpoFast
local function EaseOutExpoFast_t(t)
    -- variant that quickly ramps up then eases
    -- clamp t
    if t >= 1 then return 1 end
    -- small tweak: scale t to emphasize initial speed
    local scaled = math.min(1, t * 6) -- tune factor (6) if needed
    return 1 - (1 / (scaled * 10 + 1))
end

-- EaseOutQuad (standard)
local function EaseOutQuad_t(t)
    if t >= 1 then return 1 end
    return 1 - (1 - t) * (1 - t)
end

-- LinearMove helper (move at fixed pixel speed per frame)
local function LinearMove_step(x, targetX, speed)
    -- speed is pixel-per-frame
    local diff = targetX - x
    if math.abs(diff) <= speed then
        return targetX
    elseif diff > 0 then
        return x + speed
    else
        return x - speed
    end
end

-- Animation dispatcher:
-- mode: string, speed: number (meaning differs by mode)
-- returns newX
local function AnimationStep(mode, x, targetX, speed)
    local diff = targetX - x
    if mode == 'None' or mode == 'none' or mode == '0' then
        return targetX
    elseif mode == 'Linear' then
        return LinearMove_step(x, targetX, speed or 8) -- default 8 px/frame
    else
        -- easing modes interpret 'speed' as t step (0..1) per frame
        local t = tonumber(speed) or 0.05
        if t > 1 then t = 1 end
        if mode == 'EaseOutExpoFast' then
            local e = EaseOutExpoFast_t(t)
            return x + diff * e
        elseif mode == 'EaseOutExpo' then
            local e = EaseOutExpo_t(t)
            return x + diff * e
        else -- default EaseOutQuad
            local e = EaseOutQuad_t(t)
            return x + diff * e
        end
    end
end

-- Utility: rounded integer (for sending to Rainmeter)
local function round(n)
    return math.floor(n + 0.5)
end


-- Initialize
function Initialize()

	-- constants
    screenWidth = tonumber(SKIN:GetVariable('SCREENAREAWIDTH','1920'))
    screenHeight = tonumber(SKIN:GetVariable('SCREENAREAHEIGHT','1080'))
	firstIndex= tonumber(SKIN:GetVariable('StartPosition','2'))
    iconCount = tonumber(SKIN:GetVariable('IconCount','11'))
    visibleIcons = tonumber(SKIN:GetVariable('VisibleIcons','4'))
	iconSpacing = tonumber(SKIN:GetVariable('IconSpacing','50'))
    iconWidth = tonumber(SKIN:GetVariable('IconSize','180'))
    iconHeight = iconWidth
    debug = tonumber(SKIN:GetVariable('Debug','0'))
    animationMode = SKIN:GetVariable('Animation.Mode', 'None')  -- EaseOutExpo,EaseOutExpoFast,EaseOutQuad,Linear,None
    transitionSpeed = tonumber(SKIN:GetVariable('Animation.Speed', '0.08'))
    linearSpeed = tonumber(SKIN:GetVariable('Animation.Speed', '30')) -- PX/Frame for Linear

    -- calculate startX,startY
    startX = (screenWidth - (visibleIcons * (iconWidth + iconSpacing) - iconSpacing)) / 2
    startY = (screenHeight - iconHeight) / 2
	
	local bangs = {}
	
	-- init icons & draw
	for i = 1, iconCount do

		local name = SKIN:GetVariable('Icon.'..i..'.Name')
		local idle = '#@#\Icons\\' .. name .. '.png'
		local focus = '#@#\Icons\\' .. name .. '2.png'
		local alpha = (i <= visibleIcons) and 255 or 0
		local x = startX + (i - 1) * (iconWidth + iconSpacing)
		local focused = (i == firstIndex)
		local image = focused and focus or idle
		meterIcons[i] = {id = i,name = name,x = x,y = startY,a = alpha,h = iconHeight,w = iconWidth,idle = idle,focus = focus,image = image,focused = focused}
		table.insert(bangs, '!SetOption MeterIcon'..i..' ImageName "'..meterIcons[i].image..'"')
		table.insert(bangs, '!SetOption MeterIcon'..i..' ImageAlpha '..meterIcons[i].a)
		table.insert(bangs, '!SetOption MeterIcon'..i..' X '..meterIcons[i].x)
		table.insert(bangs, '!SetOption MeterIcon'..i..' Y '..meterIcons[i].y)
		table.insert(bangs, '!SetOption MeterIcon'..i..' W '..meterIcons[i].w)
		table.insert(bangs, '!SetOption MeterIcon'..i..' H '..meterIcons[i].h)
		LogMeter(meterIcons[i])

	end
	
	table.insert(bangs, '!UpdateMeter *')
	table.insert(bangs, '!Redraw')
	-- Log('BANG : [' ..table.concat(bangs, '][')..']')
	SKIN:Bang('['..table.concat(bangs,'][')..']')
	Log('** Lua Initialized')	
	
end

-- Update
function Update()

    local focusIndex = tonumber(SKIN:GetVariable('FocusIndex'))

    -- nothing
    if focusIndex == prevFocusIndex and not moving then
        Log('** Update skipped [' .. focusIndex .. '|' .. prevFocusIndex .. ']')
        return 0
    end

    -- lock
    SKIN:Bang('!WriteKeyValue', 'Variables', 'UpdateComplete', '0', '#@#\Lua\\Lock.ini')

    local bangs = {}
	local movingThisFrame = false 

    -- calculate offset to recenter the visible icons
    local offset = math.max(1, math.min(focusIndex - (visibleIcons - 1), iconCount - visibleIcons + 1))
    local targetOffsetX = (1 - offset) * (iconWidth + iconSpacing)

	-- detection of visible icons
    local startPos = math.max(1, focusIndex - visibleIcons + 1)
    local endPos   = math.min(iconCount, startPos + visibleIcons - 1)

    Log('** Lua Update [R=' .. startPos .. '-' .. endPos .. '|F=' .. focusIndex .. '|T=' .. targetOffsetX .. ']')

    -- detect direction
    local movingRight = focusIndex > prevFocusIndex
    local animStart, animEnd

    if movingRight then
        animStart = startPos
        animEnd = math.min(endPos + 1, iconCount)
    else
        animStart = math.max(startPos - 1, 1)
        animEnd = endPos
    end

	-- icon updates
    for i = 1, iconCount do
        
        local icon = meterIcons[i]

        -- a) focus
		local newfocused = (i == focusIndex)
		if newfocused ~= icon.focused then
			icon.focused = newfocused
			icon.image = newfocused and icon.focus or icon.idle
			table.insert(bangs, '!SetOption MeterIcon' .. i .. ' ImageName ' .. icon.image)
		end
				
        -- b) alpha (visible or hidden)
        local newAlpha = (i < startPos or i > endPos) and 0 or 255
        if newAlpha ~= icon.a then
            icon.a = newAlpha
            table.insert(bangs, '!SetOption MeterIcon' .. i .. ' ImageAlpha ' .. newAlpha)
			table.insert(bangs, '!UpdateMeter MeterIcon' .. i)
        end
		
		-- x) x position
        local targetX  = startX + (i - 1) * (iconWidth + iconSpacing) + targetOffsetX

        if i >= animStart and i <= animEnd then
            -- animation only for relevant icons
            local newX = AnimationStep(animationMode, icon.x, targetX, (animationMode == 'Linear') and linearSpeed or transitionSpeed)
            local sentX = round(newX)
            local prevSentX = round(icon.x)
            if sentX ~= prevSentX then
                -- only send if the integer position changed
                icon.x = newX
                table.insert(bangs, '!SetOption MeterIcon' .. i .. ' X ' .. sentX)
                table.insert(bangs, '!UpdateMeter MeterIcon' .. i)
                movingThisFrame = true
            else
                -- no integer change, keep floating x for next frame (no bang)
                icon.x = newX
            end
        else
            -- icons outside animation: place directly at final integer position if needed
            local sentTargetX = round(targetX)
            if round(icon.x) ~= sentTargetX then
                icon.x = targetX
                table.insert(bangs, '!SetOption MeterIcon' .. i .. ' X ' .. sentTargetX)
            end
        end

		LogMeter(icon)
		
    end

	-- final
    prevFocusIndex = focusIndex
	moving = movingThisFrame
	
    if moving then
		table.insert(bangs, '!Redraw')
    end
    table.insert(bangs, '!WriteKeyValue Variables UpdateComplete 1 #@#\Lua\\Lock.ini')
	-- Log('BANG : [' ..table.concat(bangs, '][')..']')
    SKIN:Bang('[' .. table.concat(bangs, '][') .. ']')
	
    -- animation ongoing
    if moving then
        SKIN:Bang('!UpdateMeasure MeasureIcons')
    end

    return 0
	
end

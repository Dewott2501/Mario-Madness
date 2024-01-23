local whoismx = '';
local isON = false;

-- check which character is mx which will allow mx to work as bf for some fucking reason
function onCreate()
    if getProperty('dad.curCharacter') == 'mx_demiseUG' then
        -- debugPrint(whoismx .. ' is mx');
        whoismx = 'dad';
        isON = true;
    elseif getProperty('boyfriend.curCharacter') == 'mx_demiseUG' then
        -- debugPrint('bf is mx, why tf is bf mx whats wrong with u lol');
        whoismx = 'boyfriend';
        isON = true;
    else
        isON = false;
    end
end

-- fuck you
function onCreatePost()
    --make legs
    makeAnimatedLuaSprite('mxlegsUG','characters/MX_Demise_Assets_Underground', 0, 0);
    addAnimationByPrefix('mxlegsUG', 'exist', 'MX Running Legs', 35, true);
    --legs behind mx, gf behind legs
	-- setObjectOrder(whoismx .. 'Group', getObjectOrder(whoismx .. 'Group') + 13);
    -- setObjectOrder('mxlegsUG', getObjectOrder(whoismx .. 'Group') - 1);
    
	setProperty('mxlegsUG.x', getProperty(whoismx .. '.x'));
    setProperty('mxlegsUG.y', getProperty(whoismx .. '.y'));
	setProperty('mxlegsUG.offset.x', -3);
    setProperty('mxlegsUG.offset.y', -461);

	makeAnimatedLuaSprite('mxrightarmUG', 'characters/MX_Demise_Assets_Underground', 0, 0);
    addAnimationByPrefix('mxrightarmUG', 'exist2', 'MX Running Right Arm', 35, true);
    -- setObjectOrder('mxrightarmUG', getObjectOrder('mxlegsUG') - 1);
    addLuaSprite('mxrightarmUG', false);
    addLuaSprite('mxlegsUG', false);

	setProperty('mxrightarmUG.x', getProperty(whoismx .. '.x'));
    setProperty('mxrightarmUG.y', getProperty(whoismx .. '.y'));
	setProperty('mxrightarmUG.offset.x', 57);
    setProperty('mxrightarmUG.offset.y', -321);
	
	setProperty(whoismx .. '.origin.x', 833);
	setProperty(whoismx .. '.origin.y', 1003);

    if isON == false then
	    setProperty('mxrightarmUG.visible', false)
	    setProperty('mxlegsUG.visible', false)
    end

end

function onUpdatePost()

	-- live animation shit
    -- body is moved and rotated based on what animation frame the legs are on
    -- this happens every frame
    -- i used black magic to get these numbers
    -- no trial and error here.

    if isON == true then

    setProperty('mxlegsUG.color', getProperty(whoismx .. '.color'));
    setProperty('mxrightarmUG.color', getProperty(whoismx .. '.color'));

    setProperty('mxlegsUG.x', getProperty(whoismx .. '.x'));
    setProperty('mxlegsUG.y', getProperty(whoismx .. '.y'));

    setProperty('mxrightarmUG.x', getProperty(whoismx .. '.x'));
    setProperty('mxrightarmUG.y', getProperty(whoismx .. '.y'));

	if getProperty(whoismx .. '.animation.curAnim.name') ~= 'idle' then
		setProperty('mxrightarmUG.visible', false);
        if getProperty('mxlegsUG.animation.frameIndex') == 0 then
            setProperty(whoismx .. '.angle', 0);
            setProperty(whoismx .. '.x', defaultOpponentX - 930);
            setProperty(whoismx .. '.y', defaultOpponentY - 870);
        end
        if getProperty('mxlegsUG.animation.frameIndex') == 2 then
            setProperty(whoismx .. '.angle', -2.7);
            setProperty(whoismx .. '.x', defaultOpponentX - 930 - 13.4);
            setProperty(whoismx .. '.y', defaultOpponentY - 870 - 72.75);
        end
        if getProperty('mxlegsUG.animation.frameIndex') == 4 then
            setProperty(whoismx .. '.angle', -3.7);
            setProperty(whoismx .. '.x', defaultOpponentX - 930 - 18.05);
            setProperty(whoismx .. '.y', defaultOpponentY - 870 - 94.8);
        end
        if getProperty('mxlegsUG.animation.frameIndex') == 6 then
            setProperty(whoismx .. '.angle', -2.2);
            setProperty(whoismx .. '.x', defaultOpponentX - 930 - 10.8);
            setProperty(whoismx .. '.y', defaultOpponentY - 870 - 26.5);
        end
        if getProperty('mxlegsUG.animation.frameIndex') == 8 then
            setProperty(whoismx .. '.angle', 0);
            setProperty(whoismx .. '.x', defaultOpponentX - 930);
            setProperty(whoismx .. '.y', defaultOpponentY - 870);
        end
        if getProperty('mxlegsUG.animation.frameIndex') == 10 then
            setProperty(whoismx .. '.angle', -2.7);
            setProperty(whoismx .. '.x', defaultOpponentX - 930 - 13.4);
            setProperty(whoismx .. '.y', defaultOpponentY - 870 - 72.75);
        end
        if getProperty('mxlegsUG.animation.frameIndex') == 12 then
            setProperty(whoismx .. '.angle', -3.7);
            setProperty(whoismx .. '.x', defaultOpponentX - 930 - 18.05);
            setProperty(whoismx .. '.y', defaultOpponentY - 870 - 94.8);
        end
        if getProperty('mxlegsUG.animation.frameIndex') == 14 then
            setProperty(whoismx .. '.angle', -2.2);
            setProperty(whoismx .. '.x', defaultOpponentX - 930 - 10.8);
            setProperty(whoismx .. '.y', defaultOpponentY - 870 - 26.5);
        end
	else
        setProperty(whoismx .. '.animation.frameIndex', getProperty('mxlegsUG.animation.frameIndex') + 32)
		setProperty('mxrightarmUG.visible', true);
        setProperty(whoismx .. '.angle', 0);
        setProperty(whoismx .. '.x', defaultOpponentX - 930);
        setProperty(whoismx .. '.y', defaultOpponentY - 870);
	end
    end
end

function onEvent(name, value1, value2)

if name == 'Change Character' then
    
    if value1 == '1' then

    if value2 == 'mx_demiseUG' then
        whoismx = 'dad'
        isON = true
        setProperty('mxrightarmUG.visible', true)
	    setProperty('mxlegsUG.visible', true)

        setProperty('mxlegsUG.x', getProperty(whoismx .. '.x'));
        setProperty('mxlegsUG.y', getProperty(whoismx .. '.y'));
        setProperty('mxlegsUG.offset.x', -3);
        setProperty('mxlegsUG.offset.y', -461);
        
        setProperty(whoismx .. '.origin.x', 833);
        setProperty(whoismx .. '.origin.y', 1003);
    else
        isON = false
        setProperty('mxrightarmUG.visible', false)
	    setProperty('mxlegsUG.visible', false)
    end

    end
end

end
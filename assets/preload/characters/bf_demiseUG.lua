local whoisbf = '';
local isON = false;
-- check which character is mx which will allow mx to work as bf for some fucking reason
function onCreate()
    if getProperty('boyfriend.curCharacter') == 'bf_demiseUG' then
        -- debugPrint('bf is bf');
        whoisbf = 'boyfriend';
        isON = true;
    elseif getProperty('dad.curCharacter') == 'bf_demiseUG' then
        -- debugPrint('dad is bf wtf why');
        whoisbf = 'dad';
        isON = true;
    else
        isON = false;
    end
end

-- fuck you
function onCreatePost()
    --make legs
    makeAnimatedLuaSprite('bflegsUG','characters/Demise_BF_Assets_Underground', 0, 0);
    addAnimationByPrefix('bflegsUG', 'exist', 'Bottom', 40, true);
    --legs behind bf
	-- setObjectOrder(whoisbf .. 'Group', getObjectOrder(whoisbf .. 'Group') + 10);
    -- setObjectOrder('bflegsUG', getObjectOrder(whoisbf .. 'Group') - 1);
    -- setObjectOrder('gfGroup', getObjectOrder('bflegsUG') - 1);
    

	setProperty('bflegsUG.x', getProperty(whoisbf .. '.x'));
    setProperty('bflegsUG.y', getProperty(whoisbf .. '.y'));
	setProperty('bflegsUG.offset.x', 33);
    setProperty('bflegsUG.offset.y', -236);

	makeAnimatedLuaSprite('bfrightarmUG', 'characters/Demise_BF_Assets_Underground', 0, 0);
    addAnimationByPrefix('bfrightarmUG', 'exist2', 'BF Right Arm', 40, true);
    -- arm behind bf and legs
    -- setObjectOrder('bfrightarmUG', getObjectOrder('bflegsUG') - 1);
    addLuaSprite('bfrightarmUG', false);
    addLuaSprite('bflegsUG', false);

	setProperty('bfrightarmUG.x', getProperty(whoisbf .. '.x'));
    setProperty('bfrightarmUG.y', getProperty(whoisbf .. '.y'));
	setProperty('bfrightarmUG.offset.x', -13);
    setProperty('bfrightarmUG.offset.y', -155);
	
	-- setProperty(whoisbf .. '.origin.x', 833);
	-- setProperty(whoisbf .. '.origin.y', 1003);
    if isON == false then
	    setProperty('bfrightarmUG.visible', false)
	    setProperty('bflegsUG.visible', false)
    end
end

function onUpdatePost()

	-- live animation shit
    -- body is moved and rotated based on what animation frame the legs are on
    -- this happens every frame
    -- i used black magic to get these numbers
    -- no trial and error here.

    if isON == true then

    setProperty('bflegsUG.color', getProperty(whoisbf .. '.color'));
    setProperty('bfrightarmUG.color', getProperty(whoisbf .. '.color'));

    setProperty('bflegsUG.x', getProperty(whoisbf .. '.x'));
    setProperty('bflegsUG.y', getProperty(whoisbf .. '.y'));

    setProperty('bfrightarmUG.x', getProperty(whoisbf .. '.x'));
    setProperty('bfrightarmUG.y', getProperty(whoisbf .. '.y'));

	if getProperty(whoisbf .. '.animation.curAnim.name') ~= 'idle' then
		setProperty('bfrightarmUG.visible', false);
        if getProperty('bflegsUG.animation.frameIndex') == 31 then
            setProperty(whoisbf .. '.y', defaultBoyfriendY + 270);
        end
        if getProperty('bflegsUG.animation.frameIndex') == 33 then
            setProperty(whoisbf .. '.y', defaultBoyfriendY + 270 + (7.35 / 2));
        end
        if getProperty('bflegsUG.animation.frameIndex') == 35 then
            setProperty(whoisbf .. '.y', defaultBoyfriendY + 270 + (14.7 / 2));
        end
        if getProperty('bflegsUG.animation.frameIndex') == 37 then
            setProperty(whoisbf .. '.y', defaultBoyfriendY + 270 + (2.25 / 2));
        end
        if getProperty('bflegsUG.animation.frameIndex') == 39 then
            setProperty(whoisbf .. '.y', defaultBoyfriendY + 270 + (5.05 / 2));
        end
        if getProperty('bflegsUG.animation.frameIndex') == 41 then
            setProperty(whoisbf .. '.y', defaultBoyfriendY + 270 + (9.2 / 2));
        end
        if getProperty('bflegsUG.animation.frameIndex') == 43 then
            setProperty(whoisbf .. '.y', defaultBoyfriendY + 270 + (12.6 / 2));
        end
        if getProperty('bflegsUG.animation.frameIndex') == 45 then
            setProperty(whoisbf .. '.y', defaultBoyfriendY + 270 + (3.15 / 2));
        end
	else
        setProperty(whoisbf .. '.animation.frameIndex', getProperty('bflegsUG.animation.frameIndex') - 16)
		setProperty('bfrightarmUG.visible', true);
        setProperty(whoisbf .. '.angle', 0);
        setProperty(whoisbf .. '.y', defaultBoyfriendY + 230);
	end
    end

    -- 210.95 fla y values of torso
    -- 218.3 
    -- 225.65
    -- 213.2
    -- 216
    -- 220.15
    -- 223.55
    -- 214.1

    -- 0 after subtracting 210.95 from all values
    -- 7.35 
    -- 14.7
    -- 2.25
    -- 5.05
    -- 9.2
    -- 12.6
    -- 3.15
end

function onEvent(name, value1, value2)

    if name == 'Change Character' then
        
        if value1 == '1' then
            whoisbf = 'dad';
        elseif value1 == '0' then
            whoisbf = 'boyfriend';
        end

        if value1 == '0' then
    
        if value2 == 'bf_demiseUG' then
            isON = true
            setProperty('bfrightarmUG.visible', true)
            setProperty('bflegsUG.visible', true)
    
            setProperty('bflegsUG.x', getProperty(whoisbf .. '.x'));
            setProperty('bflegsUG.y', getProperty(whoisbf .. '.y'));
            setProperty('bflegsUG.offset.x', 23);
            setProperty('bflegsUG.offset.y', -230);
            
            setProperty(whoisbf .. '.origin.x', 833);
            setProperty(whoisbf .. '.origin.y', 1003);

        else
            isON = false
            setProperty('bfrightarmUG.visible', false)
            setProperty('bflegsUG.visible', false)
        end

        end

    end
    
    end
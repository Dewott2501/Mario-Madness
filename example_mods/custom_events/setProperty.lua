function onEvent(n, v1, v2)

    if n == 'setProperty' then
		setProperty(v1, tonumber(v2))
	end
end
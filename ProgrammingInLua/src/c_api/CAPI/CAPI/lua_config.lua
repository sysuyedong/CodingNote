window_width = 1280
window_height = 720
color = { red = 1, green = 0, blue = 0,}

function fibonacci(n)
	if n == 0 or n == 1 then
		return n
	else
		return fibonacci(n - 1) + fibonacci(n - 2)
	end
end
String::underscore = ->
	@replace /([A-Z])/g, ($1) -> "_" + $1.toLowerCase()

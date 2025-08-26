module.exports = function(code) {
	// Basic downlevel transformation for ES3 engines
	// Replace const/let with var
	code = code.replace(/\bconst\b/g, 'var').replace(/\blet\b/g, 'var');
	// Replace object method shorthand with function expressions
	// Matches '{ name(arg) {' or ', name(arg) {' patterns
	code = code.replace(/([,{]\s*)([A-Za-z_$][A-Za-z0-9_$]*)\s*\(([^)]*)\)\s*{/g,
	        '$1$2: function($3){');
	// Very small template literal transformation: `${a}b` -> ''+a+'b'
	code = code.replace(/`([^`]*?)`/g, function(match, content) {
	        // handle ${...} interpolations
	        return '"' + content
	                .replace(/\\/g, '\\\\')
	                .replace(/"/g, '\\"')
	                .replace(/\$\{([^}]*)\}/g, '" + ($1) + "') + '"';
	});
	return code;
};

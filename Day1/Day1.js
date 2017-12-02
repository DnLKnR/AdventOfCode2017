function solve(s, n, d) {
    return (s == d.length) ? 0 : (d[s] === d[n] ? parseInt(d[s], 10) : 0) + solve(++s, ++n >= d.length ? 0 : n, d);
}

var getResult = {
    Part1 : function (input) {
        return solve(0, 1, '' + input);
    },
    Part2 : function (input) {
        return solve(0, input.length / 2, '' + input);
    }
}

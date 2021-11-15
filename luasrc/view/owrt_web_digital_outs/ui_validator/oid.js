// Generated automatically by nearley, version 2.20.1
// http://github.com/Hardmath123/nearley
(function () {
function id(x) { return x[0]; }
var grammar = {
    Lexer: undefined,
    ParserRules: [
    {"name": "MAIN", "symbols": ["OID"]},
    {"name": "OID$ebnf$1$subexpression$1", "symbols": [{"literal":"."}, "SIDn"]},
    {"name": "OID$ebnf$1", "symbols": ["OID$ebnf$1$subexpression$1"]},
    {"name": "OID$ebnf$1$subexpression$2", "symbols": [{"literal":"."}, "SIDn"]},
    {"name": "OID$ebnf$1", "symbols": ["OID$ebnf$1", "OID$ebnf$1$subexpression$2"], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "OID", "symbols": ["SID1", "OID$ebnf$1"]},
    {"name": "SID1", "symbols": [/[0-2]/]},
    {"name": "SIDn", "symbols": [/[0-9]/]},
    {"name": "SIDn", "symbols": [/[1-9]/, /[0-9]/]},
    {"name": "SIDn", "symbols": [/[1-9]/, /[0-9]/, /[0-9]/]},
    {"name": "SIDn", "symbols": [/[1-9]/, /[0-9]/, /[0-9]/, /[0-9]/]},
    {"name": "SIDn", "symbols": [/[1-9]/, /[0-9]/, /[0-9]/, /[0-9]/, /[0-9]/]}
]
  , ParserStart: "MAIN"
}
if (typeof module !== 'undefined'&& typeof module.exports !== 'undefined') {
   module.exports = grammar;
} else {
   window.grammar = grammar;
}
})();

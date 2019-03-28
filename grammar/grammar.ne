@{%
const moo = require('moo')

var appendItem = function (a, b) { return function (d) { return d[a].concat([d[b]]); } }

var constructMetaObj = (a, b=null) => { 
	return (d) => { 
		if (b === null) {
			return {'value': d[a].value, 'operand': null}
		} else {
		return {'value': d[a].value, 'operand': d[b].value}}
	}
}

const sharps = ['yellow', 'red', 'orange', 'blue', 'white', 'purple', 'green']
const weps = ['lbg', 'hbg', 'bow', 'sns', 'gs', 'ls', 'db', 'ig', 'gl', 'lance', 'hammer', 'hh']
const games = ['mhgu', 'mhworld']
const keys = ['raw', 'aff', 'hz', 'mv', 'we', 'cb', 'au', 'ch', 'ce', 'sharp', 'gdm']
const mhguAtkSkills = ['aus', 'aum', 'aul']
const totals = [].concat(mhguAtkSkills, weps, games, keys, sharps)

const lexer = moo.compile({
	myError: {match: /[\$?`]/, error: true},
	ws: /[ \t]+/,	
  operand: /[\+\-x]/,
	word: {match: /[a-z]+/,
				 keyword: {
					game: games,
					wep: weps,
					mhguAttackSkills: mhguAtkSkills,
					key: keys,
					sharp: sharps,
				 }},
	decimal: /\d{1,3}\.\d{1,3}/, 
  number: /[0-9]+/,
  punctuaton: /[.,\/#!$%\^&\*;:{}=\-_`~()]+/,
})
%}

@lexer lexer

MAIN              -> PREDATA ":" %ws DATA								{% function (a) {return {"game": a[0].game, "weapon": a[0].weapon, "data": a[3]}} %}
									 | DATA																{% function (a) {return {"game": null, "weapon": null, "data": a[0]}} %}

PREDATA						-> %word %ws WEP											{% (a) => {return {'game': a[0].value, 'weapon': a[2].value}} %}
									 | WEP																{% (a) => {return {'game': null, 'weapon': a[0].value}} %}

WEP								-> %word															{% id %}

DATA              -> SEGMENT
	      		       | DATA "," " " SEGMENT 	  					{% appendItem(0,3) %}

SEGMENT           -> VALUE " " WORD 	  	    					{% (a) => { return [a[2].value, a[0]] } %}
		               | WORD " " VALUE    									{% (a) => { return [a[0].value, a[2]] } %}
		      	       | WORD      													{% (a) => { return [a[0].value, {'value': null, 'operand': null} ] } %}
			             | WORD %ws WORD     									{% (a, d, r) => { if (a[0].text === 'sharp') {return [a[0].value, {'value': a[2].value, 'operand': null}]} else {return [a[2].value, {'value': a[0].value, 'operand': null}]}} %}
                   | WORD VALUE													{% (a) => { return [a[0].value, a[1]] } %}

WORD							-> %word															{% (a) => {if (totals.includes(a[0].value)) {return a[0]} else {return {'value': null}}} %}

VALUE 						-> NUMBER 														{% constructMetaObj(0) %}
	   							 | %operand NUMBER 										{% constructMetaObj(1, 0) %}
								   | NUMBER %operand										{% constructMetaObj(0, 1) %}
	
NUMBER 						-> %number														{% id %}
									 | %decimal 													{% id %}
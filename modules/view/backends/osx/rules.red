Red [
	Title:   "VID macOS GUI post-processing rules"
	Author:  "Nenad Rakocevic"
	File: 	 %rules.red
	Tabs:	 4
	Rights:  "Copyright (C) 2017 Nenad Rakocevic. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/dockimbel/Red/blob/master/BSL-License.txt
	}
]

ok-captions: ["ok" "save" "apply"]
no-capital:  ["a " | "an " | "the " | "and " | "or "]

title-ize: function [text [string!] return: [string!]][
	parse text [
		any #" " some [no-capital | p: (uppercase/part p 1) thru #" "]
	]
	text
]

sentence-ize: function [text [string!] return: [string!]][
	parse text [
		any #" " h: some [
			end
			| remove #"^^" thru #" "					;-- ^ in front of a word to escaped lowercasing
			| s: [thru #" " | to end] e: (lowercase/part s e)
		]
	]
	uppercase/part h 1
]

capitalize: function [
	"Capitalize widget text according to macOS guidelines"
	; https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/OSXHIGuidelines/TerminologyWording.html
	root [object!]
][
	foreach-face/with root [
		if face/menu [
			parse rule: [some [
				pos: string! (title-ize pos/1)
				| into rule
				| skip
			]]
		]
		either find [radio check] face/type [
			sentence-ize face/text
		][
			title-ize face/text
		]
	][
		all [
			face/type = 'button
			face/text
			not empty? face/text
		]
	]
]

Cancel-OK: function [
	"Put OK buttons last"
	root [object!]
][
	foreach-face/with root [
		pos-x: face/offset/x
		face/offset/x: f/offset/x
		f/offset/x: pos-x
	][
		either all [
			face/type = 'button
			find ok-captions face/text
		][
			last-but: none
			pos-x: face/offset/x
			pos-y: face/offset/y

			foreach f face/parent/pane [
				all [
					f <> face
					f/type = 'button
					5 > absolute f/offset/y - pos-y
					pos-x < f/offset/x
					pos-x: f/offset/x
					last-but: f
				]
			]
			last-but
		][no]
	]
]
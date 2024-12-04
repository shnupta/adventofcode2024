import "os" for Process
import "io" for File, Stdout

var count = Process.allArguments.count

if (count != 3 && count != 4) {
	System.print("Usage: wren_cli main.wren input.txt 1|2")
	return
}

var trackEnabled = false

if (count == 4 && Process.allArguments[3] == "2") {
	trackEnabled = true
}

var inputFile = Process.allArguments[2]
System.print("Opening " + Process.allArguments[2])

var contents = File.read(inputFile)

var findNextChar = Fn.new{|s, c|
	var i = 0
	for (j in s[0...s.count]) {
		if (j == c) {
			return i
		}
		i = i + 1
	}
	return null
}

var result = 0
var enabled = true

for (i in 0...contents.count-4) {
	if (contents[i...i+4] == "do()") {
		enabled = true
		continue
	}

	if (i+7 <= contents.count) {
		if (contents[i...i+7] == "don't()") {
			enabled = false
			continue
		}
	}

	if (contents[i...i+4] == "mul(") {
		var firstDigitIdx = i + 4

		// Find next close paren from what should be digit 1
		var nextCloseParen = findNextChar.call(contents[firstDigitIdx...contents.count], ")")
		if (nextCloseParen == null || nextCloseParen > 7 || nextCloseParen < 3) {
			continue
		}

		var insideBrackets = contents[firstDigitIdx...firstDigitIdx+nextCloseParen]
		var comma = findNextChar.call(insideBrackets, ",")
		if (comma == null || comma > 3) {
			continue
		}

		var numOne = Num.fromString(insideBrackets[0...comma])
		var numTwo = Num.fromString(insideBrackets[comma+1...insideBrackets.count])

		if (numOne == null || numTwo == null) {
			continue
		}

		if (!trackEnabled || enabled) {
			result = result + (numOne * numTwo)
		}
	}
}

System.print("result = %(result)")

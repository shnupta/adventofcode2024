import "os" for Process
import "io" for File, Stdout

System.print("Opening %(Process.allArguments[2])")
var contents = File.read(Process.allArguments[2]).trim()

var xmas = "XMAS"
var mas = "MAS"

var lines = contents.split("\n")
var lineCount = lines.count
var lineLength = lines[-1].count

System.print("lineCount=%(lineCount) lineLength=%(lineLength) xmas.count=%(xmas.count)")

var buildWord = Fn.new {|x, y, sequence|
	var ret = []
	for (step in sequence) {
		var tempX = x + step[0]
		var tempY = y + step[1]
		if (tempX < 0 || tempX >= lineLength) return null
		if (tempY < 0 || tempY >= lineCount) return null

		ret.add(lines[tempY][tempX])
	}
	return ret.join()
}

var steps = [
	[1, 0], [-1, 0], // horizontal right left
	[1, 1], [1, -1], // diagonal right down up
	[-1, 1], [-1, -1], // diagonal left down up
	[0, 1], [0, -1] // vertical down up
]

var xmasSequences = steps.map{|xy|
	var ret = [[0, 0]] // always start from cur x,y
	for (i in 1...xmas.count) {
		ret.add([xy[0] * i, xy[1] * i])
	}
	return ret
}

var masSequences = [
	[[-1, -1], [0, 0], [1, 1]], // top left to bottom right
	[[-1, 1], [0, 0], [1, -1]], // bottom left to top right
	[[1, 1], [0, 0], [-1, -1]], // bottom right to top left
	[[1, -1], [0, 0], [-1, 1]]  // top right to bottom left
]

var checkWord = Fn.new{|x, y, sequence, word|
	return buildWord.call(x, y, sequence) == word
}

var checkSequences = Fn.new{|x, y, sequences, match|
	var count = 0
	for (sequence in sequences) {
		count = count + (checkWord.call(x, y, sequence, match) ? 1 : 0)
	}
	return count
}

var xmasCount = 0
var masCount = 0

for (y in 0...lineCount) {
	for (x in 0...lineLength) {
		xmasCount = xmasCount + checkSequences.call(x, y, xmasSequences, xmas)
		masCount = masCount + (checkSequences.call(x, y, masSequences, mas) / 2).floor
	}
}

System.print("XMAS count %(xmasCount)")
System.print("MAS count %(masCount)")

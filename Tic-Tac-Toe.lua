PLAYER_1_HUMAN = false
PLAYER_2_HUMAN = true

BOARD_RANK = 5

PLAYER_1 = "x"
PLAYER_2 = "o"
EMPTY_SPACE = " "
DISPLAY_HORIZONTAL_SEPARATOR = "-"
DISPLAY_VERTICAL_SEPARATOR = " | "

MAX_BOARD_RANK = 5
if BOARD_RANK > MAX_BOARD_RANK then os.exit(0) end

X = -1
Y = -1

Space = {}
for i = 0, (BOARD_RANK - 1) do
	Space[i] = {}
	for j = 0, (BOARD_RANK - 1) do
		Space[i][j] = nil
	end
end

function GetPiece(x, y)
	return Space[x][y]
end

function GetPieceNoNil(x, y)
	if GetPiece(x, y) ~= nil then
		return GetPiece(x, y)
	else
		return EMPTY_SPACE
	end	
end

function IsEmpty(x, y)
	if GetPiece(x, y) == nil then
		return true
	else
		return false
	end
end

function PlacePiece(x, y, piece)
	if IsEmpty(x, y) == true then
		Space[x][y] = piece
		return true
	else
		return false
	end
end

function IsGameOver(piece)
	if CheckWin(piece) == false then
		for i = 0, (BOARD_RANK - 1) do
			for j = 0, (BOARD_RANK - 1) do
				if IsEmpty(i, j) == true then 
                    return false
                end
			end
		end
		return true
	else
		return true
	end
end

function RepeatString(to_repeat, amount)
	if amount <= 0 then
        return ""
    end
	local to_return = ""
	for i = 1, amount do
		to_return = to_return .. to_repeat
	end
	return to_return
end

function DisplayBoard()
	local widest_piece = math.max(string.len(PLAYER_1), string.len(PLAYER_2), string.len(EMPTY_SPACE))

	io.write("\n")
	for i = (BOARD_RANK - 1), 0, -1 do
		local row = ""
		for j = 0, (BOARD_RANK - 1) do
			local piece = GetPieceNoNil(j, i)
			row = row .. piece
			row = row .. RepeatString(" ", widest_piece - string.len(piece))
			if j ~= (BOARD_RANK - 1) then
				row = row .. DISPLAY_VERTICAL_SEPARATOR
			end
		end
		io.write(row)
		if i ~= 0 then
			io.write("\n")
			local repeats = math.ceil(string.len(row) / string.len(DISPLAY_HORIZONTAL_SEPARATOR))
			io.write(RepeatString(DISPLAY_HORIZONTAL_SEPARATOR, repeats))
			io.write("\n")
		end
	end

	io.write("\n")
end

Region = {}
Region_number = 0

for i = 0, (BOARD_RANK - 1) do
	Region[Region_number] = {}
	for j = 0, (BOARD_RANK - 1) do
		Region[Region_number][j] = {}
		Region[Region_number][j]["x"] = i
		Region[Region_number][j]["y"] = j
	end
	Region_number = Region_number + 1
end

for i = 0, (BOARD_RANK - 1) do
	Region[Region_number] = {}
	for j = 0, (BOARD_RANK - 1) do
		Region[Region_number][j] = {}
		Region[Region_number][j]["x"] = j
		Region[Region_number][j]["y"] = i
	end
	Region_number = Region_number + 1
end

Region[Region_number] = {}
for i = 0, (BOARD_RANK - 1) do
	Region[Region_number][i] = {}
	Region[Region_number][i]["x"] = i
	Region[Region_number][i]["y"] = i
end
Region_number = Region_number + 1

Region[Region_number] = {}
for i = (BOARD_RANK - 1), 0, -1 do
	Region[Region_number][i] = {}
	Region[Region_number][i]["x"] = BOARD_RANK - i - 1
	Region[Region_number][i]["y"] = i
end
Region_number = Region_number + 1

function GetRegion(number)
	return Region[number]
end

function CheckWinInRegion(number)
	local to_return = 0
	for i, v in pairs(GetRegion(number)) do
		local piece = GetPiece(v["x"], v["y"])
		if piece == PLAYER_1 then
            if to_return < 0 then
                return 0
            end
            to_return = to_return + 1
        end
		if piece == PLAYER_2 then
            if to_return > 0 then
                return 0
            end
            to_return = to_return - 1
        end
	end
	return to_return
end

function CheckWin(piece)
    local curDirectionNumOfPiecesInSequence = {}
    for i = 1, 4 do
        curDirectionNumOfPiecesInSequence[i] = 1
    end
    local curDirection = 1
    local isRepeatedDirection = false
	for i = -1, 1 do
        for j = -1, 1 do
            if (i ~= 0 or j ~= 0) then
                local endOfSequence = false
                local numOfRepeat = 1
                local numOfPiecesInSequence = 0
                while not endOfSequence do
                    if (X + (i * numOfRepeat) >= 0 and X + (i * numOfRepeat) < BOARD_RANK and Y + (j * numOfRepeat) >= 0 and Y + (j * numOfRepeat) < BOARD_RANK and GetPiece(X + (i * numOfRepeat), Y + (j * numOfRepeat)) == piece) then
                        numOfRepeat = numOfRepeat + 1
                        numOfPiecesInSequence = numOfPiecesInSequence + 1
                        if (curDirectionNumOfPiecesInSequence[curDirection] + numOfPiecesInSequence >= BOARD_RANK) then
                            return GetPiece(X, Y)
                        end
                    else
                        curDirectionNumOfPiecesInSequence[curDirection] = curDirectionNumOfPiecesInSequence[curDirection] + numOfPiecesInSequence
                        if curDirection ~= 4 or (curDirection == 4 and isRepeatedDirection) then
                            if not isRepeatedDirection then
                                curDirection = curDirection + 1
                            else
                                curDirection = curDirection - 1
                            end
                        end
                        endOfSequence = true
                    end
                end
            else 
                if isRepeatedDirection == false then
                    isRepeatedDirection = true
                end
            end
        end
    end
	return false
end

function CheckValidate(coordinate)
    local value = 0
    repeat
        io.write("Give the ", coordinate, "-coordinate (starting with 0). ")
        local valid = true
        value = tonumber(io.read())
        if value < 0 or value > BOARD_RANK - 1 then
            io.write("Enter correct coordinate between 0 and ", BOARD_RANK - 1, " !!!\n")
            valid = false
        end
    until valid == true
    return value
end

function HumanPlay(piece)
	io.write(piece .. ", here's the board:\n")
	DisplayBoard()
	local placed = false
	while placed == false do
		io.write("\nWhere would you like to play your " .. piece .. "?\n")
        X = CheckValidate("X")
		Y = CheckValidate("Y")
		placed = PlacePiece(X, Y, piece)
		if placed == false then
			io.write("I'm afraid you can't play there!")
		end
	end
	DisplayBoard()
	io.write("\n")
	
end

function AIPlay(piece)
	local me = 0
	if piece == PLAYER_1 then
        me = 1
    end
	if piece == PLAYER_2 then
        me = -1
    end

	for i in pairs(Region) do
		local win = CheckWinInRegion(i)
		if win == ((BOARD_RANK - 1) * me) then
			for j, v in pairs(GetRegion(i)) do
				if IsEmpty(v["x"], v["y"]) == true then
					PlacePiece(v["x"], v["y"], piece)
                    X = v["x"]
                    Y = v["y"]
					return
				end
			end
		end
	end

	for i in pairs(Region) do
		local win = CheckWinInRegion(i)
		if win == ((BOARD_RANK - 1) * (me * -1)) then
			for j, v in pairs(GetRegion(i)) do
				if IsEmpty(v["x"], v["y"]) == true then
					PlacePiece(v["x"], v["y"], piece)
                    X = v["x"]
                    Y = v["y"]
					return
				end
			end
		end
	end

    local mostWinSlots = {}
    local mostWin = 0
    for i in pairs(Region) do
		local win = CheckWinInRegion(i)
        if win > mostWin then
            mostWin = win
            for j = 1, #mostWinSlots do
                table.remove(mostWinSlots)
            end
            table.insert(mostWinSlots, i)
        end
        if win == mostWin then
            table.insert(mostWinSlots, i)
        end
	end
    while #mostWinSlots > 0 do
        math.randomseed(os.time())
        local a = math.random(1, #mostWinSlots)
        for j, v in pairs(GetRegion(mostWinSlots[a])) do
            if IsEmpty(v["x"], v["y"]) == true then
                PlacePiece(v["x"], v["y"], piece)
                X = v["x"]
                Y = v["y"]
                return
            end
        end
        table.remove(mostWinSlots, a)
    end
end

io.write("Welcome to Tic-Tac-Toe!\n\n")

while true do

	if PLAYER_1_HUMAN == true then
        HumanPlay(PLAYER_1)
	else
        AIPlay(PLAYER_1)
    end

	if IsGameOver(PLAYER_1) == true then
        break
    end

	if PLAYER_2_HUMAN == true then
        HumanPlay(PLAYER_2)
	else
        AIPlay(PLAYER_2)
    end

	if IsGameOver(PLAYER_2) == true then
        break
    end
end

io.write("The final board:\n")
DisplayBoard()
io.write("\n")

Win = CheckWin(PLAYER_1)
if Win == PLAYER_1 then
    io.write(Win)
    io.write(" wins!\n")
else
    Win = CheckWin(PLAYER_2)
    if Win == PLAYER_2 then
        io.write(Win)
	    io.write(" wins!\n")
    else
        io.write("Tie game!\n")
    end
end

--------------------------------------------------------------------------------
-- Version       : 0.1
-- File          : dinku.lua
-- Author        : Harish Sharma
-- Email         : sharmaharish@gmail.com
-- Last modified : 11th May 2007
--------------------------------------------------------------------------------

dofile("prelude.lua")
--
BL = 2 -- black
WH = 1 -- white
_E = 0
_X = -1
--
game = { turn     = WH,
﻿  ﻿   rival    = BL,
﻿  ﻿   maxdepth = 6,
﻿  ﻿   lastmove = 0,
﻿  ﻿   self     = BL,
﻿  ﻿   moves    = {},
﻿  ﻿   genmoves = {},
﻿  ﻿   fromto   = {},
﻿  ﻿   pvmoves  = {},

﻿  ﻿   board =  { _X, _X, _X, _X, _X, _X, _X, _X, _X, _X,
﻿  ﻿  ﻿  ﻿  ﻿  _X, _E, _E, _E, _E, _E, _E, _E, _E, _X,
﻿  ﻿  ﻿  ﻿  ﻿  _X, _E, _E, _E, _E, _E, _E, _E, _E, _X,
﻿  ﻿  ﻿  ﻿  ﻿  _X, _E, _E, _E, _E, _E, _E, _E, _E, _X,
﻿  ﻿  ﻿  ﻿  ﻿  _X, _E, _E, _E, WH, BL, _E, _E, _E, _X,
﻿  ﻿  ﻿  ﻿  ﻿  _X, _E, _E, _E, BL, WH, _E, _E, _E, _X,
﻿  ﻿  ﻿  ﻿  ﻿  _X, _E, _E, _E, _E, _E, _E, _E, _E, _X,
﻿  ﻿  ﻿  ﻿  ﻿  _X, _E, _E, _E, _E, _E, _E, _E, _E, _X,
﻿  ﻿  ﻿  ﻿  ﻿  _X, _E, _E, _E, _E, _E, _E, _E, _E, _X,
﻿  ﻿  ﻿  ﻿  ﻿  _X, _X, _X, _X, _X, _X, _X, _X, _X, _X },

﻿  ﻿  values = {  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
﻿  ﻿  ﻿  ﻿  ﻿  0,32,16,12, 8, 8,12,16,32, 0,     -- values of board elements
﻿  ﻿  ﻿  ﻿  ﻿  0,16, 0, 0, 0, 0, 0, 0,16, 0,
﻿  ﻿  ﻿  ﻿  ﻿  0,12, 0, 1, 1, 1, 1, 0,12, 0,
﻿  ﻿  ﻿  ﻿  ﻿  0, 8, 0, 1, 4, 4, 1, 0, 8, 0,
﻿  ﻿  ﻿  ﻿  ﻿  0, 8, 0, 1, 4, 4, 1, 0, 8, 0,
﻿  ﻿  ﻿  ﻿  ﻿  0,12, 0, 1, 1, 1, 1, 0,12, 0,
﻿  ﻿  ﻿  ﻿  ﻿  0,16, 0, 0, 0, 0, 0, 0,16, 0,
﻿  ﻿  ﻿  ﻿  ﻿  0,32,16,12, 8, 8,12,16,32, 0,
﻿  ﻿  ﻿  ﻿  ﻿  0, 0, 0, 0, 0, 0, 0, 0, 0, 0},

﻿  ﻿  offsets = { 1, -1, 9, -9, 10, -10, 11, -11 }, -- offsets in 8 directions
﻿  }

-- swaps the variables turn and rival
function swap_turns() game.turn, game.rival = game.rival, game.turn end

-- displays the reversi board
function display_board()
﻿  local function lformat(from, to)
﻿  ﻿  local t = ""
﻿  ﻿  for i = from, to, 1 do
﻿  ﻿  ﻿  local v = game.board[i]
﻿  ﻿  ﻿  if v == -1 then t = t .. "" end
﻿  ﻿  ﻿  if v == 0 then t = t .. ".  " end
﻿  ﻿  ﻿  if v == 1 then t = t .. "o  " end
﻿  ﻿  ﻿  if v == 2 then t = t .. "#  " end
﻿  ﻿  end
﻿  ﻿  return t
﻿  end
﻿  print(string.format("\n\n%d  %d  %d  %d  %d  %d  %d  %d  %d\n", 0,1,2,3,4,5,6,7,8,"\n"))
﻿  for i = 11, 90, 10 do
﻿  ﻿  if i > 10 and i < 90 then
﻿  ﻿  ﻿  print(string.format("%d  %s\n", (i - 1)/10, lformat(i + 1, i + 8)))
﻿  ﻿  end
﻿  end
﻿  if #game.moves == 0 then return end
﻿  io.write("\nmoves [")
﻿  for i=1,#game.moves,1 do
﻿  ﻿  io.write(game.moves[i][1] - 1, ",") end
﻿  io.write("]")
﻿  local cr = count_if(function(i, v) return v == WH end, game.board)
﻿  local cs = count_if(function(i, v) return v == BL end, game.board)
﻿  io.write("\nyou [", cr, "] / computer [", cs, "]\n")
end

-- traverses in all direction from 'from' and turns the relevant coins if the
-- move is valid, also it returns a list of coins turned
function make_move(from)
﻿  local ml = {}
﻿  local function lhelper(old, new, ofs)
﻿  ﻿  if game.board[new] == _E or game.board[new] == _X then return false end
﻿  ﻿  if game.board[new] == game.rival then
﻿  ﻿  ﻿  if lhelper(new, new + ofs, ofs) then
﻿  ﻿  ﻿  ﻿  game.board[new] = game.turn
﻿  ﻿  ﻿  ﻿  ml[#ml + 1] = new
﻿  ﻿  ﻿  ﻿  return true
﻿  ﻿  ﻿  end
﻿  ﻿  elseif game.board[new] == game.turn then
﻿  ﻿  ﻿  return from + ofs ~= new
﻿  ﻿  end
﻿  end
﻿  for i,v in ipairs(game.offsets) do
﻿  ﻿  lhelper(from, from + v, v)
﻿  end
﻿  if #ml > 0 then game.board[from] = game.turn end
﻿  swap_turns()
﻿  return ml
end

-- undoes what make_move committed, i is the ordinate in either game.moves or
-- games.genmoves and the table is selected on the basis of the second boolean arg
function unmake_move(i, searching)
﻿  local l = nil
﻿  local m = nil
﻿  local s = nil
﻿  if searching then
﻿  ﻿  l = game.genmoves[i][2]
﻿  ﻿  m = game.genmoves[i][1]
﻿  else
﻿  ﻿  l = game.moves[i][2]
﻿  ﻿  m = game.moves[i][1]
﻿  end
﻿  if game.board[m] == WH then s = BL else s = WH end
﻿  for j,v in ipairs(l) do
﻿  ﻿  game.board[v] = s
﻿  end
﻿  game.board[m] = _E
﻿  if not searching then game.moves[i] = nil end
﻿  swap_turns()
end

-- traverses in all directions and checks to see if the move is valid
function is_move_valid(i)
﻿  local function ltraverse(from)
﻿  ﻿  local function lhelper(old, new, ofs)
﻿  ﻿  ﻿  if game.board[new] == _E or game.board[new] == _X then return false end
﻿  ﻿  ﻿  if game.board[new] == game.rival then
﻿  ﻿  ﻿  ﻿  return lhelper(new, new + ofs, ofs)
﻿  ﻿  ﻿  elseif game.board[new] == game.turn then
﻿  ﻿  ﻿  ﻿  return new ~= (i + ofs) -- this should not be the very next cell
﻿  ﻿  ﻿  end
﻿  ﻿  end
﻿  ﻿  for i,v in ipairs(game.offsets) do
﻿  ﻿  ﻿  if lhelper(from, from + v, v) then return true end
﻿  ﻿  end
﻿  ﻿  return false
﻿  end
﻿  return ltraverse(i)
end

-- generates moves for the current ply
function generate_moves()
﻿  for i, v in ipairs(game.board) do
﻿  ﻿  if game.board[i] == _E and is_move_valid(i) then
﻿  ﻿  ﻿  game.genmoves[#game.genmoves + 1] = {i, nil}
﻿  ﻿  end
﻿  end
end

-- evaluates the score for individual cells on board and returns a final number
function evaluate()
﻿  local turn = game.turn
﻿  local rival = game.rival
﻿  local function score(n)
﻿  ﻿  if game.board[n] == turn then return game.values[n]
﻿  ﻿  elseif game.board[n] == rival then return -game.values[n]
﻿  ﻿  else return 0
﻿  ﻿  end
﻿  end
﻿  local function helper(i)
﻿  ﻿  if i <= 90 then return score(i) + helper(i + 1)
﻿  ﻿  else return 0 end
﻿  end
﻿  return helper(11)
end

-- think ? yeah i can think - uses iterative deepening, which is not exactly
-- beneficial without move-ordering, but once move-ordering and time control
-- is added this will be essential for alpha-beta pruning
function think(depth)
﻿  if depth > game.maxdepth then return end
﻿  game.genmoves = {}
﻿  game.fromto = {}
﻿  game.pvmoves = {}
﻿  ct, cr = game.turn, game.rival
﻿  search(1, depth, -999999, 999999)
﻿  game.turn, game.rival = ct, cr
﻿  think(depth + 1)
end

-- searches for the best possible move using alpha-beta pruning but without any
-- move ordering, so it is kinda eqv to minmax
-- move ordering, transposition table and other techniques will be added in
-- the next version to make the engine stronger
function search(ply, depth, alpha, beta)
﻿  local ispv = false
﻿  if ply > depth then return evaluate() end
﻿  local from = #game.genmoves + 1
﻿  generate_moves()
﻿  local to = #game.genmoves
﻿  if from > to then return evaluate() end
﻿  game.fromto[#game.fromto + 1] = {from, to}
﻿  local score = -999999
﻿  for i = from, to, 1 do
﻿  ﻿  if game.genmoves[i][1] == nil then debug.debug() end
﻿  ﻿  game.genmoves[i][2] = make_move(game.genmoves[i][1])
﻿  ﻿  if ispv then
﻿  ﻿  ﻿  score = -search(ply + 1, depth, -alpha - 1, -alpha)
﻿  ﻿  ﻿  if score > alpha and score < beta then
﻿  ﻿  ﻿  ﻿  score = -search(ply + 1, depth, -beta, -alpha)
﻿  ﻿  ﻿  end
﻿  ﻿  else
﻿  ﻿  ﻿  score = -search(ply + 1, depth, -beta, -alpha)
﻿  ﻿  end
﻿  ﻿  unmake_move(i, true)
﻿  ﻿  if score >= beta then return beta end
﻿  ﻿  if score > alpha then
﻿  ﻿  ﻿  alpha = score
﻿  ﻿  ﻿  ispv = true
﻿  ﻿  ﻿  game.pvmoves[ply] = game.genmoves[i][1]
﻿  ﻿  end
﻿  end
﻿  return alpha
end

-- this is where it starts
function play()
﻿  local function ltranslate(mov)
﻿  ﻿  return mov + 1
﻿  end
﻿  local function is_game_over()
﻿  ﻿  game.genmoves = {}
﻿  ﻿  generate_moves()
﻿  ﻿  if #game.genmoves == 0 then
﻿  ﻿  ﻿  swap_turns()
﻿  ﻿  ﻿  generate_moves()
﻿  ﻿  ﻿  if #game.genmoves == 0 then
﻿  ﻿  ﻿  ﻿  return true
﻿  ﻿  ﻿  end
﻿  ﻿  end
﻿  ﻿  game.genmoves = {}
﻿  ﻿  return false
﻿  end
﻿  local function declare_winner()
﻿  ﻿  local self = count_if(function(i, v) return v == BL end, game.board)
﻿  ﻿  local riva = count_if(function(i, v) return v == WH end, game.board)
﻿  ﻿  if self > riva then print("\nI win.")
﻿  ﻿  elseif riva > self then print("\nYou win.")
﻿  ﻿  else print("\nWe both win !")
﻿  ﻿  end
﻿  end
﻿  while true do
﻿  ﻿  display_board()
﻿  ﻿  local t = nil
﻿  ﻿  local v = true
﻿  ﻿  if game.turn ~= game.self then
﻿  ﻿  ﻿  io.write("enter move : ")
﻿  ﻿  ﻿  local m = ltranslate(io.read())
﻿  ﻿  ﻿  if is_move_valid(m) then
﻿  ﻿  ﻿  ﻿  t = {m, make_move(m)}
﻿  ﻿  ﻿  ﻿  game.moves[#game.moves + 1] = t
﻿  ﻿  ﻿  else
﻿  ﻿  ﻿  ﻿  v = false
﻿  ﻿  ﻿  ﻿  print("error [wrong move, please try again.]")
﻿  ﻿  ﻿  end
﻿  ﻿  else
﻿  ﻿  ﻿  io.write("\nthinking ... ")
﻿  ﻿  ﻿  local time = os.clock()
﻿  ﻿  ﻿  think(game.maxdepth)
﻿  ﻿  ﻿  io.write("took ", os.clock() - time, " seconds.\n")
﻿  ﻿  ﻿  if game.pvmoves[1] == nil then debug.debug() end
﻿  ﻿  ﻿  t = {game.pvmoves[1], make_move(game.pvmoves[1])}
﻿  ﻿  ﻿  game.moves[#game.moves + 1] = t
﻿  ﻿  end
﻿  ﻿  if v and is_game_over() then display_board() declare_winner() break end
﻿  end
end

play()

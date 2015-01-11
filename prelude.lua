--------------------------------------------------------------------------------
-- Version       : 0.1
-- File          : prelude.lua
-- Author        : Harish Sharma
-- Email         : sharmaharish@gmail.com
-- Last modified : 11th May 2007
--------------------------------------------------------------------------------

-- generates iterator for the given tab/list
function iterator(t)
﻿  local i = 0
﻿  local n = #t
﻿  return function ()
﻿  ﻿  ﻿  i = i + 1
﻿  ﻿  ﻿  if i <= n then return t[i] end
﻿  ﻿  end
end

--
function for_each(proc, tab)
﻿  for i, v in ipairs(tab) do
﻿  ﻿  proc(i, v)
﻿  end
end

-- map the function proc to each member in tab and returns a new tab
function map(proc, tab)
﻿  local ntab = {}
﻿  for i,v in ipairs(tab) do
﻿  ﻿  ntab[i] = proc(v)
﻿  end
﻿  return ntab
end

-- applies the proc to the tab elements
function apply(proc, tab)
﻿  for i, v in ipairs(tab) do
﻿  ﻿  tab[i] = proc(i, v)
﻿  end
end

-- applies the proc to the tab elements if the predicate succeeds
function apply_if(pred, proc, tab)
﻿  for i, v in ipairs(tab) do
﻿  ﻿  if pred(i, v) then tab[i] = proc(i, v) end
﻿  end
end

-- fold method
function fold(init, oper, proc, tab)
﻿  local agg = init
﻿  for i,v in ipairs(tab) do
﻿  ﻿  agg = oper(agg, proc(i, v))
﻿  end
﻿  return agg
end

-- filters a tab on the basis of a predicate function and returns a new tab
function filter(predicate, tab)
﻿  local ntab = {}
﻿  local j = 0
﻿  for i,v in ipairs(tab) do
﻿  ﻿  if predicate(i, v) then
﻿  ﻿  ﻿  j = j + 1
﻿  ﻿  ﻿  ntab[j] = v
﻿  ﻿  end
﻿  end
﻿  return ntab
end

-- counts elements in tab on the basis of predicate function and returns count
function count_if(predicate, tab)
﻿  local cnt = 0
﻿  for i,v in ipairs(tab) do
﻿  ﻿  if predicate(i, v) then cnt = cnt + 1 end
﻿  end
﻿  return cnt
end

-- compose a function combining 2 different functions
function compose(F, G)
﻿  local f1 = F
﻿  local f2 = G
﻿  return function (a)
﻿  ﻿  return f1(f2(a))
﻿  end
end

-- finds the first index for which the predicate succeeds
function find_if(pred, tab)
﻿  for i,v in ipairs(tab) do
﻿  ﻿  if pred(i, v) then return i end
﻿  end
﻿  return nil
end

-- generic swap function
function swap(tab, a, b) tab[a], tab[b] = tab[b], tab[a] end

-- bubble sort for sorting short lists
function bubble_sort(tab, pred, sw)
﻿  for i=1,#tab-1,1 do
﻿  ﻿  for j=i+1,#tab,1 do
﻿  ﻿  ﻿  if pred(tab[i], tab[j]) then sw(tab, i, j) end
﻿  ﻿  end
﻿  end
end
-- takes a binary function and binds 1st arg to the given constant
function bind1st(binfun, val)
﻿  return function (a) return binfun(val, a) end
end

-- takes a binary function and binds 2nd arg to the given constant
function bind2nd(binfun, val)
﻿  return function (a) return binfun(a, val) end
end

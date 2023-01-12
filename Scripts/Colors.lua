function PlayerColor( pn )
   if pn == PLAYER_1 then return "#196bff" end  -- Blue
   if pn == PLAYER_2 then return "#ca4bff" end  -- Purple
   return "1,1,1,1"
end

function DifficultyColor( dc )

	if dc == DIFFICULTY_BEGINNER		then return "#D05CF6" end
	if dc == DIFFICULTY_EASY		then return "#09FF10" end
	if dc == DIFFICULTY_MEDIUM		then return "#F3F312" end
	if dc == DIFFICULTY_HARD		then return "#EA3548" end
	if dc == DIFFICULTY_CHALLENGE		then return "#16AFF3" end
	if dc == DIFFICULTY_EDIT		then return "#F7F7F7" end
	return "1,1,1,1"
end

-- Get a color to show text on top of difficulty frames.
function ContrastingDifficultyColor( dc )
--   if dc == DIFFICULTY_BEGINNER  then return "#FF0000" end
--   if dc == DIFFICULTY_EASY      then return "#FF0000" end
--   if dc == DIFFICULTY_MEDIUM    then return "#FF0000" end
--   if dc == DIFFICULTY_HARD      then return "#009900" end
--   if dc == DIFFICULTY_CHALLENGE then return "#009900" end
--   if dc == DIFFICULTY_EDIT      then return "#009900" end
return "1,1,1,1"
end


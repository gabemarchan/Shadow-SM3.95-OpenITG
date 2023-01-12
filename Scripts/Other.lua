-- Override these in other themes.
function Platform() return "generic" end
function IsHomeMode() return false end

function SelectButtonAvailable()
   return true
end

function StageBanner()
	if not GAMESTATE:IsCourseMode() then return "songbanner"
	else return "coursebanner"
	end
end

function GetWorkoutMenuCommand()
   GAMESTATE:SetTemporaryEventMode(true)
   return "difficulty," .. GetInitialDifficulty() .. ";screen,ScreenWorkoutMenu;PlayMode,regular;SetEnv,Workout,1"
end

function ScreenEndingGetDisplayName( pn )
   if PROFILEMAN:IsPersistentProfile(pn) then return GAMESTATE:GetPlayerDisplayName(pn) end
   return "No Card"
end

function profilesongs( pn )
return "Played Songs:\n" .. PROFILEMAN:GetProfile(pn):GetTotalNumSongsPlayed()

end

function GetSerialNumberDisplay()
	local serial = GetSerialNumber()
	if serial == "???" then return "No Serial number found"
	else return serial
	end
end

function SSMSongLocText( actor )
   Trace( "SSMSongLocText" )
   local song = GAMESTATE:GetCurrentSong();
   local text = ""
   local short = ""
   if song then
	local fulldir = song:GetSongDir();
	if string.find(fulldir, "@mc1") or string.find(fulldir, "@mc2") then
	short = string.sub(fulldir, 7, -2);
	else
	short = string.sub(fulldir, 8, -2);
	end
	end
	text = short
 
   actor:settext( text )
end

function SSMCourseLocText( actor )
   Trace( "SSMCourseLocText" )
   local course = GAMESTATE:GetCurrentCourse();
   local text = ""
   local short = ""
   if course then
      if OpenITG then
	   local fulldir = course:GetCourseDir();
	   if string.find(fulldir, "@mc1") or string.find(fulldir, "@mc2") then
	   short = string.sub(fulldir, 7, -5);
	   else
	   short = string.sub(fulldir, 2, -5);
	   end
   end
	end
	text = short

   actor:settext( text )
end

--function GetSerialNumber()
--return "mmmmhmm"
--end

function StopCourseEarly()
   -- Stop gameplay between songs in Fitess: Random Endless if all players have
   -- completed their goals.
   if not GAMESTATE:GetEnv("Workout") then return "0" end
   if GAMESTATE:GetPlayMode() ~= PLAY_MODE_ENDLESS then return "0" end
   for pn = PLAYER_1,NUM_PLAYERS-1 do
      if GAMESTATE:IsPlayerEnabled(pn) and not GAMESTATE:IsGoalComplete(pn) then return "0" end
   end
   return "1"
end

--
-- Workout
--
function WorkoutResetStageStats()
   STATSMAN:Reset()
end

function WorkoutGetProfileGoalType( pn )
   return PROFILEMAN:GetProfile(pn):GetGoalType()
end

function WorkoutGetStageCalories( pn )
   return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetCaloriesBurned()
end

function WorkoutGetTotalCalories( pn )
   return STATSMAN:GetAccumStageStats():GetPlayerStageStats(pn):GetCaloriesBurned()
end

function WorkoutGetTotalSeconds( pn )
   return STATSMAN:GetAccumStageStats():GetGameplaySeconds()
end

function WorkoutGetGoalCalories( pn )
   return PROFILEMAN:GetProfile(pn):GetGoalCalories()
end

function WorkoutGetGoalSeconds( pn )
   return PROFILEMAN:GetProfile(pn):GetGoalSeconds()
end

function WorkoutGetPercentCompleteCalories( pn )
   return WorkoutGetTotalCalories(pn) / WorkoutGetGoalCalories(pn)
end

function WorkoutGetPercentCompleteSeconds( pn )
   return WorkoutGetTotalSeconds(pn) / WorkoutGetGoalSeconds(pn)
end

--
-- Options
--
function RestoreDefaults( pn )
   if pn == PLAYER_2 then
      Trace( "skip RestoreDefaults" )
      return
   end

   Trace( "RestoreDefaults" )

   PREFSMAN:SetPreference( "ControllerMode", 0 )
   PREFSMAN:SetPreference( "TwoControllerDoubles", false )
   PREFSMAN:SetPreference( "SongsPerPlay", 3 )
   PREFSMAN:SetPreference( "EventMode", false )
   PREFSMAN:SetPreference( "LifeDifficultyScale", 1 )

   local Table = PROFILEMAN:GetMachineProfile():GetSaved()
   Table["DefaultSort"] = GetDefaultSort()
   Table["DefaultDifficulty"] = GetDefaultDifficulty()

   PREFSMAN:SetPreference( "BGBrightness", .4 )
   PREFSMAN:SetPreference( "GlobalOffsetSeconds", 0 )
   PREFSMAN:SetPreference( "Autosave", true )
end

-- Home unlock (stubs):
function GetUnlockCommand() return "playcommand,NoUnlock" end
function FinalizeUnlock() end

-- Arcade unlocks:
function Unlock( Title )
   local Code = UNLOCKMAN:FindCode( Title )
   if Code then
      UNLOCKMAN:UnlockCode( Code )
   end

   -- Set the song as preferred, even if it's no longer an unlock.
   NewHelpText = {}
   local s = SONGMAN:FindSong( Title )
   if s then
      GAMESTATE:SetPreferredSong( s )
      NewHelpText[1] = "Unlocked " .. s:GetDisplayFullTitle() .. "!"
   end

   -- Get a list of steps (not songs) we just unlocked, and send a message to display
   -- them in HelpText.
   if Code then
      local Songs, Steps = UNLOCKMAN:GetStepsUnlockedByCode( Code )
      for x in Songs do
         NewHelpText[x+1] = "Unlocked " .. Songs[x]:GetDisplayFullTitle() .. " " .. DifficultyToThemedString(Steps[x]) .. "!"
      end
   end

   -- Only set the HelpText if this is actually a locked song for this game.  Don't do
   -- it if it's an old unlock code from a previous game.  (Do show it if it was already
   -- unlocked, though, so people can re-enter a code to see which steps were unlocked.)
   if Code then
      MESSAGEMAN:Broadcast( "ChangeHelpText" )
   end
   NewHelpText = nil

   -- The ITG2 menu music is much stronger than ITG1's, drowning out the unlock
   -- sounds.  Dim the music to 20% for 3 seconds while we play the unlock sound.
   -- This will stay dimmed briefly after the unlock sound plays.  That's OK; it
   -- helps emphasize the sound and prevents the music changes from being too busy.
   SOUND:DimMusic( 0.2, 3 )

   local Path = THEME:GetPath( EC_SOUNDS, '', "Unlocked " .. Title )
   SOUND:PlayOnce( Path )
end

function SetDifficultyFrameFromSteps( Actor, pn )
   Trace( "SetDifficultyFrameFromSteps" )
   local steps = GAMESTATE:GetCurrentSteps( pn );
   if steps then
      Actor:setstate(steps:GetDifficulty())
   end
end

function SetDifficultyFrameFromGameState( Actor, pn )
   Trace( "SetDifficultyFrameFromGameState" )
   local trail = GAMESTATE:GetCurrentTrail( pn );
   if trail then
      Actor:setstate(trail:GetDifficulty())
   else
      SetDifficultyFrameFromSteps( Actor, pn )
   end
end

function SetFromSongTitleAndCourseTitle( actor )
   Trace( "SetFromSongTitleAndCourseTitle" )
   local song = GAMESTATE:GetCurrentSong();
   local course = GAMESTATE:GetCurrentCourse();
   local text = ""
   if song then
      text = song:GetDisplayFullTitle()
   end
   if course then
      text = course:GetDisplayFullTitle() .. " - " .. text;
   end

   actor:settext( text )
end

function SetFromSongTitleAndCourseTitleEvaluation( actor )
   Trace( "SetFromSongTitleAndCourseTitle" )
   local song = GAMESTATE:GetCurrentSong();
   local course = GAMESTATE:GetCurrentCourse();
   local text = ""
   if song then
      text = song:GetDisplayFullTitle()
   end
   if course then
      text = course:GetDisplayFullTitle();
   end

   actor:settext( text )
end

function SetRemovedText(self, port)
   local CurrentSong = GAMESTATE:GetCurrentSong()
   if CurrentSong and string.find( CurrentSong:GetDisplayFullTitle(), "Disconnected" ) then
      self:settext( "The controller in controller port " .. port .. " has been disconnected." )
      return
   end

   self:settext( "The controller in controller port " .. port .. " has been removed." )
end


function GetActual( stepsType )
   return
      PROFILEMAN:GetMachineProfile():GetSongsActual(stepsType,DIFFICULTY_EASY)+
      PROFILEMAN:GetMachineProfile():GetSongsActual(stepsType,DIFFICULTY_MEDIUM)+
      PROFILEMAN:GetMachineProfile():GetSongsActual(stepsType,DIFFICULTY_HARD)+
      PROFILEMAN:GetMachineProfile():GetSongsActual(stepsType,DIFFICULTY_CHALLENGE)+
      PROFILEMAN:GetMachineProfile():GetCoursesActual(stepsType,COURSE_DIFFICULTY_REGULAR)+
      PROFILEMAN:GetMachineProfile():GetCoursesActual(stepsType,COURSE_DIFFICULTY_DIFFICULT)
end

function GetPossible( stepsType )
   return
      PROFILEMAN:GetMachineProfile():GetSongsPossible(stepsType,DIFFICULTY_EASY)+
      PROFILEMAN:GetMachineProfile():GetSongsPossible(stepsType,DIFFICULTY_MEDIUM)+
      PROFILEMAN:GetMachineProfile():GetSongsPossible(stepsType,DIFFICULTY_HARD)+
      PROFILEMAN:GetMachineProfile():GetSongsPossible(stepsType,DIFFICULTY_CHALLENGE)+
      PROFILEMAN:GetMachineProfile():GetCoursesPossible(stepsType,COURSE_DIFFICULTY_REGULAR)+
      PROFILEMAN:GetMachineProfile():GetCoursesPossible(stepsType,COURSE_DIFFICULTY_DIFFICULT)
end

function GetTotalPercentComplete( stepsType )
   return GetActual(stepsType) / (0.96*GetPossible(stepsType))
end

function GetSongsPercentComplete( stepsType, difficulty )
   return PROFILEMAN:GetMachineProfile():GetSongsPercentComplete(stepsType,difficulty)/0.96
end

function GetCoursesPercentComplete( stepsType, difficulty )
   return PROFILEMAN:GetMachineProfile():GetCoursesPercentComplete(stepsType,difficulty)/0.96
end

function GetExtraCredit( stepsType )
   return GetActual(stepsType) - (0.96*GetPossible(stepsType))
end

function GetMaxPercentCompelte( stepsType )
   return 1/0.96;
end

-- This is overridden in the PS2 theme to set the options difficulty.
function GetInitialDifficulty()
   return "beginner"
end

function DifficultyChangingIsAvailable()
   return GAMESTATE:GetPlayMode() ~= PLAY_MODE_ENDLESS and GAMESTATE:GetPlayMode() ~= PLAY_MODE_ONI and GAMESTATE:GetSortOrder() ~= SORT_MODE_MENU
end

function ModeMenuAvailable()
   if GAMESTATE:IsCourseMode() then return false end
   --Trace( "here1" )
   if GAMESTATE:GetSortOrder() == SORT_MODE_MENU then return false end
   --Trace( "here2" )
   return true
end

function GetEditStepsText()

   local steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
   if steps == nil then
      return ""
   elseif steps:GetDifficulty() == DIFFICULTY_EDIT then
      return steps:GetDescription()
   else
      return DifficultyToThemedString(steps:GetDifficulty())
   end
end

function GetScreenSelectStyleDefaultChoice()
   if GAMESTATE:GetNumPlayersEnabled() == 1 then return "1" else return "2" end
end

-- Wag for ScreenSelectPlayMode scroll choice3.  This should use
-- EffectMagnitude, and not a hardcoded "5".
function TweenedWag(self)
   local time = self:GetSecsIntoEffect()
   local percent = time / 4
   local rx, ry, rz
   rx,ry,rz = self:getrotation()
   rz = rz + 5 * math.sin( percent * 2 * 3.141 ) * self:getaux()
   self:rotationz( rz )
end

-- For DifficultyMeterSurvival:
function SetColorFromMeterString( self )
   local meter = self:GetText()
   if meter == "?"  then return end

   local i = (meter+0);
   local cmd;
   if i <= 1 then cmd = "Beginner"
   elseif i <= 3 then cmd = "Easy"
   elseif i <= 6 then cmd = "Regular"
   elseif i <= 9 then cmd = "Difficult"
   else cmd = "Challenge"
   end

   self:playcommand( "Set" .. cmd .. "Course" )
end

function GetPaneX( player )
   if GAMESTATE:PlayerUsingBothSides() then
      return SCREEN_CENTER_X
   end

   if player == PLAYER_1 then
      return SCREEN_CENTER_X-152
   else
      return SCREEN_CENTER_X+152
   end
end

function StepArtistX( player )
   if GAMESTATE:PlayerUsingBothSides() then
      return "horizalign,center;x,SCREEN_CENTER_X-109;y,SCREEN_BOTTOM-140"
   end

   if player == PLAYER_1 then
      return "horizalign,center;x,SCREEN_LEFT+57;y,SCREEN_BOTTOM-140"
   else
      return "horizalign,center;x,SCREEN_RIGHT-275;y,SCREEN_BOTTOM-140"
   end
end

function EvalX()
   if not GAMESTATE:PlayerUsingBothSides() then return 0 end

   local Offset = 147
   if GAMESTATE:GetMasterPlayerNumber() == PLAYER_2 then Offset = Offset * -1 end
   return Offset;
end

function EvalTweenDistance()
   local Distance = SCREEN_WIDTH/2
   if GAMESTATE:PlayerUsingBothSides() then Distance = Distance * 2 end
   return Distance
end

-- used by BGA/ScreenEvaluation overlay
-- XXX: don't lowercase commands on parse
function ActorFrame:difficultyoffset()
   if not GAMESTATE:PlayerUsingBothSides() then return end

   local XOffset = 14
   if GAMESTATE:GetMasterPlayerNumber() == PLAYER_2 then XOffset = XOffset * -1 end
   self:addx( XOffset )
   self:addy( -35 )
end

function GameState:PlayerDifficulty( pn )
   if GAMESTATE:IsCourseMode() then
      local trail = GAMESTATE:GetCurrentTrail(pn)
      return trail:GetDifficulty()
   else
      local steps = GAMESTATE:GetCurrentSteps(pn)
      return steps:GetDifficulty()
   end
end


function CourseDifficulty( pn )

local trail = GAMESTATE:GetCurrentTrail(pn)
      
if trail:GetDifficulty() == 1 then
return "Normal?"

elseif trail:GetDifficulty() == 2 then
return "Normal"

elseif trail:GetDifficulty() == 3 then
return "Intense"

elseif trail:GetDifficulty() == 4 then
return "Intense?"

else
return trail:GetDifficulty()

end
end

function Get2PlayerJoinMessage()
   if not GAMESTATE:PlayersCanJoin() then return "" end
   if GAMESTATE:GetCoinMode()==COIN_MODE_FREE then return "2 Player Mode Available" end

   local numSidesNotJoined = NUM_PLAYERS - GAMESTATE:GetNumSidesJoined()
   if GAMESTATE:GetPremium() == PREMIUM_JOINT then numSidesNotJoined = numSidesNotJoined - 1 end
   local coinsRequiredToJoinRest = numSidesNotJoined * PREFSMAN:GetPreference("CoinsPerCredit")
   local remaining = coinsRequiredToJoinRest - GAMESTATE:GetCoins();

   if remaining <= 0 then return "2 Player Mode Available" end

   local s = "For 2 Players, insert " .. remaining .. " more coin"
   if remaining > 1 then s = s.."s" end
   return s
end

function GetRandomSongNames( num )
   local s = "";
   for i = 1,num do
      local song = SONGMAN:GetRandomSong();
      if song then s = s .. song:GetDisplayFullTitle() .. "\n" end
   end
   return s
end

function GetStepChartFacts()
   local s = "";
   s = s .. "In The Groove:\n"
   s = s .. "  71 Single Easy\n"
   s = s .. "  71 Single Medium\n"
   s = s .. "  71 Single Hard\n"
   s = s .. "  52 Single Expert\n"
   s = s .. "  71 Double Easy\n"
   s = s .. "  71 Double Medium\n"
   s = s .. "  71 Double Hard\n"
   s = s .. "  59 Double Expert\n"
   s = s .. "In The Groove 2:\n"
   s = s .. "  61 Single Novice\n"
   s = s .. "  61 Single Easy\n"
   s = s .. "  61 Single Medium\n"
   s = s .. "  61 Single Hard\n"
   s = s .. "  49 Single Expert\n"
   s = s .. "  61 Double Easy\n"
   s = s .. "  61 Double Medium\n"
   s = s .. "  61 Double Hard\n"
   s = s .. "  52 Double Expert"
   return s
end

function GetRandomCourseNames( num )
   local s = "";
   for i = 1,num do
      local course = SONGMAN:GetRandomCourse();
      if course then s = s .. course:GetDisplayFullTitle() .. "\n" end
   end
   return s
end

function GetModifierNames( num )
   local mods = {
      "x1","x1.5","x2","x2.5","x3","3.5","x4","4.5","x5","x6","x8","c450",
      "Incoming","Overhead","Space","Hallway","Distant",
      "Standard","Reverse","Split","Alternate","Cross","Centered",
      "Accel","Decel","Wave","Expand","Boomerang","Bumpy",
      "Dizzy","Drift","Mini","Flip","Invert","Tornado","Float","Beat",
      "Fade&nbsp;In","Fade&nbsp;Out","Blink","Invisible","Beat","Bumpy",
      "Mirror","Left","Right","Random","Blender",
      "No&nbsp;Jumps","No&nbsp;Holds","No&nbsp;Rolls","No&nbsp;Hands","No&nbsp;Quads","No&nbsp;Mines",
      "Simple","Stream","Wide","Quick","Skippy","Echo","Stomp",
      "Planted","Floored","Twister","Add&nbsp;Mines","No&nbsp;Stretch&nbsp;Jumps","Add&nbsp;Rolls",
      "Hide&nbsp;Targets","Hide&nbsp;Judgment","Hide&nbsp;Background",
      "Roll","Twirl",
      "Metal","Cel","Flat","Robot","Vivid","MGD","Trip","Edge","DDR","Vintage","Retro","Shadow"
   }
   mods = tableshuffle( mods )
   local s = "";
   for i = 1,math.min(num,table.getn(mods)) do
      s = s .. mods[i] .. "\n"
   end
   return s
end

function OkX()
	if not GAMESTATE:PlayerUsingBothSides() then return 0 end

	local Offset = 200
	if GAMESTATE:GetMasterPlayerNumber() == PLAYER_2 then Offset = Offset * -1 end
	return Offset;
end


function GetStepsDescriptionTextP1()
	local steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
	if steps == nil then
		return "Unknown"
	elseif steps:GetDifficulty() == DIFFICULTY_EDIT then
		if steps:GetDescription() == "" then
		return "Unknown"
		end
		return steps:GetDescription()
	else
		if steps:GetDescription() == "" then
		return "Unknown"
		end
		return steps:GetDescription()
	end
end


function GetStepsDescriptionTextP2()
	local steps = GAMESTATE:GetCurrentSteps(PLAYER_2)
	if steps == nil then
		return "Unknown"
	elseif steps:GetDifficulty() == DIFFICULTY_EDIT then
		if steps:GetDescription() == "" then
		return "Unknown"
		end
		return steps:GetDescription()
	else
		if steps:GetDescription() == "" then
		return "Unknown"
		end
		return steps:GetDescription()
	end
end


function GetSongTitle()
	local song = GAMESTATE:GetCurrentSong()
	if not song then return "" end

	return
		song:GetDisplayFullTitle()
end


function GetSongArtist()
	local song = GAMESTATE:GetCurrentSong()
	if not song then return "" end

	return
		song:GetDisplayArtist()
end


function GetCourseTitle()
	local course = GAMESTATE:GetCurrentCourse()
	if not course then return "" end

	return
		course:GetDisplayFullTitle()
end

function SHUTUPSERIOUSLY()
	SOUND:DimMusic(0, 6)
end

function LifeDifficultylevel1()
	local val = PREFSMAN:GetPreference( "LifeDifficultyScale" )
	if val <= 1.7 then return true end
	return false 
end

function LifeDifficultylevel2()
	local val = PREFSMAN:GetPreference( "LifeDifficultyScale" )
	if val <= 1.5 then return true end
	return false 
end

function LifeDifficultylevel3()
	local val = PREFSMAN:GetPreference( "LifeDifficultyScale" )
	if val <= 1.3 then return true end
	return false 
end

function LifeDifficultylevel4()
	local val = PREFSMAN:GetPreference( "LifeDifficultyScale" )
	if val <= 1 then return true end
	return false 
end

function LifeDifficultylevel5()
	local val = PREFSMAN:GetPreference( "LifeDifficultyScale" )
	if val <= 0.9 then return true end
	return false 
end

function LifeDifficultylevel6()
	local val = PREFSMAN:GetPreference( "LifeDifficultyScale" )
	if val <= 0.7 then return true end
	return false 
end

function LifeDifficultylevel7()
	local val = PREFSMAN:GetPreference( "LifeDifficultyScale" )
	if val <= 0.5 then return true end
	return false 
end


function JudgeDifficultylevel1()
	local val = PREFSMAN:GetPreference( "JudgeWindowScale" )
	if val <= 1.7 and val >0.3 then return true end
	return false 
end

function JudgeDifficultylevel2()
	local val = PREFSMAN:GetPreference( "JudgeWindowScale" )
	if val <= 1.5 and val > 0.3 then return true end
	return false 
end

function JudgeDifficultylevel3()
	local val = PREFSMAN:GetPreference( "JudgeWindowScale" )
	if val <= 1.3 and val > 0.3 then return true end
	return false 
end

function JudgeDifficultylevel4()
	local val = PREFSMAN:GetPreference( "JudgeWindowScale" )
	if val <= 1 and val > 0.3 then return true end
	return false 
end

function JudgeDifficultylevel5()
	local val = PREFSMAN:GetPreference( "JudgeWindowScale" )
	if val <= 0.9 and val > 0.3 then return true end
	return false 
end

function JudgeDifficultylevel6()
	local val = PREFSMAN:GetPreference( "JudgeWindowScale" )
	if val <= 0.7 and val > 0.3 then return true end
	return false 
end

function JudgeDifficultylevel7()
	local val = PREFSMAN:GetPreference( "JudgeWindowScale" )
	if val <= 0.5 and val > 0.3 then return true end
	return false 
end

function JudgeDifficultylevel8()
	local val = PREFSMAN:GetPreference( "JudgeWindowScale" )
	if val <= 0.4 and val > 0.3 then return true end
	return false 
end

function JudgeDifficultylevelJustice()
	local val = PREFSMAN:GetPreference( "JudgeWindowScale" )
	if val <= 0.3 then return true end
	return false 
end

function TimerException()

if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
local hackzor1 = GAMESTATE:GetPlayerDisplayName(PLAYER_1) 
if hackzor1 == "DarkLink" then return "-1" end
end

if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
local hackzor2 = GAMESTATE:GetPlayerDisplayName(PLAYER_2)
if hackzor2 == "DarkLink" then return "-1" end
end

--NOTE: This is the Menu Timer Seconds. Adjust this to change the Time in ScreenSelectMuisc.
return "100"
end

-- I'll Mess With this Code Later. Ignore for now.
function CreditCode()

return "lua,function() MESSAGEMAN:Broadcast('CreditCodeEntered') end;sound,ScreenTitleMenu n00b"
end

function P1Stepartist( actor )
	local song = GAMESTATE:GetCurrentSong();
	local course = GAMESTATE:GetCurrentCourse();
	local artist = GetStepsDescriptionTextP1();
	local result = ""

	if song then
		if artist == "" then
			result = "Stepartist: Unknown"
		elseif artist == "Blank" then
			result = "Stepartist: Unknown"
		elseif artist == "blank" then
			result = "Stepartist: Unknown"
		else
			result = "Stepartist: " .. artist
		end
	else
	result = "In The Groove 2 Shadow"
	
	end
	
	if course then
		result = "In The Groove 2 Shadow"
	end
	if string.find(artist, "Foy") then
			actor:diffuseshift();
			actor:effectclock("bgm");
			actor:effectcolor1(1,1,1,1);
			actor:effectcolor2(1,.5,.5,1);
	elseif string.find(artist, "G. Marchan") or string.find(artist, "DarkLink") then
			actor:diffuseshift();
			actor:effectclock("bgm");
			actor:effectcolor1(1,1,1,1);
			actor:effectcolor2(0,0,0,0.5);
	else
	actor:stopeffect()
	end
	
	actor:settext( result )
end


function P2Stepartist( actor )
	local song = GAMESTATE:GetCurrentSong();
	local course = GAMESTATE:GetCurrentCourse();
	local artist = GetStepsDescriptionTextP2();
	local result = ""
	if song then
	actor:hidden(0)
		if artist == "" then
			result = "Stepartist: Unknown"
		elseif artist == "Blank" then
			result = "Stepartist: Unknown"
		elseif artist == "blank" then
			result = "Stepartist: Unknown"
		else
			result = "Stepartist: " .. artist
		end
		
	else
	result = "In The Groove 2 Shadow"

	end

	if course then
		result = "In The Groove 2 Shadow"
	end
	if string.find(artist, "Foy") then
			actor:diffuseshift();
			actor:effectclock("bgm");
			actor:effectcolor1(1,1,1,1);
			actor:effectcolor2(1,.5,.5,1);
	elseif string.find(artist, "G. Marchan") or string.find(artist, "DarkLink") then
			actor:diffuseshift();
			actor:effectclock("bgm");
			actor:effectcolor1(1,1,1,1);
			actor:effectcolor2(0,0,0,0.5);
	else
	actor:stopeffect()
	end
	
	actor:settext( result )
end

--Red, Green, Blue, Black?
--Smaller = Darker
--Bigger = Lighter

function SpecialSong( actor )
local song = GAMESTATE:GetCurrentSong();
local course = GAMESTATE:GetCurrentCourse();
	if not song then	
	actor:diffuse(0.8,1,0.8,0.5)
	end

	if song then
	actor:diffuse(0.8,1,0.8,0.5)

   if OpenITG then
      if song:IsCustomSong() then
      actor:diffuse(0.85,0.85,0.85,0.85)
      end
   end

   if OpenITG then
      if song:IsLong() then
      actor:diffuse(0,0.7,1,0.8)
      end
   end

	if OpenITG then
      if song:IsMarathon() then
	   actor:diffuse(1,0.25,0.25,1)
	   end
   end

	end

end

function CustomSong( actor )
local song = GAMESTATE:GetCurrentSong();
	if not song then	
	actor:hidden(1)
	end

	if song then
	actor:hidden(1)

   if OpenITG then
	   if song:IsCustomSong() then
	   actor:hidden(0)
	   end
   end

	end
end

--Removes the "Unison" Option if you're playing on Doubles since it's Completely useless.
function Doubles()
   if OPENITG then
	   if GAMESTATE:PlayerUsingBothSides() then
      return "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,20,21,22,23"
      end
	return "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,20,21,22,23"
   end
   if GAMESTATE:PlayerUsingBothSides() then
      return "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,20,21,22,23"
      end
   return "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,20,21,22,23"
end
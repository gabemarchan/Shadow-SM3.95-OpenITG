function QuadAward( pn )
	return PROFILEMAN:GetProfile(pn):GetTotalStepsWithTopGrade(STEPS_TYPE_DANCE_SINGLE,DIFFICULTY_CHALLENGE,GRADE_TIER01)
	      +PROFILEMAN:GetProfile(pn):GetTotalStepsWithTopGrade(STEPS_TYPE_DANCE_DOUBLE,DIFFICULTY_CHALLENGE,GRADE_TIER01)
end
function StarAward( pn )
	return PROFILEMAN:GetProfile(pn):GetTotalStepsWithTopGrade(STEPS_TYPE_DANCE_SINGLE,DIFFICULTY_CHALLENGE,GRADE_TIER01)*4
				+PROFILEMAN:GetProfile(pn):GetTotalStepsWithTopGrade(STEPS_TYPE_DANCE_SINGLE,DIFFICULTY_CHALLENGE,GRADE_TIER02)*3
				+PROFILEMAN:GetProfile(pn):GetTotalStepsWithTopGrade(STEPS_TYPE_DANCE_SINGLE,DIFFICULTY_CHALLENGE,GRADE_TIER03)*2
				+PROFILEMAN:GetProfile(pn):GetTotalStepsWithTopGrade(STEPS_TYPE_DANCE_SINGLE,DIFFICULTY_CHALLENGE,GRADE_TIER04)
				+PROFILEMAN:GetProfile(pn):GetTotalStepsWithTopGrade(STEPS_TYPE_DANCE_DOUBLE,DIFFICULTY_CHALLENGE,GRADE_TIER01)*4
				+PROFILEMAN:GetProfile(pn):GetTotalStepsWithTopGrade(STEPS_TYPE_DANCE_DOUBLE,DIFFICULTY_CHALLENGE,GRADE_TIER02)*3
				+PROFILEMAN:GetProfile(pn):GetTotalStepsWithTopGrade(STEPS_TYPE_DANCE_DOUBLE,DIFFICULTY_CHALLENGE,GRADE_TIER03)*2
				+PROFILEMAN:GetProfile(pn):GetTotalStepsWithTopGrade(STEPS_TYPE_DANCE_DOUBLE,DIFFICULTY_CHALLENGE,GRADE_TIER04)
end


function CalorieAward( pn )
	return PROFILEMAN:GetProfile(pn):GetCaloriesBurnedToday()
end


function PercentAward( pn )

	return ((PROFILEMAN:GetProfile(pn):GetSongsActual(STEPS_TYPE_DANCE_SINGLE,DIFFICULTY_CHALLENGE))*100)
	      +((PROFILEMAN:GetProfile(pn):GetSongsActual(STEPS_TYPE_DANCE_DOUBLE,DIFFICULTY_CHALLENGE))*100)
end


function StarIcon( Actor,pn )
local stars = StarAward( pn ); 
Trace("stars: " .. stars);
        if stars < 10 then Actor:hidden(1) end 
        if stars >= 10 then Actor:setstate(4) end 
        if stars >= 25 then Actor:setstate(5) end 
        if stars >= 50 then Actor:setstate(6) end 
        if stars >= 100 then Actor:setstate(7) end 
end


function QuadIcon( Actor,pn ) 
local quads = QuadAward( pn ); 
Trace("quads: " .. quads);
        if quads < 1 then Actor:hidden(1) end 
        if quads >= 1 then Actor:setstate(8) end 
        if quads >= 5 then Actor:setstate(9) end 
        if quads >= 10 then Actor:setstate(10) end 
        if quads >= 25 then Actor:setstate(11) end 
end


function PercentIcon( Actor,pn ) 
local perc = PercentAward( pn ); 
Trace("perc: " .. perc);
        if perc < 500 then Actor:hidden(1) end 
        if perc >= 500 then Actor:setstate(0) end 
        if perc >= 2500 then Actor:setstate(1) end 
        if perc >= 7500 then Actor:setstate(2) end 
        if perc >= 15000 then Actor:setstate(3) end 
end


function CalorieIcon( Actor,pn ) 
local cals = CalorieAward( pn ); 
Trace("cals: " .. cals);
        if cals < 250 then Actor:hidden(1) end 
        if cals >= 250 then Actor:setstate(12) end 
        if cals >= 750 then Actor:setstate(13) end 
        if cals >= 1500 then Actor:setstate(14) end 
        if cals >= 3000 then Actor:setstate(15) end 
end
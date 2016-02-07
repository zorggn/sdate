local ddate = {
	_VERSION     = 'lua ddate implementation v1.0.0',
	_DESCRIPTION = 'An implementation of the discordian calendar.',
	_URL         = 'http://github.com/zorggn/ddate',
	_LICENSE     = 'ISC LICENSE\n\n' ..
		           'Copyright (c) 2016-2016, zorg <zorg@atw.hu>\n\n' ..
		           'Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.\n\n' ..
		           'THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS.\n' ..
		           'IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.\n'
	}

-- Constants

	local sDayName      = {"SM","BT","PD","PP","SO"}
	local lDayName      = {"Sweetmorn","Boomtime","Pungenday","Prickle-Prickle","Setting Orange"}
	local sSpecDayName  = {"ST","UH"}
	local lSpecDayName  = {"St. Tib's Day","The Unknown Holyday"}
	local sAHolyDayName = {"MG","MJ","SY","ZR","ML"}
	local lAHolyDayName = {"Mungday","Mojoday","Syaday","Zaraday","Maladay"}
	local sSHolyDayName = {"CH","DI","CO","BU","AF"}
	local lSHolyDayName = {"Chaoflux","Discoflux","Confuflux","Bureflux","Afflux"}
	local sSeasonName   = {"Cha.","Dsc.","Cfn.","Bcy","Afm."}
	local lSeasonName   = {"Chaos","Discord","Confusion","Bureaucracy","The Aftermath"}
	local yearPostfix   = "YOLD"

-- Functions

	local ordDay = function(t)
		local d = t.o.day
		if t.i.month == 2 and t.i.day > 28 then return '' end
		if     (math.floor(d/10) ~= 1) and (d%10 == 1) then return 'st '
		elseif (math.floor(d/10) ~= 1) and (d%10 == 2) then return 'nd '
		elseif (math.floor(d/10) ~= 1) and (d%10 == 3) then return 'rd '
		else return 'th '
		end
	end

	local day = function(t)  if t.i.month == 2 and t.i.day > 28 then return '' else return t.o.day end end
	local wDay = function(t) if t.i.month == 2 and t.i.day > 28 then return '' else return t.o.wday end end
	local yDay = function(t) if t.i.month == 2 and t.i.day > 28 then return '' else return t.o.yday end end
	local sDay = function(t) if t.i.month == 2 and t.i.day > 28 then return '' else return sDayName[t.o.wday] end end
	local lDay = function(t) if t.i.month == 2 and t.i.day > 28 then return '' else return lDayName[t.o.wday] end end
	local sDayEx = function(t)
		if     t.o.day   ==  5                   then return sAHolyDayName[t.o.month]
		elseif t.o.day   == 50                   then return sSHolyDayName[t.o.month]
		elseif t.i.month ==  2 and t.i.day == 29 then return sSpecDayName[1]
		elseif t.i.month ==  2 and t.i.day >= 30 then return sSpecDayName[2]
		else                                          return sDayName[t.o.wday]
		end
	end
	local lDayEx = function(t)
		if     t.o.day   ==  5                   then return lAHolyDayName[t.o.month]
		elseif t.o.day   == 50                   then return lSHolyDayName[t.o.month]
		elseif t.i.month ==  2 and t.i.day == 29 then return lSpecDayName[1]
		elseif t.i.month ==  2 and t.i.day >= 30 then return lSpecDayName[2]
		else                                          return lDayName[t.o.wday]
		end
	end

	local season = function(t) return t.o.month end
	local sSeason = function(t)
		if t.i.month == 2 and t.i.day == 29 then return ''
		else return sSeasonName[t.o.month]
		end
	end
	local lSeason = function(t)
		if t.i.month == 2 and t.i.day == 29 then return ''
		else return lSeasonName[t.o.month]
		end
	end

	local sYear = function(t) return t.o.year % 100 end
	local lYear = function(t) return t.o.year       end

	local parse; parse = function(formatString, t)
		-- The e, E, W and C specifiers may not be present in os.date's implementation.
		return (formatString:gsub("(%%[aAbBcCdeEHImMpSwWxXyY%%])",
			function(specifier)
				if     specifier == "%%" then return "%"
				elseif specifier == "%d" then return day(t)
				elseif specifier == "%w" then return wDay(t)
				elseif specifier == "%W" then return yDay(t)
				elseif specifier == "%a" then return sDay(t)
				elseif specifier == "%A" then return lDay(t)
				elseif specifier == "%e" then return sDayEx(t)
				elseif specifier == "%E" then return lDayEx(t)

				elseif specifier == "%m" then return season(t)
				elseif specifier == "%b" then return sSeason(t)
				elseif specifier == "%B" then return lSeason(t)

				elseif specifier == "%y" then return sYear(t)
				elseif specifier == "%Y" then return lYear(t)

				elseif specifier == "%H" then return t.o.hour
				elseif specifier == "%I" then return (t.o.hour >= 12 and (t.o.hour + 1) - 12 or (t.o.hour + 1))
				elseif specifier == "%p" then return (t.o.hour >= 12 and "PM" or "AM")

				elseif specifier == "%M" then return t.o.min

				elseif specifier == "%S" then return t.o.sec
		
				elseif specifier == "%C" then return parse(("%%E, %%d%sof %%B %s %%Y"):format(ordDay(t), yearPostfix), t)

				elseif specifier == "%c" then return parse("%x %X", t)    -- Date and Time (supposed to be locale specific)
				elseif specifier == "%x" then return parse("%m/%d/%y", t) -- Date (supposed to be locale specific)
				elseif specifier == "%X" then return parse("%H:%M:%S", t) -- Time (supposed to be locale specific)

				else return specifier
				end
			end
		))
	end

-- Methods

ddate.date = function(formatString, time)
	-- Analogous to os.date, uses the same signature (param. list) and timestamp format, but a different specifier set.
	-- Note that the specifiers can be remapped.

	-- Default values
	formatString = formatString or "%c"
	time         = time         or os.time()

	-- Input type guards
	assert(type(formatString) == 'string')
	assert(type(time)         == 'number')

	-- Calculate date from standard calendar.
	local t = {}

	-- Input fields (Gregorian)
	t.i = os.date("*t", time)

	-- Output fields (Discordian)
	t.o = {}

	-- Unchanged
	t.o.sec   = t.i.sec
	t.o.min   = t.i.min
	t.o.hour  = t.i.hour
	t.o.isdst = t.i.isdst

	-- Changed

	-- Check for leap years, since the extra day is not part of any season,
	-- hence if we don't code it like so, we'll have an off-by-one error those years.
	local leap = (((t.i.year % 4 == 0) and (t.i.year % 100 ~= 0)) or (t.i.year % 400 == 0 )) and true or false

	t.o.yday = (leap and t.i.yday > 59) and t.i.yday - 1 or t.i.yday

	t.o.year  = t.i.year + 1166
	t.o.month = math.floor(t.o.yday / 73) + 1 -- "season"
	t.o.week  = math.floor(t.o.yday /  5) + 1
	t.o.day   = math.floor((t.o.yday - 1) % 73) + 1 -- day of the "season"
	t.o.wday  = math.floor((t.o.yday - 1) %  5) + 1 -- day of the week

	-- Return a date table if "*t" is the format string.
	if formatString == '*t' then return t.o end

	-- Otherwise, parse the format string, and substitute stuff along it, recursively if needed.
	return parse(formatString, t)
end

------------
return ddate
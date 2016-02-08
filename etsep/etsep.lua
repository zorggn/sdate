local sdate = {
	_VERSION     = 'lua sdate implementation v1.0.0',
	_DESCRIPTION = 'An implementation of the 1993 eternal september calendar.',
	_URL         = 'http://github.com/zorggn/sdate',
	_LICENSE     = 'ISC LICENSE\n\n' ..
		           'Copyright (c) 2016-2016, zorg <zorg@atw.hu>\n\n' ..
		           'Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.\n\n' ..
		           'THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS.\n' ..
		           'IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.\n'
	}

-- Notes:
-- - Yes, one would do this by getting a time value, converting it into local time, modify it,
--   and call strftime with the formatstring and new time struct. Since the latter was not available,
--   some improvisation was needed, and also some limitations exist because of that.
-- - And yes, this could be combined with a localization library or something.

-- Constants

	local sDayName   = {"Mon","Tue","Wed","Thu","Fri","Sat","Sun"}
	local lDayName   = {"Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"}
	local sMonthName = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
	local lMonthName = {"January","February","March","April","May","June","July","August","September","October","November","December"}

-- Functions

	local ordDay = function(t)
		local d = t.o.day % 100
		if     (math.floor(d/10) ~= 1) and (d%10 == 1) then return 'st '
		elseif (math.floor(d/10) ~= 1) and (d%10 == 2) then return 'nd '
		elseif (math.floor(d/10) ~= 1) and (d%10 == 3) then return 'rd '
		else return 'th '
		end
	end

	local day = function(t)  return t.o.day end
	local wDay = function(t) return t.o.wday end
	local yDay = function(t) return t.o.yday end
	local sDay = function(t) return sDayName[t.o.wday] end
	local lDay = function(t) return lDayName[t.o.wday] end

	local month = function(t) return t.o.month end
	local sMonth = function(t)
		if t.i.month == 2 and t.i.day == 29 then return ''
		else return sMonthName[t.o.month]
		end
	end
	local lMonth = function(t)
		if t.i.month == 2 and t.i.day == 29 then return ''
		else return lMonthName[t.o.month]
		end
	end

	local sYear = function(t) return t.o.year % 100 end
	local lYear = function(t) return t.o.year end

	local parse; parse = function(formatString, t)
		-- The e, E, W and C specifiers may not be present in os.date's implementation.
		return (formatString:gsub("(%%[aAbBcCdHImMpSwWxXyY%%])",
			function(specifier)
				if     specifier == "%%" then return "%"
				elseif specifier == "%d" then return day(t)
				elseif specifier == "%w" then return wDay(t)
				elseif specifier == "%W" then return yDay(t)
				elseif specifier == "%a" then return sDay(t)
				elseif specifier == "%A" then return lDay(t)

				elseif specifier == "%m" then return month(t)
				elseif specifier == "%b" then return sMonth(t)
				elseif specifier == "%B" then return lMonth(t)

				elseif specifier == "%y" then return sYear(t)
				elseif specifier == "%Y" then return lYear(t)

				elseif specifier == "%H" then return t.o.hour
				elseif specifier == "%I" then return (t.o.hour >= 12 and (t.o.hour + 1) - 12 or (t.o.hour + 1))
				elseif specifier == "%p" then return (t.o.hour >= 12 and "PM" or "AM")

				elseif specifier == "%M" then return t.o.min

				elseif specifier == "%S" then return t.o.sec
		
				elseif specifier == "%C" then return parse(("%%A, %%d%sof %%B %%Y"):format(ordDay(t), yearPostfix), t)

				elseif specifier == "%c" then return parse("%x %X", t)    -- Date and Time (supposed to be locale specific)
				elseif specifier == "%x" then return parse("%m/%d/%y", t) -- Date (supposed to be locale specific)
				elseif specifier == "%X" then return parse("%H:%M:%S", t) -- Time (supposed to be locale specific)

				else return specifier
				end
			end
		))
	end

-- Methods

sdate.date = function(formatString, time)
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
	t.o.wday  = t.i.wday

	-- Changed

	-- Fix the date so it's always the september of 1993, after that month.
	
	if (t.i.year == 1993 and t.i.month == 9) or t.i.year > 1993 then
		local epoch = os.time{year=1993, month=8, day=31}
		t.o.day  = math.floor(os.difftime(time, epoch) / 86400)
		t.o.month = 9
		t.o.year = 1993
		local leap = (((t.i.year % 4 == 0) and (t.i.year % 100 ~= 0)) or (t.i.year % 400 == 0 )) and true or false
		t.o.yday = 31+(leap and 29 or 28)+31+30+31+30+31+31
	end

	-- Return a date table if "*t" is the format string.
	if formatString == '*t' then return t.o end

	-- Otherwise, parse the format string, and substitute stuff along it, recursively if needed.
	return parse(formatString, t)
end

------------
return sdate
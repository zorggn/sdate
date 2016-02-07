# ddate

A lua ddate implementation.

### Usage

```lua
ddate.date(formatString, time)
```

### Supported specifiers

* `%a` Short weekday name
* `%A` Long weekday name
* `%b` Short season name
* `%B` Long season name
* `%c` Default date and time format
* `%C` More appropriate date and time format :3
* `%d` The day of the season
* `%e` Like `%a`, but it gives back holyday names on the 5th and 50th days
* `%E` Like `%A`, but it gives back holyday names on the 5th and 50th days
* `%H` Hours, 0-23
* `%I` Hours, 1-12
* `%m` The season of the year
* `%M` Minutes
* `%p` AM or PM
* `%S` Seconds
* `%w` The day of the week
* `%W` The day of the year
* `%x` Default date format
* `%X` Default time format
* `%y` Short year
* `%Y` Long year
* `%%` Literal "%" Escape

### Features

* 200x slower than os.date!
* Supports the 30th of february!

### Features missing

* The `%c`, `%x` and `%X` flags are not locale-specific.
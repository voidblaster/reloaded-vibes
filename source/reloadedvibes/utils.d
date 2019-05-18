/+
    This file is part of Reloaded Vibes.
    Copyright (c) 2019  0xEAB

    Distributed under the Boost Software License, Version 1.0.
       (See accompanying file LICENSE_1_0.txt or copy at
             https://www.boost.org/LICENSE_1_0.txt)
 +/
module reloadedvibes.utils;

import std.algorithm : canFind;
import std.ascii : isDigit;
import std.conv : to;
import std.string : indexOf, isNumeric;

@safe pure:

struct Socket
{
	string address;
	ushort port;

	string toString() const @safe pure nothrow
	{
		// dfmt off
		return (this.address.isIPv6)
			? '[' ~ this.address ~ "]:" ~ this.port.to!string
			: this.address ~ ':' ~ this.port.to!string;
		// dfmt on
	}
}

bool isIPv6(string address) nothrow @nogc
{
	foreach (c; address)
	{
		if (c == ':')
		{
			return true;
		}
	}

	return false;
}

bool tryParseSocket(string s, out Socket socket)
{
	socket = Socket();

	if ((s is null) && (s.length == 0))
	{
		return false;
	}

	immutable possiblePortSep = s.indexOf(':');

	size_t isIPv6 = 0;

	if (s[0] == '[')
	{
		// IPv6

		immutable ipv6end = s.indexOf(']');
		if (ipv6end < 3)
		{
			return false;
		}

		socket.address = s[1 .. ipv6end];

		isIPv6 = s.indexOf(':', ipv6end);
	}
	else if (possiblePortSep > -1)
	{
		// IPv4
		socket.address = s[0 .. possiblePortSep];
	}
	else
	{
		return false;
	}

	immutable portSep = (isIPv6) ? isIPv6 : possiblePortSep;
	string port = s[(portSep + 1) .. $];

	if (port.canFind!(d => !d.isDigit)() || (port.length > 5) || (port[0] == '-'))
	{
		return false;
	}

	immutable portInt = port.to!int;
	if (portInt > ushort.max)
	{
		return false;
	}

	socket.port = cast(ushort)(portInt);
	return true;
}

(*
    BuildTimeStampUDFB.st
    ---------------------
    This function block generates a unique timestamp string from the Micro800 PLC's RTC.
    The timestamp format is: YYMMDDSSSSS (YY=year, MM=month, DD=day, SSSSS=seconds since midnight, all zero-padded)
    Example: 2025-06-14 15:28:51 -> '25061455731'
    Calculation: YYMMDD + zero-padded seconds since midnight
    Breakdown: 25 (year), 06 (month), 14 (day), 15*3600 + 28*60 + 51 = 55731 (seconds since midnight)
    Result: '25061455731'

    Requirements:
    - Micro800 PLC with RTC
    - RTCREAD function block available in CCW

    Usage:
    - Enable the function block with FBEN := TRUE
    - Output TimestampStr will contain the unique timestamp string when FBENO is TRUE


FUNCTION_BLOCK BuildTimeStampUDFB
VAR_INPUT
    FBEN : BOOL; // Function Block Enable
END_VAR

VAR_OUTPUT
    FBENO : BOOL; // Function Block Done Output (true when code has completed)
    TimestampStr : STRING[12]; // Output: Unique timestamp string (YYMMDDSSSSS)
END_VAR

VAR
    stRTC : RTC := (Year := 0, Month := 0, Day := 0, Hours := 0, Minutes := 0, Seconds := 0); // RTC structure
    SecondsSinceMidnight : DINT; // Calculated seconds since midnight
    fbRTCRead : RTCREAD; // RTCREAD function block instance for Micro800
    sYear : STRING[3];
    sMonth : STRING[3];
    sDay : STRING[3];
    sSeconds : STRING[6];
END_VAR

    Calculation steps:
    1. Read RTC values
    2. Calculate seconds since midnight
    3. Convert year, month, day, and seconds to zero-padded strings using INSERT and MLEN
    4. Concatenate to form the timestamp string in the order YYMMDDSSSSS
*)

IF FBEN THEN
    // Execute RTCREAD to get current RTC values
    fbRTCRead(TRUE);
    stRTC := fbRTCRead.RTCData;

    // Calculate seconds since midnight
    SecondsSinceMidnight := ANY_TO_DINT(stRTC.Hours) * 3600
                           + ANY_TO_DINT(stRTC.Minutes) * 60
                           + ANY_TO_DINT(stRTC.Seconds);

    // Convert to zero-padded strings using INSERT and MLEN
    sYear := ANY_TO_STRING(ANY_TO_DINT(stRTC.Year) - 2000);
    IF MLEN(sYear) < 2 THEN
        sYear := INSERT('0', sYear, 1);
    END_IF;

    sMonth := ANY_TO_STRING(ANY_TO_DINT(stRTC.Month));
    IF MLEN(sMonth) < 2 THEN
        sMonth := INSERT(sMonth, '0', 1);
    END_IF;

    sDay := ANY_TO_STRING(ANY_TO_DINT(stRTC.Day));
    IF MLEN(sDay) < 2 THEN
        sDay := INSERT(sDay, '0', 1);
    END_IF;

    sSeconds := ANY_TO_STRING(SecondsSinceMidnight);
    CASE MLEN(sSeconds) OF
        1: sSeconds := INSERT(sSeconds, '0000', 1);
        2: sSeconds := INSERT(sSeconds, '000', 1);
        3: sSeconds := INSERT(sSeconds, '00', 1);
        4: sSeconds := INSERT(sSeconds, '0', 1);
    END_CASE;

    // Build unique timestamp string using INSERT at position 1 in reverse order (YYMMDDSSSSS)
    TimestampStr := '';
    TimestampStr := INSERT(sYear, TimestampStr, 1);
    TimestampStr := INSERT(sMonth, TimestampStr, 1);
    TimestampStr := INSERT(sDay, TimestampStr, 1);
    TimestampStr := INSERT(sSeconds, TimestampStr, 1);
    FBENO := TRUE;
ELSE
    FBENO := FALSE;
END_IF;



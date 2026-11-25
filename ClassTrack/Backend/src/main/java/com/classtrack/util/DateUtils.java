package com.classtrack.util;
import java.time.*;
public final class DateUtils { private DateUtils() {} public static LocalDate today() { return LocalDate.now(ZoneOffset.UTC); } public static double percentage(long present,long late,long total) { return total==0?0:Math.round((present+late)*10000.0/total)/100.0; } }

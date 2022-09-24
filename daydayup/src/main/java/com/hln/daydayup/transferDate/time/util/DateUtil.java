/**
 * Copyright (c) 2016 21CN.COM . All rights reserved.<br>
 *
 * Description: calendar<br>
 *
 * Modified log:<br>
 * ------------------------------------------------------<br>
 * Ver.		Date		Author			Description<br>
 * ------------------------------------------------------<br>
 * 1.0		2016��3��8��		kexm		created.<br>
 */
package com.hln.daydayup.transferDate.time.util;

//import org.slf4j.Logger;
//import org.slf4j.LoggerFactory;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

/**
 * <p>
 * �ճ���Ŀ��ʱ�乤���࣬�̳й�˾�Ĺ���ʱ�乤����
 * <p>
 *
 * @author <a href="mailto:kexm@corp.21cn.com">kexm</a>
 * @since 2016��3��8��
 */
public class DateUtil extends CommonDateUtil {
//    private static final Logger LOGGER = LoggerFactory.getLogger(DateUtil.class);

    /**
     * �Ƿ��ǽ���
     *
     * @param date
     * @return
     */
    public static boolean isToday(final Date date) {
        return isTheDay(date, new Date());
    }

    /**
     * �Ƿ���ָ������
     *
     * @param date
     * @param day
     * @return
     */
    public static boolean isTheDay(final Date date, final Date day) {
        return date.getTime() >= dayBegin(day).getTime() && date.getTime() <= dayEnd(day).getTime();
    }

    /**
     * ��ʱ���еķ�������ȡ��
     *
     * @param date
     * @param round ȡ����ֵ
     * @return
     */
    public static Date roundMin(final Date date, int round) {
        if (round > 60 || round < 0) {
            round = 0;
        }
        Calendar c = Calendar.getInstance();
        c.setTime(date);
        int min = c.get(Calendar.MINUTE);
        if ((min % round) >= (round / 2)) {
            min = round * (min / (round + 1));
        } else {
            min = round * (min / round);
        }
        c.set(Calendar.MINUTE, min);
        c.set(Calendar.SECOND, 0);
        return c.getTime();
    }

    /**
     * ���ָ��ʱ�������ĳ��Сʱ��24Сʱ�ƣ�������ʱ��
     *
     * @param date
     * @param hourIn24
     * @return
     */
    public static Date getSpecificHourInTheDay(final Date date, int hourIn24) {
        Calendar c = Calendar.getInstance();
        c.setTime(date);
        c.set(Calendar.HOUR_OF_DAY, hourIn24);
        c.set(Calendar.MINUTE, 0);
        c.set(Calendar.SECOND, 0);
        c.set(Calendar.MILLISECOND, 0);
        return c.getTime();
    }

    /**
     * �õ�������һ
     *
     * @return Date
     */
    public static Date getFirstDayOfWeek(Date date) {
        Calendar c = Calendar.getInstance();
        c.setTime(date);
        int day_of_week = c.get(Calendar.DAY_OF_WEEK) - 1;
        if (day_of_week == 0)
            day_of_week = 7;
        c.add(Calendar.DATE, -day_of_week + 1);
        return c.getTime();
    }

    /**
     * ����������ڵ�������㣨��ǰֻ֧���ܡ��£�
     *
     * @param date
     * @param hourIn24
     * @return
     */
    public static Date getRelativeTime(final Date date, final int calUnit, final int relative) {
        Calendar c = Calendar.getInstance();
        c.setTime(date);
        c.add(calUnit, relative);
        return c.getTime();
    }

    /**
     * ��ȡָ��ʱ������� 00:00:00.000 ��ʱ��
     *
     * @param date
     * @return
     */
    public static Date dayBegin(final Date date) {
        return getSpecificHourInTheDay(date, 0);
    }

    /**
     * ��ȡָ��ʱ������� 23:59:59.999 ��ʱ��
     *
     * @param date
     * @return
     */
    public static Date dayEnd(final Date date) {
        Calendar c = Calendar.getInstance();
        c.setTime(date);
        c.set(Calendar.HOUR_OF_DAY, 23);
        c.set(Calendar.MINUTE, 59);
        c.set(Calendar.SECOND, 59);
        c.set(Calendar.MILLISECOND, 999);
        return c.getTime();
    }

    /**
     * Ĭ��ʱ���ʽ��
     *
     * @param date
     * @param format
     * @return
     */
    public static String formatDateDefault(Date date) {
        return DateUtil.formatDate(date, "yyyy-MM-dd HH:mm:ss");
    }

    /**
     * ������ڸ�ʽ�ַ����Ƿ����format
     * <p>
     * ��Ҫ�߼�Ϊ�Ȱ��ַ���parseΪ��format��Date�����ٽ�Date����formatת��Ϊstring�������string���ʼ�ַ���һ�£������ڷ���format��
     * <p>
     * ֮����������˫���߼�У�飬����Ϊ�����һ���Ƿ��ַ���parseΪĳformat��Date�����ǲ�һ���ᱨ��ġ� ���� 2015-06-29 13:12:121�����Բ�����yyyy-MM-dd
     * HH:mm:ss�����ǿ�������parse��Date���󣬵�ʱ���Ϊ��2015-06-29 13:14:01�����Ӷ�һ��У����ɼ���������⡣
     *
     * @param strDateTime
     * @param format      ���ڸ�ʽ
     * @return boolean
     */
    public static boolean checkDateFormatAndValite(String strDateTime, String format) {
        if (strDateTime == null || strDateTime.length() == 0) {
            return false;
        }
        SimpleDateFormat sdf = new SimpleDateFormat(format);
        try {
            Date ndate = sdf.parse(strDateTime);
            String str = sdf.format(ndate);
//            LOGGER.debug("func<checkDateFormatAndValite> strDateTime<" + strDateTime + "> format<" + format +
//                    "> str<" + str + ">");
            if (str.equals(strDateTime)) {
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    //���ڸ�ʽΪ:�� �� �� ���磺2016��04��06��
    public static final String FORMAT_CALENDAR_DATE = "yyyy\u5E74MM\u6708dd\u65E5E";
    //ʱ���ʽ Ϊ��Сʱ���� ;�磺12:30
    public static final String FORMAT_CALENDAR_TIME = "HH:mm";


    private final static List<Integer> TIMEUNITS = new ArrayList<Integer>();

    static {
        TIMEUNITS.add(Calendar.YEAR);
        TIMEUNITS.add(Calendar.MONTH);
        TIMEUNITS.add(Calendar.DATE);
        TIMEUNITS.add(Calendar.HOUR);
        TIMEUNITS.add(Calendar.MINUTE);
        TIMEUNITS.add(Calendar.SECOND);
    }
}

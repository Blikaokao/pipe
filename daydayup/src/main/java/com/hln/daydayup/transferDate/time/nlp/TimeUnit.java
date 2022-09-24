package com.hln.daydayup.transferDate.time.nlp;

import com.hln.daydayup.transferDate.time.enums.RangeTimeEnum;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * <p>
 * ʱ��������
 * <p>
 *
 * @author <a href="mailto:kexm@corp.21cn.com">kexm</a>
 * @since 2016��5��4��
 */
public class TimeUnit {
	//����Ҫ��ʹ��
	//private static final Logger LOGGER = LoggerFactory.getLogger(TimeUnit.class);
    /**
     * Ŀ���ַ���
     */
    public String Time_Expression = null;
    public String Time_Norm = "";
    public int[] time_full;
    public int[] time_origin;
    private Date time;
    private Boolean isAllDayTime = true;
    private boolean isFirstTimeSolveContext = true;

    TimeNormalizer normalizer = null;
    public TimePoint _tp = new TimePoint();
    public TimePoint _tp_origin = new TimePoint();

    /**
     * ʱ����ʽ��Ԫ���췽��
     * �÷�����Ϊʱ����ʽ��Ԫ����ڣ���ʱ����ʽ�ַ�������
     *
     * @param exp_time ʱ����ʽ�ַ���
     * @param n
     */

    public TimeUnit(String exp_time, TimeNormalizer n) {
        Time_Expression = exp_time;
        normalizer = n;
        Time_Normalization();
    }

    /**
     * ʱ����ʽ��Ԫ���췽��
     * �÷�����Ϊʱ����ʽ��Ԫ����ڣ���ʱ����ʽ�ַ�������
     *
     * @param exp_time  ʱ����ʽ�ַ���
     * @param n
     * @param contextTp ������ʱ��
     */

    public TimeUnit(String exp_time, TimeNormalizer n, TimePoint contextTp) {
        Time_Expression = exp_time;
        normalizer = n;
        _tp_origin = contextTp;
        Time_Normalization();
    }

    /**
     * return the accurate time object
     */
    public Date getTime() {
        return time;
    }

    /**
     * ��-�淶������
     * <p>
     * �÷���ʶ��ʱ����ʽ��Ԫ�����ֶ�
     */
    public void norm_setyear() {
        /**����ֻ����λ������ʾ���*/
        String rule = "[0-9]{2}(?=��)";
        Pattern pattern = Pattern.compile(rule);
        Matcher match = pattern.matcher(Time_Expression);
        if (match.find()) {
            _tp.tunit[0] = Integer.parseInt(match.group());
            if (_tp.tunit[0] >= 0 && _tp.tunit[0] < 100) {
                if (_tp.tunit[0] < 30) /**30���±�ʾ2000���Ժ�����*/
                    _tp.tunit[0] += 2000;
                else/**�����ʾ1900���Ժ�����*/
                    _tp.tunit[0] += 1900;
            }

        }
        /**����������֧��1XXX���2XXX���ʶ�𣬿�ʶ����λ������λ����ʾ�����*/
        rule = "[0-9]?[0-9]{3}(?=��)";

        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find())/**�����3λ����4λ������ݣ��򸲸�ԭ��2λ��ʶ��������*/ {
            _tp.tunit[0] = Integer.parseInt(match.group());
        }
    }

    /**
     * ��-�淶������
     * <p>
     * �÷���ʶ��ʱ����ʽ��Ԫ�����ֶ�
     */
    public void norm_setmonth() {
        String rule = "((10)|(11)|(12)|([1-9]))(?=��)";
        Pattern pattern = Pattern.compile(rule);
        Matcher match = pattern.matcher(Time_Expression);
        if (match.find()) {
            _tp.tunit[1] = Integer.parseInt(match.group());

            /**����������δ��ʱ������  @author kexm*/
            preferFuture(1);
        }
    }

    /**
     * ��-�� ����ģ��д��
     * <p>
     * �÷���ʶ��ʱ����ʽ��Ԫ���¡����ֶ�
     * <p>
     * add by kexm
     */
    public void norm_setmonth_fuzzyday() {
        String rule = "((10)|(11)|(12)|([1-9]))(��|\\.|\\-)([0-3][0-9]|[1-9])";
        Pattern pattern = Pattern.compile(rule);
        Matcher match = pattern.matcher(Time_Expression);
        if (match.find()) {
            String matchStr = match.group();
            Pattern p = Pattern.compile("(��|\\.|\\-)");
            Matcher m = p.matcher(matchStr);
            if (m.find()) {
                int splitIndex = m.start();
                String month = matchStr.substring(0, splitIndex);
                String date = matchStr.substring(splitIndex + 1);

                _tp.tunit[1] = Integer.parseInt(month);
                _tp.tunit[2] = Integer.parseInt(date);

                /**����������δ��ʱ������  @author kexm*/
                preferFuture(1);
            }
        }
    }

    /**
     * ��-�淶������
     * <p>
     * �÷���ʶ��ʱ����ʽ��Ԫ�����ֶ�
     */
    public void norm_setday() {
        String rule = "((?<!\\d))([0-3][0-9]|[1-9])(?=(��|��))";
        Pattern pattern = Pattern.compile(rule);
        Matcher match = pattern.matcher(Time_Expression);
        if (match.find()) {
            _tp.tunit[2] = Integer.parseInt(match.group());

            /**����������δ��ʱ������  @author kexm*/
            preferFuture(2);
        }
    }

    /**
     * ʱ-�淶������
     * <p>
     * �÷���ʶ��ʱ����ʽ��Ԫ��ʱ�ֶ�
     */
    public void norm_sethour() {
        String rule = "(?<!(��|����))([0-2]?[0-9])(?=(��|ʱ))";

        Pattern pattern = Pattern.compile(rule);
        Matcher match = pattern.matcher(Time_Expression);
        if (match.find()) {
            _tp.tunit[3] = Integer.parseInt(match.group());
            /**����������δ��ʱ������  @author kexm*/
            preferFuture(3);
            isAllDayTime = false;
        }
        /*
         * �Թؼ��֣��磨��������/�糿/��䣩�����磬����,���,����,���,����,����,���,��,pm,PM����ȷʱ�����
		 * ��Լ��
		 * 1.����/���0-10����Ϊ12-22��
		 * 2.����/���0-11����Ϊ12-23��
		 * 3.����/����/���/��1-11����Ϊ13-23�㣬12����Ϊ0��
		 * 4.0-11��pm/PM��Ϊ12-23��
		 * 
		 * add by kexm
		 */
        rule = "�賿";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            if (_tp.tunit[3] == -1) /**���Ӷ�û����ȷʱ��㣬ֻд�ˡ��賿����������Ĵ��� @author kexm*/
                _tp.tunit[3] = RangeTimeEnum.day_break.getHourTime();
            /**����������δ��ʱ������  @author kexm*/
            preferFuture(3);
            isAllDayTime = false;
        }

        rule = "����|�糿|���|����|����|����";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            if (_tp.tunit[3] == -1) /**���Ӷ�û����ȷʱ��㣬ֻд�ˡ�����/�糿/��䡱��������Ĵ��� @author kexm*/
                _tp.tunit[3] = RangeTimeEnum.early_morning.getHourTime();
            /**����������δ��ʱ������  @author kexm*/
            preferFuture(3);
            isAllDayTime = false;
        }

        rule = "����";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            if (_tp.tunit[3] == -1) /**���Ӷ�û����ȷʱ��㣬ֻд�ˡ����硱��������Ĵ��� @author kexm*/
                _tp.tunit[3] = RangeTimeEnum.morning.getHourTime();
            /**����������δ��ʱ������  @author kexm*/
            preferFuture(3);
            isAllDayTime = false;
        }

        rule = "(����)|(���)";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            if (_tp.tunit[3] >= 0 && _tp.tunit[3] <= 10)
                _tp.tunit[3] += 12;
            if (_tp.tunit[3] == -1) /**���Ӷ�û����ȷʱ��㣬ֻд�ˡ�����/��䡱��������Ĵ��� @author kexm*/
                _tp.tunit[3] = RangeTimeEnum.noon.getHourTime();
            /**����������δ��ʱ������  @author kexm*/
            preferFuture(3);
            isAllDayTime = false;
        }

        rule = "(����)|(���)|(pm)|(PM)";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            if (_tp.tunit[3] >= 0 && _tp.tunit[3] <= 11)
                _tp.tunit[3] += 12;
            if (_tp.tunit[3] == -1) /**���Ӷ�û����ȷʱ��㣬ֻд�ˡ�����|�����������Ĵ���  @author kexm*/
                _tp.tunit[3] = RangeTimeEnum.afternoon.getHourTime();
            /**����������δ��ʱ������  @author kexm*/
            preferFuture(3);
            isAllDayTime = false;
        }

        rule = "����|ҹ��|ҹ��|����|����";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            if (_tp.tunit[3] >= 1 && _tp.tunit[3] <= 11)
                _tp.tunit[3] += 12;
            else if (_tp.tunit[3] == 12)
                _tp.tunit[3] = 0;
            else if (_tp.tunit[3] == -1)
                _tp.tunit[3] = RangeTimeEnum.night.getHourTime();

            /**����������δ��ʱ������  @author kexm*/
            preferFuture(3);
            isAllDayTime = false;
        }

    }

    /**
     * ��-�淶������
     * <p>
     * �÷���ʶ��ʱ����ʽ��Ԫ�ķ��ֶ�
     */
    public void norm_setminute() {
        String rule = "([0-5]?[0-9](?=��(?!��)))|((?<=((?<!С)[��ʱ]))[0-5]?[0-9](?!��))";

        Pattern pattern = Pattern.compile(rule);
        Matcher match = pattern.matcher(Time_Expression);
        if (match.find()) {
            if (!match.group().equals("")) {
                _tp.tunit[4] = Integer.parseInt(match.group());
                /**����������δ��ʱ������  @author kexm*/
                preferFuture(4);
                isAllDayTime = false;
            }
        }
        /** �Ӷ�һ�̣��룬3�̵���ȷʶ��1��Ϊ15�֣���Ϊ30�֣�3��Ϊ45�֣�*/
        rule = "(?<=[��ʱ])[1һ]��(?!��)";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            _tp.tunit[4] = 15;
            /**����������δ��ʱ������  @author kexm*/
            preferFuture(4);
            isAllDayTime = false;
        }

        rule = "(?<=[��ʱ])��";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            _tp.tunit[4] = 30;
            /**����������δ��ʱ������  @author kexm*/
            preferFuture(4);
            isAllDayTime = false;
        }

        rule = "(?<=[��ʱ])[3��]��(?!��)";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            _tp.tunit[4] = 45;
            /**����������δ��ʱ������  @author kexm*/
            preferFuture(4);
            isAllDayTime = false;
        }
    }

    /**
     * ��-�淶������
     * <p>
     * �÷���ʶ��ʱ����ʽ��Ԫ�����ֶ�
     */
    public void norm_setsecond() {
		/*
		 * �����ʡ�ԡ��֡�˵����ʱ��
		 * ��17��15��32
		 * modified by ����
		 */
        String rule = "([0-5]?[0-9](?=��))|((?<=��)[0-5]?[0-9])";

        Pattern pattern = Pattern.compile(rule);
        Matcher match = pattern.matcher(Time_Expression);
        if (match.find()) {
            _tp.tunit[5] = Integer.parseInt(match.group());
            isAllDayTime = false;
        }
    }

    /**
     * ������ʽ�Ĺ淶������
     * <p>
     * �÷���ʶ��������ʽ��ʱ����ʽ��Ԫ�ĸ����ֶ�
     */
    public void norm_setTotal() {
        String rule;
        Pattern pattern;
        Matcher match;
        String[] tmp_parser;
        String tmp_target;

        rule = "(?<!(��|����))([0-2]?[0-9]):[0-5]?[0-9]:[0-5]?[0-9]";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            tmp_parser = new String[3];
            tmp_target = match.group();
            tmp_parser = tmp_target.split(":");
            _tp.tunit[3] = Integer.parseInt(tmp_parser[0]);
            _tp.tunit[4] = Integer.parseInt(tmp_parser[1]);
            _tp.tunit[5] = Integer.parseInt(tmp_parser[2]);
            /**����������δ��ʱ������  @author kexm*/
            preferFuture(3);
            isAllDayTime = false;
        } else {
            rule = "(?<!(��|����))([0-2]?[0-9]):[0-5]?[0-9]";
            pattern = Pattern.compile(rule);
            match = pattern.matcher(Time_Expression);
            if (match.find()) {
                tmp_parser = new String[2];
                tmp_target = match.group();
                tmp_parser = tmp_target.split(":");
                _tp.tunit[3] = Integer.parseInt(tmp_parser[0]);
                _tp.tunit[4] = Integer.parseInt(tmp_parser[1]);
                /**����������δ��ʱ������  @author kexm*/
                preferFuture(3);
                isAllDayTime = false;
            }
        }
		/*
		 * ������:�̶���ʽʱ����ʽ��
		 * ����,���,����,���,����,����,���,��,pm,PM
		 * ����ȷʱ����㣬��Լͬ��
		 */
        rule = "(����)|(���)";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            if (_tp.tunit[3] >= 0 && _tp.tunit[3] <= 10)
                _tp.tunit[3] += 12;
            if (_tp.tunit[3] == -1) /**���Ӷ�û����ȷʱ��㣬ֻд�ˡ�����/��䡱��������Ĵ��� @author kexm*/
                _tp.tunit[3] = RangeTimeEnum.noon.getHourTime();
            /**����������δ��ʱ������  @author kexm*/
            preferFuture(3);
            isAllDayTime = false;

        }

        rule = "(����)|(���)|(pm)|(PM)";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            if (_tp.tunit[3] >= 0 && _tp.tunit[3] <= 11)
                _tp.tunit[3] += 12;
            if (_tp.tunit[3] == -1) /**���Ӷ�û����ȷʱ��㣬ֻд�ˡ�����/��䡱��������Ĵ��� @author kexm*/
                _tp.tunit[3] = RangeTimeEnum.afternoon.getHourTime();
            /**����������δ��ʱ������  @author kexm*/
            preferFuture(3);
            isAllDayTime = false;
        }

        rule = "��";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            if (_tp.tunit[3] >= 1 && _tp.tunit[3] <= 11)
                _tp.tunit[3] += 12;
            else if (_tp.tunit[3] == 12)
                _tp.tunit[3] = 0;
            if (_tp.tunit[3] == -1) /**���Ӷ�û����ȷʱ��㣬ֻд�ˡ�����/��䡱��������Ĵ��� @author kexm*/
                _tp.tunit[3] = RangeTimeEnum.night.getHourTime();
            /**����������δ��ʱ������  @author kexm*/
            preferFuture(3);
            isAllDayTime = false;
        }


        rule = "[0-9]?[0-9]?[0-9]{2}-((10)|(11)|(12)|([1-9]))-((?<!\\d))([0-3][0-9]|[1-9])";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            tmp_parser = new String[3];
            tmp_target = match.group();
            tmp_parser = tmp_target.split("-");
            _tp.tunit[0] = Integer.parseInt(tmp_parser[0]);
            _tp.tunit[1] = Integer.parseInt(tmp_parser[1]);
            _tp.tunit[2] = Integer.parseInt(tmp_parser[2]);
        }

        rule = "((10)|(11)|(12)|([1-9]))/((?<!\\d))([0-3][0-9]|[1-9])/[0-9]?[0-9]?[0-9]{2}";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            tmp_parser = new String[3];
            tmp_target = match.group();
            tmp_parser = tmp_target.split("/");
            _tp.tunit[1] = Integer.parseInt(tmp_parser[0]);
            _tp.tunit[2] = Integer.parseInt(tmp_parser[1]);
            _tp.tunit[0] = Integer.parseInt(tmp_parser[2]);
        }
		
		/*
		 * ������:�̶���ʽʱ����ʽ ��.��.�� ����ȷʶ��
		 * add by ����
		 */
        rule = "[0-9]?[0-9]?[0-9]{2}\\.((10)|(11)|(12)|([1-9]))\\.((?<!\\d))([0-3][0-9]|[1-9])";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            tmp_parser = new String[3];
            tmp_target = match.group();
            tmp_parser = tmp_target.split("\\.");
            _tp.tunit[0] = Integer.parseInt(tmp_parser[0]);
            _tp.tunit[1] = Integer.parseInt(tmp_parser[1]);
            _tp.tunit[2] = Integer.parseInt(tmp_parser[2]);
        }
    }

    /**
     * ����������ʱ��Ϊ��׼��ʱ��ƫ�Ƽ���
     */
    public void norm_setBaseRelated() {
        String[] time_grid = new String[6];
        time_grid = normalizer.getTimeBase().split("-");
        int[] ini = new int[6];
        for (int i = 0; i < 6; i++)
            ini[i] = Integer.parseInt(time_grid[i]);

        Calendar calendar = Calendar.getInstance();
        calendar.setFirstDayOfWeek(Calendar.MONDAY);
        calendar.set(ini[0], ini[1] - 1, ini[2], ini[3], ini[4], ini[5]);
        calendar.getTime();

        boolean[] flag = {false, false, false};//�۲�ʱ����ʽ�Ƿ���ǰ���ʱ����ʽ���ı�ʱ��


        String rule = "\\d+(?=��[��֮]?ǰ)";
        Pattern pattern = Pattern.compile(rule);
        Matcher match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[2] = true;
            int day = Integer.parseInt(match.group());
            calendar.add(Calendar.DATE, -day);
        }

        rule = "\\d+(?=��[��֮]?��)";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[2] = true;
            int day = Integer.parseInt(match.group());
            calendar.add(Calendar.DATE, day);
        }

        rule = "\\d+(?=(��)?��[��֮]?ǰ)";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[1] = true;
            int month = Integer.parseInt(match.group());
            calendar.add(Calendar.MONTH, -month);
        }

        rule = "\\d+(?=(��)?��[��֮]?��)";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[1] = true;
            int month = Integer.parseInt(match.group());
            calendar.add(Calendar.MONTH, month);
        }

        rule = "\\d+(?=��[��֮]?ǰ)";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[0] = true;
            int year = Integer.parseInt(match.group());
            calendar.add(Calendar.YEAR, -year);
        }

        rule = "\\d+(?=��[��֮]?��)";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[0] = true;
            int year = Integer.parseInt(match.group());
            calendar.add(Calendar.YEAR, year);
        }

        String s = new SimpleDateFormat("yyyy-MM-dd-HH-mm-ss").format(calendar.getTime());
        String[] time_fin = s.split("-");
        if (flag[0] || flag[1] || flag[2]) {
            _tp.tunit[0] = Integer.parseInt(time_fin[0]);
        }
        if (flag[1] || flag[2])
            _tp.tunit[1] = Integer.parseInt(time_fin[1]);
        if (flag[2])
            _tp.tunit[2] = Integer.parseInt(time_fin[2]);
    }

    /**
     * ���õ�ǰʱ����ص�ʱ����ʽ
     */
    public void norm_setCurRelated() {
        String[] time_grid = new String[6];
        time_grid = normalizer.getOldTimeBase().split("-");
        int[] ini = new int[6];
        for (int i = 0; i < 6; i++)
            ini[i] = Integer.parseInt(time_grid[i]);

        Calendar calendar = Calendar.getInstance();
        calendar.setFirstDayOfWeek(Calendar.MONDAY);
        calendar.set(ini[0], ini[1] - 1, ini[2], ini[3], ini[4], ini[5]);
        calendar.getTime();

        boolean[] flag = {false, false, false};//�۲�ʱ����ʽ�Ƿ���ǰ���ʱ����ʽ���ı�ʱ��

        String rule = "ǰ��";
        Pattern pattern = Pattern.compile(rule);
        Matcher match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[0] = true;
            calendar.add(Calendar.YEAR, -2);
        }

        rule = "ȥ��";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[0] = true;
            calendar.add(Calendar.YEAR, -1);
        }

        rule = "����";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[0] = true;
            calendar.add(Calendar.YEAR, 0);
        }

        rule = "����";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[0] = true;
            calendar.add(Calendar.YEAR, 1);
        }

        rule = "����";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[0] = true;
            calendar.add(Calendar.YEAR, 2);
        }

        rule = "��(��)?��";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[1] = true;
            calendar.add(Calendar.MONTH, -1);

        }

        rule = "(��|���)��";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[1] = true;
            calendar.add(Calendar.MONTH, 0);
        }

        rule = "��(��)?��";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[1] = true;
            calendar.add(Calendar.MONTH, 1);
        }

        rule = "��ǰ��";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[2] = true;
            calendar.add(Calendar.DATE, -3);
        }

        rule = "(?<!��)ǰ��";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[2] = true;
            calendar.add(Calendar.DATE, -2);
        }

        rule = "��";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[2] = true;
            calendar.add(Calendar.DATE, -1);
        }

        rule = "��(?!��)";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[2] = true;
            calendar.add(Calendar.DATE, 0);
        }

        rule = "��(?!��)";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[2] = true;
            calendar.add(Calendar.DATE, 1);
        }

        rule = "(?<!��)����";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[2] = true;
            calendar.add(Calendar.DATE, 2);
        }

        rule = "�����";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[2] = true;
            calendar.add(Calendar.DATE, 3);
        }

        rule = "(?<=(����(��|����)))[1-7]?";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[2] = true;
            int week;
            try {
                week = Integer.parseInt(match.group());
            } catch (NumberFormatException e) {
                week = 1;
            }
            if (week == 7)
                week = 1;
            else
                week++;
            calendar.add(Calendar.WEEK_OF_MONTH, -2);
            calendar.set(Calendar.DAY_OF_WEEK, week);
        }

        rule = "(?<=((?<!��)��(��|����)))[1-7]?";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[2] = true;
            int week;
            try {
                week = Integer.parseInt(match.group());
            } catch (NumberFormatException e) {
                week = 1;
            }
            if (week == 7)
                week = 1;
            else
                week++;
            calendar.add(Calendar.WEEK_OF_MONTH, -1);
            calendar.set(Calendar.DAY_OF_WEEK, week);
        }

        rule = "(?<=((?<!��)��(��|����)))[1-7]?";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[2] = true;
            int week;
            try {
                week = Integer.parseInt(match.group());
            } catch (NumberFormatException e) {
                week = 1;
            }
            if (week == 7)
                week = 1;
            else
                week++;
            calendar.add(Calendar.WEEK_OF_MONTH, 1);
            calendar.set(Calendar.DAY_OF_WEEK, week);
        }

        rule = "(?<=(����(��|����)))[1-7]?";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[2] = true;
            int week;
            try {
                week = Integer.parseInt(match.group());
            } catch (NumberFormatException e) {
                week = 1;
            }
            if (week == 7)
                week = 1;
            else
                week++;
            calendar.add(Calendar.WEEK_OF_MONTH, 2);
            calendar.set(Calendar.DAY_OF_WEEK, week);
        }

        rule = "(?<=((?<!(��|��))(��|����)))[1-7]?";
        pattern = Pattern.compile(rule);
        match = pattern.matcher(Time_Expression);
        if (match.find()) {
            flag[2] = true;
            int week;
            try {
                week = Integer.parseInt(match.group());
            } catch (NumberFormatException e) {
                week = 1;
            }
            if (week == 7)
                week = 1;
            else
                week++;
            calendar.add(Calendar.WEEK_OF_MONTH, 0);
            calendar.set(Calendar.DAY_OF_WEEK, week);
            /**����δ��ʱ������ @author kexm*/
            preferFutureWeek(week, calendar);
        }

        String s = new SimpleDateFormat("yyyy-MM-dd-HH-mm-ss").format(calendar.getTime());
        String[] time_fin = s.split("-");
        if (flag[0] || flag[1] || flag[2]) {
            _tp.tunit[0] = Integer.parseInt(time_fin[0]);
        }
        if (flag[1] || flag[2])
            _tp.tunit[1] = Integer.parseInt(time_fin[1]);
        if (flag[2])
            _tp.tunit[2] = Integer.parseInt(time_fin[2]);

    }

    /**
     * �÷������ڸ���timeBaseʹ֮���������Ĺ�����
     */
    public void modifyTimeBase() {
        String[] time_grid = new String[6];
        time_grid = normalizer.getTimeBase().split("-");

        String s = "";
        if (_tp.tunit[0] != -1)
            s += Integer.toString(_tp.tunit[0]);
        else
            s += time_grid[0];
        for (int i = 1; i < 6; i++) {
            s += "-";
            if (_tp.tunit[i] != -1)
                s += Integer.toString(_tp.tunit[i]);
            else
                s += time_grid[i];
        }
        normalizer.setTimeBase(s);
    }

    /**
     * ʱ����ʽ�淶�������
     * <p>
     * ʱ����ʽʶ���ͨ������ڽ���淶���׶Σ�
     * ����ʶ��ÿ���ֶε�ֵ
     */
    public void Time_Normalization() {
        norm_setyear();
        norm_setmonth();
        norm_setday();
        norm_setmonth_fuzzyday();/**add by kexm*/
        norm_setBaseRelated();
        norm_setCurRelated();
        norm_sethour();
        norm_setminute();
        norm_setsecond();
        norm_setTotal();
        modifyTimeBase();

        _tp_origin.tunit = _tp.tunit.clone();

        String[] time_grid = new String[6];
        time_grid = normalizer.getTimeBase().split("-");

        int tunitpointer = 5;
        while (tunitpointer >= 0 && _tp.tunit[tunitpointer] < 0) {
            tunitpointer--;
        }
        for (int i = 0; i < tunitpointer; i++) {
            if (_tp.tunit[i] < 0)
                _tp.tunit[i] = Integer.parseInt(time_grid[i]);
        }
        String[] _result_tmp = new String[6];
        _result_tmp[0] = String.valueOf(_tp.tunit[0]);
        if (_tp.tunit[0] >= 10 && _tp.tunit[0] < 100) {
            _result_tmp[0] = "19" + String.valueOf(_tp.tunit[0]);
        }
        if (_tp.tunit[0] > 0 && _tp.tunit[0] < 10) {
            _result_tmp[0] = "200" + String.valueOf(_tp.tunit[0]);
        }

        for (int i = 1; i < 6; i++) {
            _result_tmp[i] = String.valueOf(_tp.tunit[i]);
        }

        Calendar cale = Calendar.getInstance();            //leverage a calendar object to figure out the final time
        cale.clear();
        if (Integer.parseInt(_result_tmp[0]) != -1) {
            Time_Norm += _result_tmp[0] + "��";
            cale.set(Calendar.YEAR, Integer.valueOf(_result_tmp[0]));
            if (Integer.parseInt(_result_tmp[1]) != -1) {
                Time_Norm += _result_tmp[1] + "��";
                cale.set(Calendar.MONTH, Integer.valueOf(_result_tmp[1]) - 1);
                if (Integer.parseInt(_result_tmp[2]) != -1) {
                    Time_Norm += _result_tmp[2] + "��";
                    cale.set(Calendar.DAY_OF_MONTH, Integer.valueOf(_result_tmp[2]));
                    if (Integer.parseInt(_result_tmp[3]) != -1) {
                        Time_Norm += _result_tmp[3] + "ʱ";
                        cale.set(Calendar.HOUR_OF_DAY, Integer.valueOf(_result_tmp[3]));
                        if (Integer.parseInt(_result_tmp[4]) != -1) {
                            Time_Norm += _result_tmp[4] + "��";
                            cale.set(Calendar.MINUTE, Integer.valueOf(_result_tmp[4]));
                            if (Integer.parseInt(_result_tmp[5]) != -1) {
                                Time_Norm += _result_tmp[5] + "��";
                                cale.set(Calendar.SECOND, Integer.valueOf(_result_tmp[5]));
                            }
                        }
                    }
                }
            }
        }
        time = cale.getTime();

        time_full = _tp.tunit.clone();
//		time_origin = _tp_origin.tunit.clone(); comment by kexm
    }

    public Boolean getIsAllDayTime() {
        return isAllDayTime;
    }

    public void setIsAllDayTime(Boolean isAllDayTime) {
        this.isAllDayTime = isAllDayTime;
    }

    public String toString() {
        return Time_Expression + " ---> " + Time_Norm;
    }

    /**
     * ����û�ѡ����������δ��ʱ�䣬���checkTimeIndex��ָ��ʱ���Ƿ��ǹ�ȥ��ʱ�䣬����ǵĻ�������һ����ʱ����Ϊ��ǰʱ���+1��
     * <p>
     * ��������˵������8�㿴�顱����ʶ��Ϊ��������;
     * 12��31��˵��3����ˡ�����ʶ��Ϊ����1�µ�3�š�
     *
     * @param checkTimeIndex _tp.tunitʱ��������±�
     */
    private void preferFuture(int checkTimeIndex) {
        /**1. ��鱻����ʱ�伶��֮ǰ���Ƿ�û�и��߼����Ѿ�ȷ����ʱ�䣬����У��򲻽��д���.*/
        for (int i = 0; i < checkTimeIndex; i++) {
            if (_tp.tunit[i] != -1) return;
        }
        /**2. ���������Ĳ���ʱ��*/
        checkContextTime(checkTimeIndex);
        /**3. ���������Ĳ���ʱ����ٴμ�鱻����ʱ�伶��֮ǰ���Ƿ�û�и��߼����Ѿ�ȷ����ʱ�䣬����У��򲻽���������.*/
        for (int i = 0; i < checkTimeIndex; i++) {
            if (_tp.tunit[i] != -1) return;
        }
        /**4. ȷ���û�ѡ��*/
        if (!normalizer.isPreferFuture()) {
            return;
        }
        /**5. ��ȡ��ǰʱ�䣬���ʶ�𵽵�ʱ��С�ڵ�ǰʱ�䣬�����ϵ����м���ʱ������Ϊ��ǰʱ�䣬��������һ����ʱ�䲽��+1*/
        Calendar c = Calendar.getInstance();
        if (this.normalizer.getTimeBase() != null) {
            String[] ini = this.normalizer.getTimeBase().split("-");
            c.set(Integer.valueOf(ini[0]).intValue(), Integer.valueOf(ini[1]).intValue() - 1, Integer.valueOf(ini[2]).intValue()
                    , Integer.valueOf(ini[3]).intValue(), Integer.valueOf(ini[4]).intValue(), Integer.valueOf(ini[5]).intValue());
//            LOGGER.debug(DateUtil.formatDateDefault(c.getTime()));
        }

        int curTime = c.get(TUNIT_MAP.get(checkTimeIndex));
        if (curTime < _tp.tunit[checkTimeIndex]) {
            return;
        }
        //׼�����ӵ�ʱ�䵥λ�Ǳ�����ʱ�����һ��������һ��ʱ��+1
        int addTimeUnit = TUNIT_MAP.get(checkTimeIndex - 1);
        c.add(addTimeUnit, 1);

//		_tp.tunit[checkTimeIndex - 1] = c.get(TUNIT_MAP.get(checkTimeIndex - 1));
        for (int i = 0; i < checkTimeIndex; i++) {
            _tp.tunit[i] = c.get(TUNIT_MAP.get(i));
            if (TUNIT_MAP.get(i) == Calendar.MONTH) {
                ++_tp.tunit[i];
            }
        }

    }

    /**
     * ����û�ѡ����������δ��ʱ�䣬�����ָ��day_of_week�Ƿ��ǹ�ȥ��ʱ�䣬����ǵĻ�����Ϊ���ܡ�
     * <p>
     * ��������˵����һ���ᣬʶ��Ϊ����һ����
     *
     * @param weekday ʶ������ܼ�����Χ1-7��
     */
    private void preferFutureWeek(int weekday, Calendar c) {
        /**1. ȷ���û�ѡ��*/
        if (!normalizer.isPreferFuture()) {
            return;
        }
        /**2. ��鱻����ʱ�伶��֮ǰ���Ƿ�û�и��߼����Ѿ�ȷ����ʱ�䣬����У��򲻽���������.*/
        int checkTimeIndex = 2;
        for (int i = 0; i < checkTimeIndex; i++) {
            if (_tp.tunit[i] != -1) return;
        }
        /**��ȡ��ǰ�����ܼ������ʶ�𵽵�ʱ��С�ڵ�ǰʱ�䣬��ʶ��ʱ��Ϊ��һ��*/
        Calendar curC = Calendar.getInstance();
        if (this.normalizer.getTimeBase() != null) {
            String[] ini = this.normalizer.getTimeBase().split("-");
            curC.set(Integer.valueOf(ini[0]).intValue(), Integer.valueOf(ini[1]).intValue() - 1, Integer.valueOf(ini[2]).intValue()
                    , Integer.valueOf(ini[3]).intValue(), Integer.valueOf(ini[4]).intValue(), Integer.valueOf(ini[5]).intValue());
        }
        int curWeekday = curC.get(Calendar.DAY_OF_WEEK);
        if (weekday == 1) {
            weekday = 7;
        }
        if (curWeekday < weekday) {
            return;
        }
        //׼�����ӵ�ʱ�䵥λ�Ǳ�����ʱ�����һ��������һ��ʱ��+1
        c.add(Calendar.WEEK_OF_YEAR, 1);
    }

    /**
     * ����������ʱ�䲹��ʱ����Ϣ
     */
    private void checkContextTime(int checkTimeIndex) {
        for (int i = 0; i < checkTimeIndex; i++) {
            if (_tp.tunit[i] == -1 && _tp_origin.tunit[i] != -1) {
                _tp.tunit[i] = _tp_origin.tunit[i];
            }
        }
        /**�ڴ���Сʱ�������ʱ���������ʱ���������������û����������Сʱ�������ϵ�ʱ�䣬��Ҳ������ʱ����Ϊ����*/
        if (isFirstTimeSolveContext == true && checkTimeIndex == 3 && _tp_origin.tunit[checkTimeIndex] >= 12 && _tp.tunit[checkTimeIndex] < 12) {
            _tp.tunit[checkTimeIndex] += 12;
        }
        isFirstTimeSolveContext = false;
    }

    private static Map<Integer, Integer> TUNIT_MAP = new HashMap<>();

    static {
        TUNIT_MAP.put(0, Calendar.YEAR);
        TUNIT_MAP.put(1, Calendar.MONTH);
        TUNIT_MAP.put(2, Calendar.DAY_OF_MONTH);
        TUNIT_MAP.put(3, Calendar.HOUR_OF_DAY);
        TUNIT_MAP.put(4, Calendar.MINUTE);
        TUNIT_MAP.put(5, Calendar.SECOND);
    }
}

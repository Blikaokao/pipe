import 'lunar.dart';
class GetLunar{

  static String getLunar(int year,int month,int day){
    String solarfest = HolidayUtil.getHolidayByMD(month,day);
    if(solarfest!=null){
      return solarfest;
    }
    //节气、农历节日
    Lunar lunar = Solar.fromYmd(year, month, day).getLunar();
    String lunarFest = lunar.getLunarDay();
    return lunarFest;

  }

}
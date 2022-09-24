/**
 * Copyright (c) 2016 21CN.COM . All rights reserved.<br>
 *
 * Description: fudannlp<br>
 * 
 * Modified log:<br>
 * ------------------------------------------------------<br>
 * Ver.		Date		Author			Description<br>
 * ------------------------------------------------------<br>
 * 1.0		2016��5��3��		kexm		created.<br>
 */
package com.hln.daydayup.transferDate.time.enums;

/**
 * <p>
 * ��Χʱ���Ĭ��ʱ���
 * <p>
 * @author <a href="mailto:kexm@corp.21cn.com">kexm</a>
 * @version 
 * @since 2016��5��3��
 * 
 */
public enum RangeTimeEnum {
	
	day_break(3),
	early_morning(8), //��
	morning(10), //����
	noon(12), //���硢���
	afternoon(15), //���硢���
	night(18), //���ϡ�����
	lateNight(20), //�����
	midNight(23);  //��ҹ
	
	private int hourTime = 0;

	/**
	 * @param hourTime
	 */
	private RangeTimeEnum(int hourTime) {
		this.setHourTime(hourTime);
	}

	/**
	 * @return the hourTime
	 */
	public int getHourTime() {
		return hourTime;
	}

	/**
	 * @param hourTime the hourTime to set
	 */
	public void setHourTime(int hourTime) {
		this.hourTime = hourTime;
	}
	
}

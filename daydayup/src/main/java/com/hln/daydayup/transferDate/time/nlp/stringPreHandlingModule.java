package com.hln.daydayup.transferDate.time.nlp;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * �ַ���Ԥ����ģ�飬Ϊ������TimeNormalizer�ṩ��Ӧ���ַ���Ԥ�������
 * 
 * @author ����07300720158
 *
 */
public class stringPreHandlingModule {

	/**
	 * �÷���ɾ��һ�ַ���������ƥ��ĳһ�����ִ�
	 * ����������һ���ַ����еĿհ׷�����������
	 * 
	 * @param target �������ַ���
	 * @param rules ɾ������
	 * @return ��������ɺ���ַ���
	 */
	public static String delKeyword(String target, String rules){
		Pattern p = Pattern.compile(rules); 
		Matcher m = p.matcher(target); 
		StringBuffer sb = new StringBuffer(); 
		boolean result = m.find(); 
		while(result) { 
			m.appendReplacement(sb, ""); 
			result = m.find(); 
		}
		m.appendTail(sb);
		String s = sb.toString();
		//System.out.println("�ַ�����"+target+" �Ĵ�����ַ���Ϊ��" +sb);
		return s;
	}
	
	/**
	 * �÷������Խ��ַ��������е��ú��ֱ�ʾ������ת��Ϊ�ð��������ֱ�ʾ������
	 * ��"������һǧ���ٸ��ˣ���������������й�"����ת��Ϊ
	 * "������1200���ˣ�605�������й�"
	 * �������֧���˲��ֲ������﷽��
	 * ���������������ת��Ϊ20650
	 * ����һʮ�ĺ�����ʮ�Ķ�����ת��Ϊ214
	 * һ�����һ��˿���ת��Ϊ160+158
	 * �÷���Ŀǰ֧�ֵ���ȷת����Χ��0-99999999
	 * �ù���ģ��������õĸ�����
	 * 
	 * @param target ��ת�����ַ���
	 * @return ת����Ϻ���ַ���
	 */
	public static String numberTranslator(String target){
		Pattern p = Pattern.compile("[һ�������������߰˾�123456789]��[һ�������������߰˾�123456789](?!(ǧ|��|ʮ))"); 
		Matcher m = p.matcher(target); 
		StringBuffer sb = new StringBuffer(); 
		boolean result = m.find(); 
		while(result) { 
			String group = m.group();
			String[] s = group.split("��");
			int num = 0;
			if(s.length == 2){
				num += wordToNumber(s[0])*10000 + wordToNumber(s[1])*1000;
			}
			m.appendReplacement(sb, Integer.toString(num)); 
			result = m.find(); 
		}
		m.appendTail(sb);
		target = sb.toString();
		
		p = Pattern.compile("[һ�������������߰˾�123456789]ǧ[һ�������������߰˾�123456789](?!(��|ʮ))"); 
		m = p.matcher(target); 
		sb = new StringBuffer(); 
		result = m.find(); 
		while(result) { 
			String group = m.group();
			String[] s = group.split("ǧ");
			int num = 0;
			if(s.length == 2){
				num += wordToNumber(s[0])*1000 + wordToNumber(s[1])*100;
			}
			m.appendReplacement(sb, Integer.toString(num)); 
			result = m.find(); 
		}
		m.appendTail(sb);
		target = sb.toString();
		
		p = Pattern.compile("[һ�������������߰˾�123456789]��[һ�������������߰˾�123456789](?!ʮ)"); 
		m = p.matcher(target); 
		sb = new StringBuffer(); 
		result = m.find(); 
		while(result) { 
			String group = m.group();
			String[] s = group.split("��");
			int num = 0;
			if(s.length == 2){
				num += wordToNumber(s[0])*100 + wordToNumber(s[1])*10;
			}
			m.appendReplacement(sb, Integer.toString(num)); 
			result = m.find(); 
		}
		m.appendTail(sb);
		target = sb.toString();
		
		p = Pattern.compile("[��һ�������������߰˾�]"); 
		m = p.matcher(target); 
		sb = new StringBuffer(); 
		result = m.find(); 
		while(result) { 
			m.appendReplacement(sb, Integer.toString(wordToNumber(m.group()))); 
			result = m.find(); 
		}
		m.appendTail(sb);
		target = sb.toString();
		
		p = Pattern.compile("(?<=(��|����))[ĩ����]"); 
		m = p.matcher(target); 
		sb = new StringBuffer(); 
		result = m.find(); 
		while(result) { 
			m.appendReplacement(sb, Integer.toString(wordToNumber(m.group()))); 
			result = m.find(); 
		}
		m.appendTail(sb);
		target = sb.toString();
		
		p = Pattern.compile("(?<!(��|����))0?[0-9]?ʮ[0-9]?"); 
		m = p.matcher(target);
		sb = new StringBuffer();
		result = m.find();
		while(result) { 
			String group = m.group();
			String[] s = group.split("ʮ");
			int num = 0;
			if(s.length == 0){
				num += 10;
			}
			else if(s.length == 1){
				int ten = Integer.parseInt(s[0]);
				if(ten == 0)
					num += 10;
				else num += ten*10;
			}
			else if(s.length == 2){
				if(s[0].equals(""))
					num += 10;
				else{
					int ten = Integer.parseInt(s[0]);
					if(ten == 0)
						num += 10;
					else num += ten*10;
				}
				num += Integer.parseInt(s[1]);
			}
			m.appendReplacement(sb, Integer.toString(num)); 
			result = m.find(); 
		}
		m.appendTail(sb);
		target = sb.toString();
		
		p = Pattern.compile("0?[1-9]��[0-9]?[0-9]?"); 
		m = p.matcher(target);
		sb = new StringBuffer();
		result = m.find();
		while(result) { 
			String group = m.group();
			String[] s = group.split("��");
			int num = 0;
			if(s.length == 1){
				int hundred = Integer.parseInt(s[0]);
				num += hundred*100;
			}
			else if(s.length == 2){
				int hundred = Integer.parseInt(s[0]);
				num += hundred*100;
				num += Integer.parseInt(s[1]);
			}
			m.appendReplacement(sb, Integer.toString(num)); 
			result = m.find(); 
		}
		m.appendTail(sb);
		target = sb.toString();
		
		p = Pattern.compile("0?[1-9]ǧ[0-9]?[0-9]?[0-9]?"); 
		m = p.matcher(target);
		sb = new StringBuffer();
		result = m.find();
		while(result) { 
			String group = m.group();
			String[] s = group.split("ǧ");
			int num = 0;
			if(s.length == 1){
				int thousand = Integer.parseInt(s[0]);
				num += thousand*1000;
			}
			else if(s.length == 2){
				int thousand = Integer.parseInt(s[0]);
				num += thousand*1000;
				num += Integer.parseInt(s[1]);
			}
			m.appendReplacement(sb, Integer.toString(num)); 
			result = m.find(); 
		}
		m.appendTail(sb);
		target = sb.toString();
		
		p = Pattern.compile("[0-9]+��[0-9]?[0-9]?[0-9]?[0-9]?"); 
		m = p.matcher(target);
		sb = new StringBuffer();
		result = m.find();
		while(result) { 
			String group = m.group();
			String[] s = group.split("��");
			int num = 0;
			if(s.length == 1){
				int tenthousand = Integer.parseInt(s[0]);
				num += tenthousand*10000;
			}
			else if(s.length == 2){
				int tenthousand = Integer.parseInt(s[0]);
				num += tenthousand*10000;
				num += Integer.parseInt(s[1]);
			}
			m.appendReplacement(sb, Integer.toString(num)); 
			result = m.find(); 
		}
		m.appendTail(sb);
		target = sb.toString();
		
		return target;
	}
	
	/**
	 * ����numberTranslator�ĸ����������ɽ�[��-��]��ȷ����Ϊ[0-9]
	 * 
	 * @param s ��д����
	 * @return ��Ӧ����������������Ǵ�д���ַ���-1
	 */
	private static int wordToNumber(String s){
		if(s.equals("��")||s.equals("0"))
			return 0;
		else if(s.equals("һ")||s.equals("1"))
			return 1;
		else if(s.equals("��")||s.equals("��")||s.equals("2"))
			return 2;
		else if(s.equals("��")||s.equals("3"))
			return 3;
		else if(s.equals("��")||s.equals("4"))
			return 4;
		else if(s.equals("��")||s.equals("5"))
			return 5;
		else if(s.equals("��")||s.equals("6"))
			return 6;
		else if(s.equals("��")||s.equals("��")||s.equals("��") || s.equals("ĩ") ||s.equals("7"))
			return 7;
		else if(s.equals("��")||s.equals("8"))
			return 8;
		else if(s.equals("��")||s.equals("9"))
			return 9;
		else return -1;
	}
}








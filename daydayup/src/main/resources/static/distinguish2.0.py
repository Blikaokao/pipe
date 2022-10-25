# -*- coding: utf-8 -*-
"""
Created on Thu Mar 10 15:16:42 2022

@author: Dell
"""

import io
import sys
import importlib
import time
import datetime
import jionlp as jio
import re
entities = []
previous_date = ""

def tencent_conference(text):
    d1 = jio.ner.extract_time(text, time_base=time.time(),with_parsing=False)
    d2 = jio.parse_time(d1[0]['text'], time_base=time.time())
    th = d2['time'][0]  #解析数字时间（开始时间
    tt = d2['time'][1]  #解析数字时间（结束时间
    number = text.split("腾讯会议：",1)[1][0:11]
    link = jio.extract_url(text, detail=False)
    event = "腾讯会议，会议号：" + number + "，会议链接：" + link[0]
    entity = {'begtime':th,'endtime':tt,'event':event}
    entities.append(entity)
    return 0

def single_time(text):
    global previous_date
    #print("现在是单个时间实体时间！")
    d1 = jio.ner.extract_time(text, time_base=time.time(),with_parsing=True)
    #print(d1)
    t0 = d1[0]['detail']['time'][0]
    t1 = d1[0]['detail']['time'][1]
    if t0 == '-inf': 
        th = "" #x月x日前
        tt = t1
    if t1 == 'inf':
        th = t0
        tt = "" #从x月x日开始
    if t0 != '-inf' and t1 != 'inf':
        data_1 = datetime.datetime.strptime(t0, "%Y-%m-%d %H:%M:%S")
        data_2 = datetime.datetime.strptime(t1, "%Y-%m-%d %H:%M:%S")
        if data_2 < data_1:
            data_2 = data_2 + datetime.timedelta(hours=12)
        
        th = data_1.strftime('%Y-%m-%d %H:%M:%S')
        tt = data_2.strftime('%Y-%m-%d %H:%M:%S')
    event = text.replace(d1[0]['text'], '')#删掉已经提取的时间实体
    #print(event)
    if event != '':
        punctuation = '、，。；：/,.;:' #删掉事件字符前后的标点
        for p in punctuation:
            if event[0] == p and event != '':
                event = event.lstrip(p)
        for p in punctuation:
            if event[len(event)-1] == p and event != '':
                event = event.rstrip(p)
    if (d1[0]['text'].find('日') == -1) and (d1[0]['text'].find('.') == -1) and (d1[0]['text'].find('/') == -1) and (d1[0]['text'].find('周') == -1) and (d1[0]['text'].find('天') == -1) and (d1[0]['text'].find('旬') == -1): #没有date只有time的一个时间
        if previous_date != "": #前面曾记录过date
            th = previous_date + th[11:19]
            tt = previous_date + tt[11:19]
    else:
        previous_date = th[0:11]
    #print(previous_date)
    entity = {'begtime':th,'endtime':tt,'event':event}
    entities.append(entity)
    

# 向前切割，遇到时间段和time时间点即切割    
def cut_forward(ptext,sec_cuttext,d2):
    global previous_date
    flag = 0
    for i in range(0,len(d2)):
        if d2[i]['text'].find(":") == -1: epiont = False
        else: epiont = True
        if d2[i]['text'].find("点") == -1: cpiont = False
        else: cpiont = True
        if d2[i]['type'] == 'time_span' or (d2[i]['type'] == 'time_point' and (epiont or cpiont)) > 0: factor = True
        else: factor = False
        if factor == True:
            sec_cuttext.append(ptext[flag:d2[i]['offset'][1]])
            flag = d2[i]['offset'][1]
    sec_cuttext.append(ptext[flag:len(ptext)])
    #print(sec_cuttext)
    for parttext in sec_cuttext:
        #print(parttext)
        d3 = jio.ner.extract_time(parttext, time_base=time.time(),with_parsing=True)
        #print(d3)
        # 切割后每个文本只有一个时间实体
        if len(d3) == 1:
            #print("只有一个时间实体！")
            special_time = ['暑假','暑期','寒假','春天','春季','夏天','秋天','冬天','今年','明年','白天','今日','明天','上午','下午','六月','3月','四月']
            sc1 = True
            sc2 = True
            for st in special_time:
                if d3[0]['text'] == st: sc1 = False
            t0 = d3[0]['detail']['time'][0]
            t1 = d3[0]['detail']['time'][1]
            if t0 != '-inf' and t1 != 'inf':
                data_1 = datetime.datetime.strptime(t0, "%Y-%m-%d %H:%M:%S")
                data_2 = datetime.datetime.strptime(t1, "%Y-%m-%d %H:%M:%S")
                if (data_2 - data_1).days > 180: sc2 = False
            if sc1 and sc2:
                single_time(parttext)
                
        # 切割后每个文本仍有多个时间实体
        if len(d3) > 1:
            if d3[len(d3)-1]['text'].find(":") == -1: epiont = False
            else: epiont = True
            if d3[len(d3)-1]['text'].find("点") == -1: cpiont = False
            else: cpiont = True
            # 如果最后一个时间实体是点时间段，把这个time赋给前面的每一个date
            if d3[len(d3)-1]['type'] == 'time_span' and (epiont or cpiont) and d3[len(d3)-2]['type'] == 'time_point':
                event = parttext
                #print(event)
                for temp in d3:
                    event = event.replace(temp['text'], '')
                if event != '':
                    punctuation = '、，。；：/,.;:！' #删掉事件字符前后的标点
                    for p in punctuation:
                        if event[0] == p and event != '':
                            event = event.lstrip(p)
                pattern = re.compile(r'(\d{2}|\d{1}):(\d{2})-(\d{2}|\d{1}):(\d{2})')
                t = d3[len(d3)-1]['text'].replace(" ", "")
                d3[len(d3)-1]['text'] = t #去空格
                m = pattern.search(t)
                #print(m)
                #print(m.span(0))
                #print(t[m.span(0)[0]:m.span(0)[1]])
                d3[len(d3)-1]['text'] = d3[len(d3)-1]['text'].replace(t[m.span(0)[0]:m.span(0)[1]], "")
                #print(d3[len(d3)-1]['text'])
                if d3[len(d3)-1]['text'] == '':
                    d3.pop(len(d3)-1)
                for temp in d3:
                        temp['text'] = temp['text'] + t[m.span(0)[0]:m.span(0)[1]]
                #print(d3)
                for temp in d3:
                    if temp['type'] == 'time_point' or temp['type'] == 'time_span':
                        d2 = jio.parse_time(temp['text'], time_base=time.time())
                        #print(d2)
                        t0 = d2['time'][0]  #解析数字时间（开始时间
                        t1 = d2['time'][1]  #解析数字时间（结束时间
                        if t0 == '-inf': t0 = "" #x月x日前
                        if t1 == 'inf': t1 = "" #从x月x日开始
                        entity = {'begtime':t0,'endtime':t1,'event':event}
                        entities.append(entity)
            # 多个时间实体都是时间点或者时间点+date时间段，切割，单独返回
            else:
                trd_cuttime = []
                k = 0
                for i in range(0,len(d3)):
                    trd_cuttime.append(parttext[k:d3[i]['offset'][1]])
                    k = d3[i]['offset'][1]
                if k != (len(parttext)):
                    trd_cuttime.append(parttext[k:len(parttext)])
                #print(trd_cuttime)
                for pt in trd_cuttime:
                    d4 = jio.ner.extract_time(pt, time_base=time.time(),with_parsing=True)
                    if len(d4) == 1: 
                        if isinstance(d4[0]['detail']['time'],list):
                            special_time = ['暑假','暑期','寒假','春天','春季','夏天','秋天','冬天','今年','明年','白天','今日','明天','上午','下午','六月','3月','四月']
                            sc1 = True
                            sc2 = True
                            for st in special_time:
                                if d4[0]['text'] == st: sc1 = False
                            t0 = d4[0]['detail']['time'][0]
                            t1 = d4[0]['detail']['time'][1]
                            if t0 != '-inf' and t1 != 'inf':
                                data_1 = datetime.datetime.strptime(t0, "%Y-%m-%d %H:%M:%S")
                                data_2 = datetime.datetime.strptime(t1, "%Y-%m-%d %H:%M:%S")
                                if (data_2 - data_1).days > 180: sc2 = False
                            if sc1 and sc2:
                                single_time(pt)
            
def cut_back(ptext,sec_cuttext,d2):
    global previous_date
    flag = 0
    for i in range(0,len(d2)):
        if d2[i]['text'].find(":") == -1: epiont = False
        else: epiont = True
        if d2[i]['text'].find("点") == -1: cpiont = False
        else: cpiont = True
        if d2[i]['type'] == 'time_span' or (d2[i]['type'] == 'time_point' and (epiont or cpiont)) > 0: factor = True
        else: factor = False
        if factor == True:   
            sec_cuttext.append(ptext[flag:d2[i]['offset'][0]])
            flag = d2[i]['offset'][0]
    sec_cuttext.append(ptext[flag:len(ptext)])
    #print(sec_cuttext)      
    for parttext in sec_cuttext:
        dtime2 = jio.ner.extract_time(parttext, time_base=time.time(),with_parsing=True)
        #print(dtime2)
        if len(dtime2) == 1:
            if isinstance(dtime2[0]['detail']['time'],list):
                special_time = ['暑假','暑期','寒假','春天','夏天','秋天','冬天','今年','明年']
                sc1 = True
                sc2 = True
                for st in special_time:
                    if dtime2[0]['text'] == st: sc1 = False
                data_1 = datetime.datetime.strptime(dtime2[0]['detail']['time'][0], "%Y-%m-%d %H:%M:%S")
                data_2 = datetime.datetime.strptime(dtime2[0]['detail']['time'][1], "%Y-%m-%d %H:%M:%S")
                if (data_2 - data_1).days > 80: sc2 = False
                if sc1 and sc2:
                    single_time(parttext)
        parttext = parttext.replace("、", "和")
        if len(dtime2) > 1:
            if dtime2[len(dtime2)-1]['text'].find(":") == -1: epiont = False
            else: epiont = True
            if dtime2[len(dtime2)-1]['text'].find("点") == -1: cpiont = False
            else: cpiont = True
            # 如果最后一个时间实体是点时间段，把这个time赋给前面的每一个date
            if dtime2[len(dtime2)-1]['type'] == 'time_span' and (epiont or cpiont) :
                event = parttext
                for temp in dtime2:
                    event = event.replace(temp['text'], '')
                pattern = re.compile(r'(\d{2}|\d{1}):(\d{2})-(\d{2}|\d{1}):(\d{2})')
                t = dtime2[len(dtime2)-1]['text'].replace(" ", "")
                dtime2[len(dtime2)-1]['text'] = t #去空格
                m = pattern.search(t)
                #print(m)
                #print(m.span(0))
                dtime2[len(dtime2)-1]['text'] = dtime2[len(dtime2)-1]['text'].replace(t[m.span(0)[0]:m.span(0)[1]], "")
                if dtime2[len(dtime2)-1]['text'] == '':
                    dtime2.pop(len(dtime2)-1)
                for temp in dtime2:
                    temp['text'] = temp['text'] + t[m.span(0)[0]:m.span(0)[1]]
                for temp in dtime2:
                    d2 = jio.parse_time(temp['text'], time_base=time.time())
                    t0 = d2['time'][0]  #解析数字时间（开始时间
                    t1 = d2['time'][1]  #解析数字时间（结束时间
                    if t0 == '-inf': t0 = "" #x月x日前
                    if t1 == 'inf': t1 = "" #从x月x日开始
                    
                    entity = {'begtime':t0,'endtime':t1,'event':event}
                    entities.append(entity)
            # 多个时间实体都是时间点或者时间点+date时间段，切割，单独返回
            else:
                d4 = jio.ner.extract_time(parttext, time_base=time.time(),with_parsing=True)
                #print(d4)
                special_time = ['暑假','暑期','寒假','春天','春季','夏天','秋天','冬天','今年','明年','白天','今日','明天','上午','下午','六月','3月','四月']
                for dtemp in d4:
                    for st in special_time:
                        if dtemp['text'] == st:
                            parttext = parttext.replace(dtemp['text'],"")
                    if isinstance(dtemp['detail']['time'],dict):
                        parttext = parttext.replace(dtemp['text'],"")
                #print(parttext)
                dtime2 = jio.ner.extract_time(parttext, time_base=time.time(),with_parsing=True)
                #print(dtime2)
                trd_cuttime = []
                k = 0
                if k != dtime2[0]['offset'][0]:
                    trd_cuttime.append(parttext[k:dtime2[0]['offset'][0]])
                    k = dtime2[0]['offset'][0]
                for i in range(0,len(dtime2)-1):
                    trd_cuttime.append(parttext[k:dtime2[i+1]['offset'][0]])
                    k = dtime2[i+1]['offset'][0]
                if k != (len(parttext)):
                    trd_cuttime.append(parttext[k:len(parttext)])
                #print(trd_cuttime)
                for pt in trd_cuttime:
                    d4 = jio.ner.extract_time(pt, time_base=time.time(),with_parsing=True)
                    #print(d4)
                    if len(d4) >= 1:
                        special_time = ['暑假','暑期','寒假','春天','春季','夏天','秋天','冬天','今年','明年','白天','今日','明天','上午','下午','六月','3月','四月','春节']
                        sc1 = True
                        sc2 = True
                        for st in special_time:
                            if d4[0]['text'] == st: sc1 = False
                        data_1 = datetime.datetime.strptime(d4[0]['detail']['time'][0], "%Y-%m-%d %H:%M:%S")
                        data_2 = datetime.datetime.strptime(d4[0]['detail']['time'][1], "%Y-%m-%d %H:%M:%S")
                        if (data_2 - data_1).days > 80: sc2 = False
                        #print(sc1)
                        #print(sc2)
                        if sc1 and sc2:
                            single_time(pt)

    
def cut_after_mulptime(ptext):
    # 判断切割方向
    if ptext.find('时间为') == -1: c1 = False
    else: c1 = True
    if ptext.find('时间:') == -1: c2 = False
    else: c2 = True
    if ptext.find('时间：') == -1: c3 = False
    else: c3 = True
    if ptext.find('时间】') == -1: c4 = False
    else: c4 = True
    if ptext.find('课:') == -1: c5 = False
    else: c5 = True
    if ptext.find('日期:') == -1: c6 = False
    else: c6 = True
    if ptext.find('日期：') == -1: c7 = False
    else: c7 = True
    if ptext.find('调整') == -1: c8 = False
    else: c8 = True
    if (c1 or c2 or c3 or c4 or c5 or c6 or c7 or c8) :
        condition = True
    else:
        condition = False
    sec_cuttext = []
    d2 = jio.ner.extract_time(ptext, time_base=time.time(),with_parsing=True)
    #print(d2)
    #print(len(d2))
    projects=[ptext,sec_cuttext,d2]            
    # 向前切割
    if condition == True :
        cut_forward(*projects)
    # 向后切割
    if condition == False :
        cut_back(*projects)

def distinguish(text):
    importlib.reload(sys)
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    
    # 判断是否是腾讯会议模型
    if text.find('请您参加腾讯会议') == -1: tc1 = False
    else: tc1 = True
    if text.find('会议时间') == -1: tc2 = False
    else: tc2 = True
    if tc1 and tc2: condition = True
    else: condition = False
    if condition :
        tencent_conference(text)
        return 0
    
    # 判断是否是修改时间类型的文本
    modify = ["改为","改到","改成","延期","后延","延缓","延迟","推迟"]
    for mod in modify:
        if text.find(mod) != -1: #找到了相应的关键词
            posit = text.find(mod)
            #print(posit)
            text1 = text[0:posit]
            text2 = text[posit:len(text)]
            date1 = jio.ner.extract_time(text1, time_base=time.time(),with_parsing=True)
            date2 = jio.ner.extract_time(text2, time_base=time.time(),with_parsing=True)
            #print(date1)
            #print(date2)
            event = text1
            #print(event)
            for temp in date1:
                event = event.replace(temp['text'], '')
            for temp in date2:
                th = temp['detail']['time'][0]
                tt = temp['detail']['time'][1]
                entity = {'begtime':th,'endtime':tt,'event':event}
                entities.append(entity)
            return 0
    
    
    # 判断文本时间实体数量
    d1 = jio.ner.extract_time(text, time_base=time.time(),with_parsing=True)
    #print(d1)
    
    # 无时间实体
    if len(d1) == 0:
        th = ""
        tt = ""
        event = text
        entity = {'begtime':th,'endtime':tt,'event':event}
        entities.append(entity)
       
    # 单一时间实体
    #if len(d1) == 1:
        #single_time(text)
        
    # 多个时间实体
    if len(d1) >= 1:
        
        # 先对。和; 位置进行切割
        cut_text_temp1 = text.split("。")
        cut_text1 = []
        cut_text = []
        for t in cut_text_temp1:
            cut_text_temp2 = t.split(";")
            for temp in cut_text_temp2:
                cut_text1.append(temp)
        for t in cut_text1:
            cut_text_temp3 = t.split("！")
            for temp in cut_text_temp3:
                cut_text.append(temp)
        #print(cut_text)
        
        # 对切割后的每个文本进行处理
        for ptext in cut_text:
            ptext = ptext.replace("、", "和")
            dtime1 = jio.ner.extract_time(ptext, time_base=time.time(),with_parsing=True)
            #print(dtime1)
            # 如果切割后的文本只有一个时间实体
            if len(dtime1) == 1:
                if isinstance(dtime1[0]['detail']['time'],list):
                    special_time = ['暑假','暑期','寒假','春天','春季','夏天','秋天','冬天','今年','明年','白天','今日','明天','上午','下午','六月','3月','四月']
                    sc1 = True
                    sc2 = True
                    for st in special_time:
                        if dtime1[0]['text'] == st: sc1 = False
                    t0 = dtime1[0]['detail']['time'][0]
                    t1 = dtime1[0]['detail']['time'][1]
                    if t0 == '-inf': 
                        th = "" #x月x日前
                        tt = t1
                    if t1 == 'inf':
                        th = t0
                        tt = "" #从x月x日开始
                    if t0 != '-inf' and t1 != 'inf':    
                        data_1 = datetime.datetime.strptime(t0, "%Y-%m-%d %H:%M:%S")
                        data_2 = datetime.datetime.strptime(t1, "%Y-%m-%d %H:%M:%S")
                        if (data_2 - data_1).days > 180: sc2 = False
                    if sc1 and sc2:
                        single_time(ptext)
                    else:
                        entity = {'begtime':"",'endtime':"",'event':ptext}
                        entities.append(entity)
            # 如果切割后的文本仍有多个时间实体
            if len(dtime1) > 1:
                cut_after_mulptime(ptext)    
                

if __name__ == '__main__':
    importlib.reload(sys)
    for i in range(1, len(sys.argv)):
        text = sys.argv[i]
    #text = "老师，您好！我是计算机学院的**老师，很开心跟各位老师汇报：教师培训即将开始，将通过ZOOM线上举行，分四次，单次培训时长为90分钟。具体时间为4月28日、5月5日、5月12日和5月19日的20:00-21:00。请各位老师确认是否参加此次培训，如不能参加此次培训，将无法承担第一学年结对工作。另外在培训开始前，请各位老师开通账号，用于获取线上培训资源，麻烦各位老师将姓名、Title(Prof/Dr/Mr/MS)、出生日期在周日之前发给我。我的邮箱是1071686408@qq.com，手机号是12345678900.如果您有任何疑问，欢迎随时联系我。"
    text = text.replace("\n","")
    text = text.replace("\r","")
    distinguish(text)
    print(len(entities))
    for entity in entities:
        for item in entity:
            print(entity[item])
    
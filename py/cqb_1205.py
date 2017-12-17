# -*- coding: utf-8 -*-
"""
Created on Tue Dec  5 21:32:58 2017

@author: wolai
"""

#用Python写一个录入成绩函数：
#   输入参数
#      位置参数：姓名，成绩
#      默认参数：学校，专业
#      可选参数：加分
#      关键字参数：性别，年龄等
#   输出参数：一个字典
#
#然后将输出值依次传进一个列表，作为字典列表存储

def input_score(name,score,school = '中北大学',pro = '吹牛',*inc_score,**kw):
    dic_temp = {}
    dic_temp['姓名'] = name
    dic_temp['成绩'] = score
    dic_temp['学校'] = school
    dic_temp['专业'] = pro
    inc_sum = 0
    for inc in inc_score:
        inc_sum = inc_sum + inc
    dic_temp['加分'] = inc_sum
    for key in kw:
        dic_temp[key] = kw[key]
    return dic_temp
List_a = []
List_a.append(input_score('臭傻宝', '80'))
List_a.append(input_score('臭亲宝', '80','中北大学信息商务学院','吹牛',10,10,10,age = '26',sex = 'unknow'))
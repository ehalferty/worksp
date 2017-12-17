# -*- coding: utf-8 -*-
"""
Created on Wed Dec  6 21:55:38 2017

@author: wolai
"""

#def grade(name,scor,school='中北大学',profession='自动化',*addscor,**kw):
#    dic_temp={}
#    for i in range(len(name)):
#        for j in range(len(scor)):
#            dic_temp['分数']=scor[j]
#        dic_temp['姓名']=name[i]
#        dic_temp['学校']='中北大学'
#        dic_temp['专业']='自动化'
#        
#    return dic_temp
#name=['张三','李四','王五','赵六','杨七']
#scor=['80','60','89','58','90']
#
#d=grade(name,scor,'中北大学','自动化',10,20,sex='女',age='26')
#print (d)

def grade(name,scor,school='中北大学',profession='自动化',*addscor,**kw):
    list_temp = []
    for n_num in range(len(name)):
        dic_temp={}
        dic_temp['姓名']=name[n_num]
        dic_temp['分数']=scor[n_num]
        dic_temp['学校']=school
        dic_temp['专业']=profession
        addscore_sum = 0
        for addscore in addscor:
            addscore_sum = addscore_sum + addscore
        dic_temp['加分'] = addscore_sum
        for key in kw:
            dic_temp[key] = kw[key]
        list_temp.append(dic_temp)
    return list_temp
name=['张三','李四','王五','赵六','杨七']
scor=['80','60','89','58']
d=grade(name,scor,'中北大学','自动化',10,20,sex='女',age='26')
print (d)
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 14 22:26:31 2017

@author: wolai
"""
#author: cqb
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
scor=['80','60','89','58','88']
d=grade(name,scor,'中北大学','自动化',10,20,sex='女',age='26')
print (d)

with open('录入成绩1.txt','w') as f:
    for i in d:
        f.write('姓名:'+str(i['姓名'])+'   学校:'+str(i['学校'])+'\n')
        
with open('录入成绩1.txt','r') as f:
    print (f.read())

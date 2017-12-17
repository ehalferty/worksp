# -*- coding: utf-8 -*-
"""
Created on Sun Dec  3 09:09:33 2017

@author: wolai
"""
#author: cqb
#def str_odd(str):
#    m=[]
#    for i in range(len(str)):
#        if i%2 == 1:
#            k=i
#            m.append(str[0:k])
#    return m
#
#str='adjdfjvfbvnfjfj'
#b=str_odd(str)
#print(b)

#author: cqb
#def str_odd(str):
#    m=[]
#    for i in range(len(str)):
#        if i%2 == 1:
#            m.append(str[0:i:2])
#        elif i == len(str)-1:
#            m.append(str[0::2])
#    return m
#str='adjdfjvfbvnfjfj'
#b=str_odd(str)
#print(b)

#author: cqb
#def str_num(str):
#    m=[]
#    for i in range(len(str)):
#        m.append(int(str[i]))
#    return m
#str='1745756585904'
#b=str_num(str)
#print(b)

#author: cqb
#def str_chi(str):
#    m=[]
#    for i in range(len(str)):
#        if str[i]>='0' and str[i]<='9':
#            if str[i]=='0':
#                m.append('零')
#            elif str[i]=='1':
#                m.append('壹')
#            elif str[i]=='2':
#                m.append('贰')
#            elif str[i]=='3':
#                m.append('叁')
#            elif str[i]=='4':
#                m.append('肆')
#            elif str[i]=='5':
#                m.append('伍')
#            elif str[i]=='6':
#                m.append('陆')
#            elif str[i]=='7':
#                m.append('柒')
#            elif str[i]=='8':
#                m.append('捌')
#            elif str[i]=='9':
#                m.append('玖')
#    return m
#str='173878qhr978ty9'
#a=str_chi(str) 
#print (a)

#author: cqb
#def power(val,con):
#    m = 1
#    while con > 0:
#        m = val*m
#        con = con-1
#    return m
#def str_num(str):
#    sum = 0
#    for i in range(len(str)):
#        sum = int(str[i])*power(10,len(str)-i-1)+sum
#    return sum
#def str_ch(str):
#    m=''
#    for i in range(len(str)):
#        if str[i]>='0' and str[i]<='9':
#            if str[i]=='0':
#                m = m +'零'
#            elif str[i]=='1':
#                m = m +'壹'
#            elif str[i]=='2':
#                m = m +'贰'
#            elif str[i]=='3':
#                m = m +'叁'
#            elif str[i]=='4':
#                m = m +'肆'
#            elif str[i]=='5':
#                m = m +'伍'
#            elif str[i]=='6':
#                m = m +'陆'
#            elif str[i]=='7':
#                m = m +'柒'
#            elif str[i]=='8':
#                m = m +'捌'
#            elif str[i]=='9':
#                m = m +'玖'
#    return m
#	
##def str_unit(str):
##    n=[]
##    for i in range(len(str)):
##        n.append(str[i])
##    n.insert(len(str)-1,'十')
##    n.insert(len(str)-2,'百')
##    n.insert(len(str)-3,'千')
##    n.insert(len(str)-4,'万')
##    n.insert(len(str)-5,'十')
##    n.insert(len(str)-6,'百')
##    n.insert(len(str)-7,'千')
##    n.insert(len(str)-8,'亿')
##    n.insert(len(str)-9,'十')
##    return n
##num_a = '1'
##num_b = '2'
##num_c = str_num(num_a) + str_num(num_b)
##num_c = str_ch(str(num_c))
##print(str_unit(num_c))

#author: taoge
#def power(val,con):
#    m = 1
#    while con > 0:
#        m = val*m
#        con = con-1
#    return m
#def str_num(str):
#    sum = 0
#    for i in range(len(str)):
#        sum = int(str[i])*power(10,len(str)-i-1)+sum
#    return sum
#def str_ch(str):
#    ch ={'0':'零','1':'壹','2':'贰','3':'叁','4':'肆','5':'伍','6':'陆','7':'柒','8':'捌','9':'玖'}
#    m=''
#    for i in range(len(str)):
#        if str[i] in ch:
#            m = m + ch[str[i]]
#        if (len(str)-i)%4 == 1:
#            if (len(str)-i)//4 == 1:
#                m = m+'万'
#            elif (len(str)-i)//4 == 2:
#                m = m+'亿'
#        elif (len(str)-i)%4 == 2:
#            m = m+'拾'
#        elif (len(str)-i)%4 == 3:
#            m = m+'佰'
#        else:
#            m = m+'仟'
#    return m
#num_a = '121233714'
#num_b = '824554902'
#num_c = str_num(num_a) + str_num(num_b)
#num_c = str_ch(str(num_c))
#print(num_c)

#author: cqb
#def add(dic,key,value):
#    j = 0
#    if isinstance(key, list):
#        if len(key) == len(value):
#            for i in key:
#                dic[i]=value[j]
#                j = j+1
#        else:
#            print('Key-Value not match!')
#    else:
#        dic[key]=value
#    return dic
#dic={'姓名':'臭宝宝','单位':'中船重工','年龄':'26'}
#key=['姓名','性别','单位','年龄']
#value=['臭亲宝','女','国务院','26']
#dic_b=add(dic,key,value)
#print (dic_b)

#author: cqb
#def sky(x,a=1,b=2,c=1):
#	d=a*x*x+b*x+c
#	return d
#x=2
#e=sky(x,20,30,10)
#print (e)

#author: cqb
#def sum(a,b):
#	return a+b
#print (sum(1,2))

#author: cqb
#def sum(a):
#	sum_emp=0
#	for i in a:
#		sum_emp=sum_emp+i
#	return sum_emp
#a=[1,12,3,4,5,5,6,3,9]
#e=sum(a)
#print (e)

#author: cqb
#def plus(*a):
#	plus_emp=1
#	for i in a:
#		plus_emp=plus_emp*i	
#	return plus_emp
#a=[1,12,3,4,5,5,6,3,9]
#e=plus(*a)
#print (e)

#author: cqb
#def sky(x,a=1,b=2,*c):
#	for i in c:
#		d=a*x*x+b*x+i
#	return d
#x=2
#e=sky(x,1,2,10)
#print (e)

#author: cqb
#def add(**zl):
#	for key in zl:
#		print('%s is %s' % (key,zl[key]))
#print (add(姓名='臭宝宝',单位='中船重工',年龄='26'))
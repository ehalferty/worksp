# -*- coding: utf-8 -*-
"""
Created on Thu Nov 30 21:51:38 2017

@author: wolai
"""

#def sum(a,b):
#     c=a+b
#     print (c)
#     return c
#
#d=sum(b='1.1',a='2')
#print (d)

#@author: cqb
#def abs(a):
#     n=|a|
#    print(n)
#    return (n)
#a=2
#b=abs(a)
#print (b)

#@author: cqb
#def abs(a):
#    if a>0:
#       n=a;
#    else: n=-a
#    return (n)
#a=2
#b=abs(a)
#print (b)

#@author: cqb
#def abs(a):
#    if a>0:
#       n=a;
#    else: n=-a
#    return (n)
#def sum(a,b):
#    m=a+b
#    return m
#a,b=2,-1
#c=abs(a)
#d=abs(b)
#e=sum(c,d)
#print (e)
#
#a,b=2,-10
#c=abs(a)
#d=abs(b)
#e=sum(c,d)
#print (e)
#
#a,b=2,-10
#
#e=sum(abs(a),abs(b))
#print (e)

#@author: cqb
#def sum(a,b):
#    m=abs(a)+abs(b)
#    return m
#def abs(a):
#    if a>0:
#       n=a;
#    else: n=-a
#    return (n)
#e=sum(2,-10)
#print (e)

#@author: cqb
#def sum(a,b):
#    m=abs(a)+abs(b)
#    return m
#def abs(a):
#    if a>0:
#       n=a;
#    else: n=-a
#    return (n)
#e=sum(2,-10)
#print (e)
#print (f)

#@author: cqb
#def sum(a,b):
#    m=abs(a)+abs(b)
#    f=abs(a+b)
#    print (f)
#    return m
#    
#def abs(a):
#    if a>0:
#       n=a;
#    else: n=-a
#    return (n)
#e=sum(2,-10)
#
#print (e)
#def sum(a,b):
#    m=abs(a)+abs(b)
#    f=abs(a+b)
#   
#    return m,f
#   
#def abs(a):
#    if a>0:
#       n=a;
#    else: n=-a
#    return (n)
#e,f=sum(2,-10)
#
#print (e)
#print (f)

#@author: cqb
#def sum(a,b):
#    c=a+b
#    return c
#d=sum(a,b)
#for i=0
#   x=d+an
#print x

#@author: taoge
#def listsum(list_a):
#    list_sum = 0
#    for i in list_a:
#        list_sum = list_sum+i
#    return list_sum
#
#a= [1,2,3,4,5,6,7,8,9,10]
#b = listsum(a)
#print(b)

#@author: taoge
#def listsum(list_a):
#    list_sum = 0
#    for i in list_a:
#        list_sum = list_sum+i
#    list_a.append(list_sum)
#    return list_sum
#
#a = [1,2,3,4,5,6,7,8,9,10]
#b = listsum(a)
#print(a)

#@author: taoge
#from functools import reduce
#
#a = [1,2,3,4,5,6,7,8,9,10]
#print(reduce(lambda a,b:a+b,a))

#@author: cqb
#from functools import reduce
#a=[2,3,-5,6,9,-10,20]
#print (reduce(lambda a,b:abs(a)+abs(b),a ))

#@author: cqb
#def abs (a):
#    n=[]
#    for i in a:
#       if i>0:
#        n.append(i);
#       else: n.append(-i)
#
#    return (n)
#
#a=[2,3,-5,6,9,-10,20]
#m=abs (a)
#print (m)

#@author: taoge
#a=[2,3,-5,6,9,-10,20]
#print(list(map(abs,a)))

#@author: cqb&cbb
#def sqr(i):
#    c=i*i
#    return c
#a=[1,2,3,4,5,6,7,8,9,10]
#print(list(map(sqr ,a)))

#@author: cqb&cbb
#def abs(a):
#    n=[]
#    for i in a:
#        n.append(i*i);  
#    return (n)
#
#a=[2,3,-5,6,9,-10,20]
#m=abs (a)
#print (m)

#@author: taoge
#def str_capital(str):
#    str_temp = ''
#    for i in str:
#        if i >= 'a' and i <= 'z':
#             str_temp =str_temp + chr(ord(i)-32)
#        else: str_temp =str_temp + i
#    return str_temp
#a = 'AsajdAfsdFkhaskdAsfsadasdBasdasdAsdadfn'
#a = str_capital(a)
#print(a)

#@author: cqb&cbb
#def str_odd(a):
#   str_temp=''
#   for i in range(len(a)):
#       if i%2 == 0:
#           str_temp=str_temp+a[i]
#   return str_temp
#a='ahsjhfdnffbgjg'
#a=str_odd(a)
#print (a)

#@author: cqb&cbb
#def str_character(a):
#  m=[]
#  for i in range(len(a)):
#      m.append(a[0:i+1]) 
#  return m
#a='shgaohgoudfghlsajhgo'
#a = str_character(a)
#print (a)
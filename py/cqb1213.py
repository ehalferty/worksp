# -*- coding: utf-8 -*-
"""
Created on Wed Dec 13 21:29:09 2017

@author: wolai
"""

#写一个类，类的名称是班级，累的成员有姓名、班级和专业，要求姓名和班级不可以修改，专业可以修改。
#@author: cqb
#class Student(object):
#    def __init__(self,name,grade,profession):
#        self.__name=name
#        self.__grade=grade
#        self.__profession=profession
#    def print_grade(self):
#        print('name is %s' % self.__name,'grade is %s' % self.__grade,'profession is %s' % self.__profession) 
#    def get_name(self):
#        return self.__name
#    def get_grade(self):
#        return self.__grade
#    def get_profession(self):
#        return self.__profession
#    def set_profession(self,profession):
#        self.__profession=profession
#A=Student('A','二班','自动化')
#B=Student('B','三班','电子信息')
#C=Student('C','一班','电气自动化')
#A.print_grade()
#B.print_grade()
#C.print_grade()
#C.set_profession('测控技术')
#C.print_grade()

#@author: turtle_fly
#class a():
#    num = 0  
#   
#obj1 = a()  
#obj2 = a()   
#print (obj1.num, obj2.num, a.num)  
#      
#obj1.num += 1  
#print (obj1.num, obj2.num, a.num)   
#  
#a.num += 2  
#print(id(obj1.num),id(a.num))
#print (obj1.num, obj2.num, a.num)

#author: turtle_fly
class task_queue:
    def __init__(self):
        self.queue = []
    def append(self,obj):
        self.queue.append(obj)
        
    def print_queue(self):
        print (self.queue)
        
a=task_queue()
b=task_queue()
c=task_queue()

a.append('tc_1')
#a.queue = ['tc_1']

a.print_queue()
b.print_queue()
c.print_queue()
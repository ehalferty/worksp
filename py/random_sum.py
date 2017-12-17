# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import copy
import xlrd

def check(output,input,sumval):
    input = sorted(input)
    pre = []
    _check(pre,0,output,input,0,sumval)
    
def _check(pre,presum,output,input,start,sumval):
    for i in range(start,len(input)):
        newPreSum = presum + input[i]
        if (newPreSum > sumval):
            break
        newPre = copy.copy(pre)
        newPre.append(input[i])
        if (newPreSum == sumval):
            output.append(newPre)
            break
        _check(newPre,newPreSum,output,input,i+1,sumval)

data = xlrd.open_workbook('excelFile.xls')
table = data.sheets()[0]
table_col = table.col_values(1)
output = []
check(output,table_col,50)
for i in range(len(output)):
    print(output[i])
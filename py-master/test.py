# -*- coding: utf-8 -*-

from bs4 import BeautifulSoup
import requests

response = requests.get('http://esf.xian.fang.com/')
soup = BeautifulSoup(response.text, 'lxml')

regions = soup.select('#list_D02_10 > div.qxName > a')  # 区域
totprices = soup.select('#list_D02_11 > p > a')  # 总价
housetypes = soup.select('#list_D02_12 > a')  # 户型
areas = soup.select('#list_D02_13 > p > a')  # 面积

print('区域href：')
n = 1
while n < 11:
    print(regions[n].get('attr'))
    n = n + 1
print('总价href：')
n = 1
while n < 10:
    print(totprices[n].get('href'))
    n = n + 1
print('户型href：')
n = 1
while n < 7:
    print(housetypes[n].get('href'))
    n = n + 1
print('面积href：')
n = 1
while n < 10:
    print(areas[n].get('href'))
    n = n + 1
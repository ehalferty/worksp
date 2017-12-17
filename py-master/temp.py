# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
from bs4 import BeautifulSoup
import requests

def spider_1(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.text,'lxml')

    titles = soup.select('dd > p.title > a')            # 标题
    hrefs = soup.select('dd > p.title > a')            # 链接
    details = soup.select('dd > p.mt12')                # 建筑信息
    courts = soup.select('dd > p:nth-of-type(3) > a')   # 小区
    adds = soup.select('dd > p:nth-of-type(3) > span')  # 地址
    areas = soup.select('dd > div.area.alignR > p:nth-of-type(1)')     # 面积
    prices = soup.select('dd > div.moreInfo > p:nth-of-type(1) > span.price')  # 总价
    danjias = soup.select('dd > div.moreInfo > p.danjia.alignR.mt5')    # 单价
    authors = soup.select('dd > p.gray6.mt10 > a')      # 发布者
    tags = soup.select('dd > div.mt8.clearfix > div.pt4.floatl')   # 标签

    for title, href, detail, court, add, area, price, danjia, author, tag in zip(titles, hrefs, details, courts, adds, areas, prices, danjias, authors, tags):
        data = {
            'title': title.get_text(),
            'href': 'http://esf.xian.fang.com' + href.get('href'),
            'detail': list(detail.stripped_strings),
            'court': court.get_text(),
            'add': add.get_text(),
            'area': area.get_text(),
            'price': price.get_text(),
            'danjia': danjia.get_text(),
            'author': author.get_text(),
            'tag': list(tag.stripped_strings)
        }
        print(data)

page = 1
while page < 100:
    url = 'http://newhouse.yz.fang.com/house/web/newhouse_sumall.php?page='+str(page)
    spider_1(url)
    page = page + 1